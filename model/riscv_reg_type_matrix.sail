type mreglen             : Int=mlen /*type mlen       : Int = 128 256 OR 512 bits*/
type mreglenbits         = bits(mreglen)/*Each mector register has a fixed MLEN bits of state*/

type mregtype            = mreglenbits

val MRegStr : mregtype -> string
function MRegStr(r) = BitStr(r)
