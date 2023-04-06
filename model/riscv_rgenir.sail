enum Retired = {DEF_END, RETIRE_FAIL}
val rgenir_def : string -> Retired

rgenir clause rgenir_def = Sail_MACCOMMOp <"maccomm", [DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>, NoSideEffect]> {
  summary : string = "Matrix multiply then add operator";
  description : string = "Matrix multiply of input1 and input2 then add to input3.";
  input1 : Tensor(real) = undefined; 
  input2 : Tensor(real) = undefined; 
  input3 : Tensor(real) = undefined; 
  execute_mm : string = "int32_t @ input1 * input2 + input3";
  output : Tensor(real) = undefined;
  DEF_END;
}

rgenir clause rgenir_def = Sail_MACCPMMOp <"maccpmm", [DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>, NoSideEffect]> {
  summary : string = "Pointwise multiply then add operator";
  description : string = "Pointwise multiply of input1 and input2 then add to input3.";
  input1 : Tensor(real) = undefined; 
  input2 : Tensor(real) = undefined; 
  input3 : Tensor(real) = undefined; 
  execute_mm : string = "int32_t @ input1 * input2 + input3";
  output : Tensor(real) = undefined;
  DEF_END;
}

rgenir clause rgenir_def = Sail_FMACC64OMMOp <"fmacc64omm", [DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>, NoSideEffect]> {
  summary : string = "64-bit matrix multiply then add operator";
  description : string = "Matrix multiply of input1 and input2 then add to input3, bit-length 64, element length 8";
  input1 : Tensor(real) = undefined; 
  input2 : Tensor(real) = undefined; 
  input3 : Tensor(real) = undefined; 
  execute_mm : string = "float @ input1 * input2 + input3";
  output : Tensor(real) = undefined;
  DEF_END;
}

rgenir clause rgenir_def = Sail_FMACC32OMMOp <"fmacc32omm", [DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>, NoSideEffect]> {
  summary : string = "32-bit matrix multiply then add operator";
  description : string = "Matrix multiply of input1 and input2 then add to input3, bit-length 32, element length 16";
  input1 : Tensor(real) = undefined; 
  input2 : Tensor(real) = undefined; 
  input3 : Tensor(real) = undefined; 
  execute_mm : string = "float @ input1 * input2 + input3";
  output : Tensor(real) = undefined;
  DEF_END;
}

rgenir clause rgenir_def = Sail_FMACC16OMMOp <"fmacc16omm", [DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>, NoSideEffect]> {
  summary : string = "16-bit matrix multiply then add operator";
  description : string = "Matrix multiply of input1 and input2 then add to input3, bit-length 16, element length 32";
  input1 : Tensor(real) = undefined; 
  input2 : Tensor(real) = undefined; 
  input3 : Tensor(real) = undefined; 
  execute_mm : string = "float @ input1 * input2 + input3";
  output : Tensor(real) = undefined;
  DEF_END;
}

rgenir clause rgenir_def = Sail_MVVMMOp <"mvvmm", [DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>, NoSideEffect]> {
  summary : string = "Matrix move vector vertically";
  description : string = "Matrix move input1 to output vertically.";
  input1 : Tensor(real) = undefined; 
  input2 : Tensor(real) = undefined; 
  execute_mm : string = "int32_t @ vertical(input1 -> input2)";
  output : Tensor(real) = undefined;
  DEF_END;
}

rgenir clause rgenir_def = Sail_MVHMMOp <"mvhmm", [DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>, NoSideEffect]> {
  summary : string = "Matrix move vector horizontally";
  description : string = "Matrix move input1 to output horizontally.";
  input1 : Tensor(real) = undefined; 
  input2 : Tensor(real) = undefined; 
  execute_mm : string = "int32_t @ horizontal(input1 -> input2";
  output : Tensor(real) = undefined;
  DEF_END;
}
