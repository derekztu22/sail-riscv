mapping bytes_wordwidth : int <-> word_width = {
  1 <-> BYTE,
  2 <-> HALF,
  4 <-> WORD,
  8 <-> DOUBLE
}

val get_num_melem : (int) -> int effect {undef}
function get_num_melem(num_elem) = {
  var num_melem : int = undefined;
  num_melem = num_elem;
  num_melem
}

/* ******************************************************************* */
union clause ast = MACCO_MM : (regidx, regidx, regidx)

mapping clause encdec = MACCO_MM(ms2, ms1, md)
  <-> 0b000001 @ 0b0 @ ms2 @ ms1 @ 0b001  @ md @ 0b1011111

function clause execute(MACCO_MM(ms2, ms1, md)) = {
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);

  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2); 
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
    foreach(j from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[j]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i*num_elem + j];
      let add = md_val_idx + mult;
      result[i*num_elem + j] = add;
    };
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = MACCO_MM(ms2, ms1, md)
  <-> "macco.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^sep() ^ mreg_name(ms1)

/* ******************************************************************* */
union clause ast = MACCP_MM : (regidx, regidx, regidx)

mapping clause encdec = MACCP_MM(ms2, ms1, md)
  <-> 0b000001 @ 0b1 @ ms2 @ ms1 @ 0b001  @ md @ 0b1011111

function clause execute(MACCP_MM(ms2, ms1, md)) = {
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);

  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2); 
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[i]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i];
      let add = md_val_idx + mult;
      result[i] = add;
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = MACCP_MM(ms2, ms1, md)
  <-> "maccp.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = MSACCO_MM : (regidx, regidx, regidx)

mapping clause encdec = MSACCO_MM(ms2, ms1, md)
  <-> 0b000011 @ 0b0 @ ms2 @ ms1 @ 0b001  @ md @ 0b1011111

function clause execute(MSACCO_MM(ms2, ms1, md)) = {
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);

  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2);
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
    foreach(j from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[j]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i*'n + j];
      let add = md_val_idx - mult;
      result[i*'n + j] = add;
    };
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = MSACCO_MM(ms2, ms1, md)
  <-> "msacco.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = MSACCP_MM : (regidx, regidx, regidx)

mapping clause encdec = MSACCP_MM(ms2, ms1, md)
  <-> 0b000011 @ 0b1 @ ms2 @ ms1 @ 0b001  @ md @ 0b1011111

function clause execute(MSACCP_MM(ms2, ms1, md)) = {
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);

  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2);
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[i]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i];
      let sub = md_val_idx - mult;
      result[i] = sub;
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = MSACCP_MM(ms2, ms1, md)
  <-> "msaccp.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FMACC64O_MM : (regidx, regidx, regidx)

mapping clause encdec = FMACC64O_MM(ms2, ms1, md)
  <-> 0b000101 @ 0b0 @ ms2 @ ms1 @ 0b000  @ md @ 0b1011111

function clause execute(FMACC64O_MM(ms2, ms1, md)) = {
  let mbits  : int  = 64;
  let num_elem   : int  = 8;

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;
  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2); 
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
    foreach(j from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[j]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i*num_elem + j];
      let add = md_val_idx + mult;
      result[i*num_elem + j] = add;
    };
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = FMACC64O_MM(ms2, ms1, md)
  <-> "fmacc64o.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FMACC64P_MM : (regidx, regidx, regidx)

mapping clause encdec = FMACC64P_MM(ms2, ms1, md)
  <-> 0b000101 @ 0b1 @ ms2 @ ms1 @ 0b000  @ md @ 0b1011111

function clause execute(FMACC64P_MM(ms2, ms1, md)) = {
  let num_elem   : int  = 8;

  let 'n = num_elem;
  let 'm = 64;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2);
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[i]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i];
      let add = md_val_idx + mult;
      result[i] = add;
  };
 write_mreg('o, md, result);
  RETIRE_SUCCESS
}

mapping clause assembly = FMACC64P_MM(ms2, ms1, md)
  <-> "fmacc64p.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FMACC32O_MM : (regidx, regidx, regidx)

mapping clause encdec = FMACC32O_MM(ms2, ms1, md)
  <-> 0b000101 @ 0b0 @ ms2 @ ms1 @ 0b001  @ md @ 0b1011111

function clause execute(FMACC32O_MM(ms2, ms1, md)) = {
  let mbits  : int  = 32;
  let num_elem   : int  = 16;

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;
  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));


  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2); 
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
    foreach(j from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[j]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i*num_elem + j];
      let add = md_val_idx + mult;
      result[i*num_elem + j] = add;
    };
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = FMACC32O_MM(ms2, ms1, md)
  <-> "fmacc32o.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FMACC32P_MM : (regidx, regidx, regidx)

mapping clause encdec = FMACC32P_MM(ms2, ms1, md)
  <-> 0b000101 @ 0b1 @ ms2 @ ms1 @ 0b001 @ md @ 0b1011111

function clause execute(FMACC32P_MM(ms2, ms1, md)) = {
  let num_elem   : int  = 16;

  let 'n = num_elem;
  let 'm = 32;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2);
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[i]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i];
      let add = md_val_idx + mult;
      result[i] = add;
  };
 write_mreg('o, md, result);
  RETIRE_SUCCESS
}

mapping clause assembly = FMACC32P_MM(ms2, ms1, md)
  <-> "fmacc32p.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FMACC16O_MM : (regidx, regidx, regidx)

mapping clause encdec = FMACC16O_MM(ms2, ms1, md)
  <-> 0b000101 @ 0b0 @ ms2 @ ms1 @ 0b010  @ md @ 0b1011111

function clause execute(FMACC16O_MM(ms2, ms1, md)) = {
  let mbits  : int  = 16;
  let num_elem   : int  = 32;

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;
  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));


  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2); 
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
    foreach(j from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[j]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i*num_elem + j];
      let add = md_val_idx + mult;
      result[i*num_elem + j] = add;
    };
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = FMACC16O_MM(ms2, ms1, md)
  <-> "fmacc16o.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FMACC16P_MM : (regidx, regidx, regidx)

mapping clause encdec = FMACC16P_MM(ms2, ms1, md)
  <-> 0b000101 @ 0b1 @ ms2 @ ms1 @ 0b010  @ md @ 0b1011111

function clause execute(FMACC16P_MM(ms2, ms1, md)) = {
  let num_elem   : int  = 32;

  let 'n = num_elem;
  let 'm = 16;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2);
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[i]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i];
      let add = md_val_idx + mult;
      result[i] = add;
  };
 write_mreg('o, md, result);
  RETIRE_SUCCESS
}

mapping clause assembly = FMACC16P_MM(ms2, ms1, md)
  <-> "fmacc16p.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)



/* ******************************************************************* */

union clause ast = FSMACC64O_MM : (regidx, regidx, regidx)

mapping clause encdec = FSMACC64O_MM(ms2, ms1, md)
  <-> 0b000110 @ 0b0 @ ms2 @ ms1 @ 0b000  @ md @ 0b1011111

function clause execute(FSMACC64O_MM(ms2, ms1, md)) = {
  let mbits  : int  = 64;
  let num_elem   : int  = 8;

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;
  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));


  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2); 
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
    foreach(j from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[j]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i*num_elem + j];
      let add = md_val_idx - mult;
      result[i*num_elem + j] = add;
    };
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = FSMACC64O_MM(ms2, ms1, md)
  <-> "fsmacc64o.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FSMACC64P_MM : (regidx, regidx, regidx)

mapping clause encdec = FSMACC64P_MM(ms2, ms1, md)
  <-> 0b000110 @ 0b1 @ ms2 @ ms1 @ 0b000  @ md @ 0b1011111

function clause execute(FSMACC64P_MM(ms2, ms1, md)) = {
  let num_elem   : int  = 8;

  let 'n = num_elem;
  let 'm = 64;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2);
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[i]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i];
      let add = md_val_idx - mult;
      result[i] = add;
  };
 write_mreg('o, md, result);
  RETIRE_SUCCESS
}

mapping clause assembly = FSMACC64P_MM(ms2, ms1, md)
  <-> "fsmacc64p.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FSMACC32O_MM : (regidx, regidx, regidx)

mapping clause encdec = FSMACC32O_MM(ms2, ms1, md)
  <-> 0b000110 @ 0b0 @ ms2 @ ms1 @ 0b001  @ md @ 0b1011111

function clause execute(FSMACC32O_MM(ms2, ms1, md)) = {
  let mbits  : int  = 32;
  let num_elem   : int  = 16;

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;
  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));


  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2); 
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
    foreach(j from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[j]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i*num_elem + j];
      let add = md_val_idx - mult;
      result[i*num_elem + j] = add;
    };
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = FSMACC32O_MM(ms2, ms1, md)
  <-> "fsmacc32o.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FSMACC32P_MM : (regidx, regidx, regidx)

mapping clause encdec = FSMACC32P_MM(ms2, ms1, md)
  <-> 0b000110 @ 0b1 @ ms2 @ ms1 @ 0b001 @ md @ 0b1011111

function clause execute(FSMACC32P_MM(ms2, ms1, md)) = {
  let num_elem   : int  = 16;

  let 'n = num_elem;
  let 'm = 32;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2);
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[i]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i];
      let add = md_val_idx - mult;
      result[i] = add;
  };
 write_mreg('o, md, result);
  RETIRE_SUCCESS
}

mapping clause assembly = FSMACC32P_MM(ms2, ms1, md)
  <-> "fsmacc32p.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FSMACC16O_MM : (regidx, regidx, regidx)

mapping clause encdec = FSMACC16O_MM(ms2, ms1, md)
  <-> 0b000110 @ 0b0 @ ms2 @ ms1 @ 0b010  @ md @ 0b1011111

function clause execute(FSMACC16O_MM(ms2, ms1, md)) = {
  let mbits  : int  = 16;
  let num_elem   : int  = 32;

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;
  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));


  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2); 
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
    foreach(j from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[j]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i*num_elem + j];
      let add = md_val_idx - mult;
      result[i*num_elem + j] = add;
    };
  };
 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = FSMACC16O_MM(ms2, ms1, md)
  <-> "fsmacc16o.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = FSMACC16P_MM : (regidx, regidx, regidx)

mapping clause encdec = FSMACC16P_MM(ms2, ms1, md)
  <-> 0b000110 @ 0b1 @ ms2 @ ms1 @ 0b010  @ md @ 0b1011111

function clause execute(FSMACC16P_MM(ms2, ms1, md)) = {
  let num_elem   : int  = 32;

  let 'n = num_elem;
  let 'm = 16;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  let ms2_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms2);
  let md_val  : vector('o, dec, bits('m)) = read_mreg(num_elem, md);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
      let ms1_val_idx = signed(ms1_val[i]);
      let ms2_val_idx = signed(ms2_val[i]);
      let mult = ms1_val_idx * ms2_val_idx;
      let md_val_idx = md_val[i];
      let add = md_val_idx - mult;
      result[i] = add;
  };
 write_mreg('o, md, result);
  RETIRE_SUCCESS
}

mapping clause assembly = FSMACC16P_MM(ms2, ms1, md)
  <-> "fsmacc16p.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms2) ^ sep() ^ mreg_name(ms1)


/* ******************************************************************* */

union clause ast = LOADXY_MM : (regidx, regidx)

mapping clause encdec = LOADXY_MM(rs1, md)
  <-> 0b000000 @ 0b1 @ 0b00001 @ rs1 @ 0b000  @ md @ 0b1011111

function clause execute(LOADXY_MM(rs1, md)) = {
  let load_width_bytes  : int = 4;
  let width_type : word_width = bytes_wordwidth(load_width_bytes);
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);

  assert(1 <= load_width_bytes & load_width_bytes <= 8);
  assert(0 <= num_elem & num_elem <= 32);
  assert (8 * load_width_bytes == 32);

  total : vector(32, dec, bits(32)) = undefined;

  foreach (i from 0 to (num_elem - 1)) {
      let elem_offset = i * load_width_bytes ; // int
      match ext_data_get_addr(rs1, to_bits(sizeof(xlen), elem_offset), Read(Data), width_type) {
        Ext_DataAddr_Error(e)  => { ext_handle_data_check_error(e) ; status = RETIRE_FAIL; print("fail0") },
        Ext_DataAddr_OK(vaddr)  =>
          match translateAddr(vaddr, Read(Data)) {
            TR_Failure(e, _) => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL},
            TR_Address(paddr, _) => {
              match mem_read(Read(Data), paddr, load_width_bytes, false, false, false) {
                MemValue(result) => {
                     total[i] = result;
                  },
                MemException(e) => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL; print("fail3") }
              }
            }
          }
       }
  };
  
  RETIRE_SUCCESS
}

mapping clause assembly = LOADXY_MM(rs1, md)
  <-> "loadxy.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ reg_name(rs1)

/* ******************************************************************* */

union clause ast = LOADZ_MM : (regidx, regidx)

mapping clause encdec = LOADZ_MM(rs1, md)
  <-> 0b000000 @ 0b0 @ 0b00001 @ rs1 @ 0b000  @ md @ 0b1011111

function clause execute(LOADZ_MM(rs1, md)) = {
  let load_width_bytes  : int = 4;
  let width_type : word_width = bytes_wordwidth(load_width_bytes);
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);

  assert(1 <= load_width_bytes & load_width_bytes <= 8);
  assert(0 <= num_elem & num_elem <= 32);
  assert (8 * load_width_bytes == 32);

  total : vector(32, dec, bits(32)) = undefined;

  foreach (i from 0 to (num_elem - 1)) {
      let elem_offset = i * load_width_bytes ; // int
      match ext_data_get_addr(rs1, to_bits(sizeof(xlen), elem_offset), Read(Data), width_type) {
        Ext_DataAddr_Error(e)  => { ext_handle_data_check_error(e) ; status = RETIRE_FAIL; print("fail0") },
        Ext_DataAddr_OK(vaddr)  =>
          match translateAddr(vaddr, Read(Data)) {
            TR_Failure(e, _) => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL},
            TR_Address(paddr, _) => {
              match mem_read(Read(Data), paddr, load_width_bytes, false, false, false) {
                MemValue(result) => {
                     total[i] = result;
                  },
                MemException(e) => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL; print("fail3") }
              }
            }
          }
       }
  };
  
  RETIRE_SUCCESS
}

mapping clause assembly = LOADZ_MM(rs1, md)
  <-> "loadz.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ reg_name(rs1)


/* ******************************************************************* */

union clause ast = STOREXY_MM : (regidx, regidx)

mapping clause encdec = STOREXY_MM(rs1, ms3)
  <-> 0b000000 @ 0b1 @ 0b00010 @ rs1 @ 0b000  @ ms3 @ 0b1011111

function clause execute(STOREXY_MM(rs1, ms3)) = {
  let load_width_bytes  : int = 4;
  let width_type : word_width = bytes_wordwidth(load_width_bytes);
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);
  let ms3_val    : vector(32, dec, bits(16)) = read_mreg(num_elem, ms3);
  status : Retired  = RETIRE_FAIL;


  assert(1 <= load_width_bytes & load_width_bytes <= 8);
  assert(0 <= num_elem & num_elem <= 32);
  assert (8 * load_width_bytes == 16);

  foreach (i from 0 to (num_elem - 1)) {
    let elem_offset = i * load_width_bytes;
    match ext_data_get_addr(rs1, to_bits(sizeof(xlen), elem_offset), Write(Data), width_type) {
      Ext_DataAddr_Error(e)  => { ext_handle_data_check_error(e); status = RETIRE_FAIL },
      Ext_DataAddr_OK(vaddr) =>
        match translateAddr(vaddr, Write(Data)) {
          TR_Failure(e, _)    => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL },
          TR_Address(paddr, _) => {
            let eares : MemoryOpResult(unit) = mem_write_ea(paddr, load_width_bytes, false, false, false);
            match (eares) {
              MemException(e) => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL },
              MemValue(_) => {
                let res : MemoryOpResult(bool) = mem_write_value(paddr, load_width_bytes, ms3_val[i], false, false, false);
                match (res) {
                  MemValue(true)  => status = RETIRE_SUCCESS,
                  MemValue(false) => internal_error("store got false from mem_write_value"),
                  MemException(e) => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL }
                }
              }
            }
          }
      }
    }
  };
  RETIRE_SUCCESS
}

mapping clause assembly = STOREXY_MM(rs1, ms3)
  <-> "storexy.mm" ^ spc() ^ mreg_name(ms3) ^ sep() ^ reg_name(rs1)

/* ******************************************************************* */

union clause ast = STOREZ_MM : (regidx, regidx)

mapping clause encdec = STOREZ_MM(rs1, ms3)
  <-> 0b000000 @ 0b0 @ 0b00010 @ rs1 @ 0b000  @ ms3 @ 0b1011111

function clause execute(STOREZ_MM(rs1, ms3)) = {
  let load_width_bytes  : int = 4;
  let width_type : word_width = bytes_wordwidth(load_width_bytes);
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);
  let ms3_val    : vector(32, dec, bits(16)) = read_mreg(num_elem, ms3);
  status : Retired  = RETIRE_FAIL;


  assert(1 <= load_width_bytes & load_width_bytes <= 8);
  assert(0 <= num_elem & num_elem <= 32);
  assert (8 * load_width_bytes == 16);

  foreach (i from 0 to (num_elem - 1)) {
    let elem_offset = i * load_width_bytes;
    match ext_data_get_addr(rs1, to_bits(sizeof(xlen), elem_offset), Write(Data), width_type) {
      Ext_DataAddr_Error(e)  => { ext_handle_data_check_error(e); status = RETIRE_FAIL },
      Ext_DataAddr_OK(vaddr) =>
        match translateAddr(vaddr, Write(Data)) {
          TR_Failure(e, _)    => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL },
          TR_Address(paddr, _) => {
            let eares : MemoryOpResult(unit) = mem_write_ea(paddr, load_width_bytes, false, false, false);
            match (eares) {
              MemException(e) => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL },
              MemValue(_) => {
                let res : MemoryOpResult(bool) = mem_write_value(paddr, load_width_bytes, ms3_val[i], false, false, false);
                match (res) {
                  MemValue(true)  => status = RETIRE_SUCCESS,
                  MemValue(false) => internal_error("store got false from mem_write_value"),
                  MemException(e) => { handle_mem_exception(vaddr, e); status = RETIRE_FAIL }
                }
              }
            }
          }
      }
    }
  };
  RETIRE_SUCCESS
}

mapping clause assembly = STOREZ_MM(rs1, ms3)
  <-> "storez.mm" ^ spc() ^ mreg_name(ms3) ^ sep() ^ reg_name(rs1)

/* ******************************************************************* */

union clause ast = MVH_MM : (regidx, regidx)

mapping clause encdec = MVH_MM(ms1, md)
  <-> 0b000111 @ 0b0 @ 0b00010 @ ms1 @ 0b011  @ md @ 0b1011111

function clause execute(MVH_MM(ms1, md)) = {
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);

  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem, ms1);
  result      : vector('o, dec, bits('m)) = undefined;

  foreach(i from 0 to (num_elem - 1)) {
    result[i] = ms1_val[i];
  };
  write_mreg('o, md, result);
  RETIRE_SUCCESS
}

mapping clause assembly = MVH_MM(ms1, md)
  <-> "mvh.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms1)

/* ******************************************************************* */

union clause ast = MVV_MM : (regidx, regidx)

mapping clause encdec = MVV_MM(ms1, md)
  <-> 0b000111 @ 0b0 @ 0b00011 @ ms1 @ 0b011  @ md @ 0b1011111

function clause execute(MVV_MM(ms1, md)) = {
  let mbits  : int  = get_vtype_vsew();
  let lmul       : real = get_vtype_LMUL();
  let num_elem   : int  = get_num_elem(lmul, mbits);

  assert(8 <= mbits & mbits <= 64);
  assert(0 <= num_elem & num_elem <= sizeof(vlen));

  let 'n = num_elem;
  let 'm = mbits;
  let 'o = num_elem * num_elem;

  let ms1_val : vector('n, dec, bits('m)) = read_mreg(num_elem,  ms1);
  result      : vector('o, dec, bits('m)) = undefined;
  assert((0 <= num_elem) & (num_elem <= (num_elem * num_elem)));

 foreach(i from 0 to (num_elem - 1)) {
   let next_elem = i * num_elem;
   result[next_elem] = ms1_val[i];
 };

 write_mreg('o, md, result);
 RETIRE_SUCCESS
}

mapping clause assembly = MVV_MM(ms1,  md)
  <-> "mvv.mm" ^ spc() ^ mreg_name(md) ^ sep() ^ mreg_name(ms1)
