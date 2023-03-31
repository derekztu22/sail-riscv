/* matrix registers */
register mr0 : mregtype
register mr1 : mregtype
register mr2 : mregtype
register mr3 : mregtype
register mr4 : mregtype
register mr5 : mregtype
register mr6 : mregtype
register mr7 : mregtype
register mr8 : mregtype
register mr9 : mregtype
register mr10 : mregtype
register mr11 : mregtype
register mr12 : mregtype
register mr13 : mregtype
register mr14 : mregtype
register mr15 : mregtype
register mr16 : mregtype
register mr17 : mregtype
register mr18 : mregtype
register mr19 : mregtype
register mr20 : mregtype
register mr21 : mregtype
register mr22 : mregtype
register mr23 : mregtype
register mr24 : mregtype
register mr25 : mregtype
register mr26 : mregtype
register mr27 : mregtype
register mr28 : mregtype
register mr29 : mregtype
register mr30 : mregtype
register mr31 : mregtype

val mreg_name : bits(5) <-> string
mapping mreg_name = {
    0b00000 <-> "m0",
    0b00001 <-> "m1",
    0b00010 <-> "m2",
    0b00011 <-> "m3",
    0b00100 <-> "m4",
    0b00101 <-> "m5",
    0b00110 <-> "m6",
    0b00111 <-> "m7",
    0b01000 <-> "m8",
    0b01001 <-> "m9",
    0b01010 <-> "m10",
    0b01011 <-> "m11",
    0b01100 <-> "m12",
    0b01101 <-> "m13",
    0b01110 <-> "m14",
    0b01111 <-> "m15",
    0b10000 <-> "m16",
    0b10001 <-> "m17",
    0b10010 <-> "m18",
    0b10011 <-> "m19",
    0b10100 <-> "m20",
    0b10101 <-> "m21",
    0b10110 <-> "m22",
    0b10111 <-> "m23",
    0b11000 <-> "m24",
    0b11001 <-> "m25",
    0b11010 <-> "m26",
    0b11011 <-> "m27",
    0b11100 <-> "m28",
    0b11101 <-> "m29",
    0b11110 <-> "m30",
    0b11111 <-> "m31"
}

val mreg_id : string <-> bits(5)
mapping mreg_id = {
    "m0"	<->  0b00000,
    "m1"	<->  0b00001,
    "m2"	<->  0b00010,
    "m3"	<->  0b00011,
    "m4"	<->  0b00100,
    "m5"	<->  0b00101,
    "m6"	<->  0b00110,
    "m7"	<->  0b00111,
    "m8"	<->  0b01000,
    "m9"	<->  0b01001,
    "m10"	<->  0b01010,
    "m11"	<->  0b01011,
    "m12"	<->  0b01100,
    "m13"	<->  0b01101,
    "m14"	<->  0b01110,
    "m15"	<->  0b01111,
    "m16"	<->  0b10000,
    "m17"	<->  0b10001,
    "m18"	<->  0b10010,
    "m19"	<->  0b10011,
    "m20"	<->  0b10100,
    "m21"	<->  0b10101,
    "m22"	<->  0b10110,
    "m23"	<->  0b10111,
    "m24"	<->  0b11000,
    "m25"	<->  0b11001,
    "m26"	<->  0b11010,
    "m27"	<->  0b11011,
    "m28"	<->  0b11100,
    "m29"	<->  0b11101,
    "m30"	<->  0b11110,
    "m31"	<->  0b11111 	
}

/* **************************************************************** */
/* Matrix CSR                                               */   

bitfield Mcsr : bits(3) = {
  mxrm : 2 .. 1,
  mxsat     : 0
}
register mcsr : Mcsr

val ext_write_mcsr : (bits(2), bits(1)) -> unit effect {rreg, wreg}
function ext_write_mcsr (mxrm_val, mxsat_val) = {
  mcsr->mxrm()    = mxrm_val;      /* Note: frm can be an illegal value, 101, 110, 111 */
  mcsr->mxsat() = mxsat_val;
}

val write_mreg : forall 'n 'm, 8 <= 'm <= 64. (int, regidx, vector('n, dec, bits('m))) -> unit
function write_mreg(num_elem, mrid, vec) = {
  let a : int = 1;
}

val read_mreg : forall 'n 'm, 8 <= 'm <= 64. (int, regidx) -> vector('n, dec, bits('m))
function read_mreg(num_elem, mrid) = {
  var result : vector('n, dec, bits('m)) = undefined;
  result 
}
