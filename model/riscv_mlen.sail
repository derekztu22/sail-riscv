/* Define the MLEN value for the architecture. */

type mlen       : Int = 128 /*256 OR 512 bits*/
type mlen_bytes : Int = 16 /*32 or 64 bytes*/
type mstart_int     : Int = 8 /*2**8=256(mlen bits) 0~255*/      
type mstartbits = bits(mstart_int)
