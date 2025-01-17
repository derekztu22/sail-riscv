/*=======================================================================================*/
/*  This Sail RISC-V architecture model, comprising all files and                        */
/*  directories except where otherwise noted is subject the BSD                          */
/*  two-clause license in the LICENSE file.                                              */
/*                                                                                       */
/*  SPDX-License-Identifier: BSD-2-Clause                                                */
/*=======================================================================================*/

/* Machine-mode and supervisor-mode functionality. */

/* CSR access control */

function csrAccess(csr : csreg) -> csrRW = csr[11..10]
function csrPriv(csr : csreg) -> priv_level = csr[9..8]

val check_CSR_access : (csrRW, priv_level, Privilege, bool) -> bool
function check_CSR_access(csrrw, csrpr, p, isWrite) =
    not(isWrite == true & csrrw == 0b11)  /* read/write */
  & (privLevel_to_bits(p) >=_u csrpr)      /* privilege */

function check_TVM_SATP(csr : csreg, p : Privilege) -> bool =
  not(csr == 0x180 & p == Supervisor & mstatus[TVM] == 0b1)

// There are several features that are controlled by machine/supervisor enable
// bits (m/senvcfg, m/scounteren, etc.). This abstracts that logic.
function feature_enabled_for_priv(p : Privilege, machine_enable_bit : bit, supervisor_enable_bit : bit) -> bool = match p {
  Machine => true,
  Supervisor => machine_enable_bit == bitone,
  User => machine_enable_bit == bitone & (not(extensionEnabled(Ext_S)) | supervisor_enable_bit == bitone),
}

// Return true if the counter is enabled OR the CSR is not a counter.
function check_Counteren(csr : csreg, p : Privilege) -> bool = {
  // Check if it is not a counter.
  if csr <_u 0xC00 | 0xC1F <_u csr then return true;

  // Check the relevant bit in m/scounteren.
  let index = unsigned(csr[4 .. 0]);
  feature_enabled_for_priv(p, mcounteren.bits[index], scounteren.bits[index])
}

// Return true if the stimecmp[h] CSR is accessible OR the CSR is not stimecmp[h].
function check_Stimecmp(csr : csreg, p : Privilege) -> bool = {
  // Check if it is not stimecmp.
  if csr != 0x14D & csr != 0x15D then return true;

  p == Machine | (p == Supervisor & mcounteren[TM] == 0b1 & menvcfg[STCE] == 0b1)
}

/* Seed may only be accessed if we are doing a write, and access has been
 * allowed in the current priv mode
 */
function check_seed_CSR (csr : csreg, p : Privilege, isWrite : bool) -> bool = {
  if not(csr == 0x015) then {
    true
  } else if not(isWrite) then {
    /* Read-only access to the seed CSR is not allowed */
    false
  } else {
    match (p) {
      Machine => true,
      Supervisor => false, /* TODO: base this on mseccfg */
      User => false, /* TODO: base this on mseccfg */
    }
  }
}

function check_CSR(csr : csreg, p : Privilege, isWrite : bool) -> bool =
    is_CSR_defined(csr)
  & check_CSR_access(csrAccess(csr), csrPriv(csr), p, isWrite)
  // TODO: If we add `p` back to is_CSR_defined() we could move these three
  // check_ functions back there. We should also rename is_CSR_defined()
  // to is_CSR_accessible() or similar.
  & check_TVM_SATP(csr, p)
  & check_Counteren(csr, p)
  & check_Stimecmp(csr, p)
  & check_seed_CSR(csr, p, isWrite)

/* Reservation handling for LR/SC.
 *
 * The reservation state is maintained external to the model since the
 * reservation behavior is platform-specific anyway and maintaining
 * this state outside the model simplifies the concurrency analysis.
 *
 * These are externs are defined here in the system module since
 * we currently perform reservation cancellation on privilege level
 * transition.  Ideally, the platform should get more visibility into
 * where cancellation can be performed.
 */

val speculate_conditional = impure {interpreter: "excl_res", c: "speculate_conditional", lem: "speculate_conditional_success"} : unit -> bool

val load_reservation = impure {interpreter: "Platform.load_reservation", c: "load_reservation", lem: "load_reservation"} : physaddrbits -> unit
val match_reservation = pure {interpreter: "Platform.match_reservation", lem: "match_reservation", c: "match_reservation"} : physaddrbits -> bool
val cancel_reservation = impure {interpreter: "Platform.cancel_reservation", c: "cancel_reservation", lem: "cancel_reservation"} : unit -> unit

/* Exception delegation: given an exception and the privilege at which
 * it occured, returns the privilege at which it should be handled.
 */
function exception_delegatee(e : ExceptionType, p : Privilege) -> Privilege = {
  let idx   = num_of_ExceptionType(e);
  let super = bit_to_bool(medeleg.bits[idx]);
  let deleg = if extensionEnabled(Ext_S) & super then Supervisor else Machine;
  /* We cannot transition to a less-privileged mode. */
  if   privLevel_to_bits(deleg) <_u privLevel_to_bits(p)
  then p else deleg
}

/* Interrupts are prioritized in privilege order, and for each
 * privilege, in the order: external, software, timers.
 */
function findPendingInterrupt(ip : xlenbits) -> option(InterruptType) = {
  let ip = Mk_Minterrupts(ip);
  if      ip[MEI] == 0b1 then Some(I_M_External)
  else if ip[MSI] == 0b1 then Some(I_M_Software)
  else if ip[MTI] == 0b1 then Some(I_M_Timer)
  else if ip[SEI] == 0b1 then Some(I_S_External)
  else if ip[SSI] == 0b1 then Some(I_S_Software)
  else if ip[STI] == 0b1 then Some(I_S_Timer)
  else                        None()
}

/* Given the current privilege level, return the pending set
 * of interrupts for the highest privilege that has any pending.
 *
 * We don't use the lowered views of {xie,xip} here, since the spec
 * allows for example the M_Timer to be delegated to the S-mode.
 */
function getPendingSet(priv : Privilege) -> option((xlenbits, Privilege)) = {
  // mideleg can only be non-zero if we support Supervisor mode.
  assert(extensionEnabled(Ext_S) | mideleg.bits == zeros());

  let pending_m = mip.bits & mie.bits & ~(mideleg.bits);
  let pending_s = mip.bits & mie.bits & mideleg.bits;

  let mIE = (priv == Machine    & mstatus[MIE] == 0b1) | priv == Supervisor | priv == User;
  let sIE = (priv == Supervisor & mstatus[SIE] == 0b1) | priv == User;

  if      mIE & (pending_m != zeros()) then Some((pending_m, Machine))
  else if sIE & (pending_s != zeros()) then Some((pending_s, Supervisor))
  else None()
}

/* Examine the current interrupt state and return an interrupt to be *
 * handled (if any), and the privilege it should be handled at.
 */
function dispatchInterrupt(priv : Privilege) -> option((InterruptType, Privilege)) = {
  match getPendingSet(priv) {
    None()       => None(),
    Some(ip, p)  => match findPendingInterrupt(ip) {
                      None()  => None(),
                      Some(i) => Some((i, p)),
                    }
  }
}

/* types of privilege transitions */

union ctl_result = {
  CTL_TRAP : sync_exception,
  CTL_SRET : unit,
  CTL_MRET : unit,
}

/* trap value */

function tval(excinfo : option(xlenbits)) -> xlenbits = {
  match (excinfo) {
    Some(e) => e,
    None()  => zeros()
  }
}

$ifdef RVFI_DII
val rvfi_trap : unit -> unit
// TODO: record rvfi_trap_data
function rvfi_trap () =
  rvfi_inst_data[rvfi_trap] = 0x01
$else
val rvfi_trap : unit -> unit
function rvfi_trap () = ()
$endif

/* handle exceptional ctl flow by updating nextPC and operating privilege */

function trap_handler(del_priv : Privilege, intr : bool, c : exc_code, pc : xlenbits, info : option(xlenbits), ext : option(ext_exception))
                     -> xlenbits = {
  rvfi_trap();
  if   get_config_print_platform()
  then print_platform("handling " ^ (if intr then "int#" else "exc#")
                      ^ BitStr(c) ^ " at priv " ^ to_str(del_priv)
                      ^ " with tval " ^ BitStr(tval(info)));

  match (del_priv) {
    Machine => {
       mcause[IsInterrupt] = bool_to_bits(intr);
       mcause[Cause]       = zero_extend(c);

       mstatus[MPIE] = mstatus[MIE];
       mstatus[MIE]  = 0b0;
       mstatus[MPP]  = privLevel_to_bits(cur_privilege);
       mtval           = tval(info);
       mepc            = pc;

       cur_privilege   = del_priv;

       handle_trap_extension(del_priv, pc, ext);

       if   get_config_print_reg()
       then print_reg("CSR mstatus <- " ^ BitStr(mstatus.bits));

       prepare_trap_vector(del_priv, mcause)
    },
    Supervisor => {
       assert (extensionEnabled(Ext_S), "no supervisor mode present for delegation");

       scause[IsInterrupt] = bool_to_bits(intr);
       scause[Cause]       = zero_extend(c);

       mstatus[SPIE] = mstatus[SIE];
       mstatus[SIE]  = 0b0;
       mstatus[SPP]  = match cur_privilege {
                           User => 0b0,
                           Supervisor => 0b1,
                           Machine => internal_error(__FILE__, __LINE__, "invalid privilege for s-mode trap")
                         };
       stval           = tval(info);
       sepc            = pc;

       cur_privilege   = del_priv;

       handle_trap_extension(del_priv, pc, ext);

       if   get_config_print_reg()
       then print_reg("CSR mstatus <- " ^ BitStr(mstatus.bits));

       prepare_trap_vector(del_priv, scause)
    },
    User => internal_error(__FILE__, __LINE__, "Invalid privilege level"),
  };
}

function exception_handler(cur_priv : Privilege, ctl : ctl_result,
                           pc: xlenbits) -> xlenbits = {
  match (cur_priv, ctl) {
    (_, CTL_TRAP(e)) => {
      let del_priv = exception_delegatee(e.trap, cur_priv);
      if   get_config_print_platform()
      then print_platform("trapping from " ^ to_str(cur_priv) ^ " to " ^ to_str(del_priv)
                          ^ " to handle " ^ to_str(e.trap));
      trap_handler(del_priv, false, exceptionType_to_bits(e.trap), pc, e.excinfo, e.ext)
    },
    (_, CTL_MRET())  => {
      let prev_priv   = cur_privilege;
      mstatus[MIE]  = mstatus[MPIE];
      mstatus[MPIE] = 0b1;
      cur_privilege   = privLevel_of_bits(mstatus[MPP]);
      mstatus[MPP]  = privLevel_to_bits(if extensionEnabled(Ext_U) then User else Machine);
      if   cur_privilege != Machine
      then mstatus[MPRV] = 0b0;

      if   get_config_print_reg()
      then print_reg("CSR mstatus <- " ^ BitStr(mstatus.bits));
      if   get_config_print_platform()
      then print_platform("ret-ing from " ^ to_str(prev_priv) ^ " to " ^ to_str(cur_privilege));

      prepare_xret_target(Machine)
    },
    (_, CTL_SRET())  => {
      let prev_priv   = cur_privilege;
      mstatus[SIE]  = mstatus[SPIE];
      mstatus[SPIE] = 0b1;
      cur_privilege   = if mstatus[SPP] == 0b1 then Supervisor else User;
      mstatus[SPP]  = 0b0;
      if   cur_privilege != Machine
      then mstatus[MPRV] = 0b0;

      if   get_config_print_reg()
      then print_reg("CSR mstatus <- " ^ BitStr(mstatus.bits));
      if   get_config_print_platform()
      then print_platform("ret-ing from " ^ to_str(prev_priv)
                          ^ " to " ^ to_str(cur_privilege));

      prepare_xret_target(Supervisor)
    },
  }
}

function handle_mem_exception(virtaddr(addr) : virtaddr, e : ExceptionType) -> unit = {
  let t : sync_exception = struct { trap    = e,
                                    excinfo = Some(addr),
                                    ext     = None() } in
  set_next_pc(exception_handler(cur_privilege, CTL_TRAP(t), PC))
}

function handle_exception(e: ExceptionType) -> unit = {
  let t : sync_exception = struct { trap    = e,
                                    excinfo = None(),
                                    ext     = None() } in
  set_next_pc(exception_handler(cur_privilege, CTL_TRAP(t), PC))
}

function handle_interrupt(i : InterruptType, del_priv : Privilege) -> unit =
  set_next_pc(trap_handler(del_priv, true, interruptType_to_bits(i), PC, None(), None()))

/* state state initialization */

function init_sys() -> unit = {
  cur_privilege = Machine;

  mhartid     = zeros();
  mconfigptr  = zeros();

  misa[MXL] = arch_to_bits(if xlen == 32 then RV32 else RV64);
  misa[A]   = 0b1;                             /* atomics */
  misa[C]   = bool_to_bits(sys_enable_rvc());  /* RVC */
  misa[B]   = bool_to_bits(sys_enable_bext()); /* Bit-manipulation */
  misa[I]   = 0b1;                             /* base integer ISA */
  misa[M]   = 0b1;                             /* integer multiply/divide */
  misa[U]   = 0b1;                             /* user-mode */
  misa[S]   = 0b1;                             /* supervisor-mode */
  misa[V]   = bool_to_bits(sys_enable_vext()); /* vector extension */

  if   sys_enable_fdext() & sys_enable_zfinx()
  then internal_error(__FILE__, __LINE__, "F and Zfinx cannot both be enabled!");

  /* We currently support both F and D */
  misa[F]   = bool_to_bits(sys_enable_fdext());      /* single-precision */
  misa[D]   = if   flen >= 64
                then bool_to_bits(sys_enable_fdext())  /* double-precision */
                else 0b0;

  mstatus = set_mstatus_SXL(mstatus, misa[MXL]);
  mstatus = set_mstatus_UXL(mstatus, misa[MXL]);
  mstatus[SD]   = 0b0;
  mstatus[MPP] = privLevel_to_bits(lowest_supported_privLevel());

  /* set to little-endian mode */
  if xlen == 64 then {
    mstatus = Mk_Mstatus([mstatus.bits with 37 .. 36 = 0b00])
  };
  mstatush.bits = zeros();

  mip.bits     = zeros();
  mie.bits     = zeros();
  mideleg.bits = zeros();
  medeleg.bits = zeros();
  mtvec.bits   = zeros();
  mcause.bits  = zeros();
  mepc            = zeros();
  mtval           = zeros();
  mscratch        = zeros();

  mcycle          = zeros();
  mtime           = zeros();

  mcounteren.bits = zeros();

  minstret           = zeros();
  minstret_increment = true;

  menvcfg.bits = zeros();
  senvcfg.bits = zeros();
  /* initialize vector csrs */
  vstart             = zeros();
  vl                 = zeros();
  vcsr[vxrm]       = 0b00;
  vcsr[vxsat]      = 0b0;
  vtype[vill]      = 0b1;
  vtype[reserved]  = zeros();
  vtype[vma]       = 0b0;
  vtype[vta]       = 0b0;
  vtype[vsew]      = 0b000;
  vtype[vlmul]     = 0b000;

  // PMP's L and A fields are set to 0 on reset.
  init_pmp();

  // log compatibility with spike
  if   get_config_print_reg()
  then print_reg("CSR mstatus <- " ^ BitStr(mstatus.bits) ^ " (input: " ^ BitStr(zeros() : xlenbits) ^ ")")
}

/* memory access exceptions, defined here for use by the platform model. */

union MemoryOpResult ('a : Type) = {
  MemValue     : 'a,
  MemException : ExceptionType
}

val MemoryOpResult_add_meta : forall ('t : Type). (MemoryOpResult('t), mem_meta) -> MemoryOpResult(('t, mem_meta))
function MemoryOpResult_add_meta(r, m) = match r {
  MemValue(v)     => MemValue(v, m),
  MemException(e) => MemException(e)
}

val MemoryOpResult_drop_meta : forall ('t : Type). MemoryOpResult(('t, mem_meta)) -> MemoryOpResult('t)
function MemoryOpResult_drop_meta(r) = match r {
  MemValue(v, m)  => MemValue(v),
  MemException(e) => MemException(e)
}
