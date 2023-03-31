#!/bin/bash

function test_build () {
    declare -i rc=0
    eval $*
    rc=$?
    if [ $rc -ne 0 ]; then
        echo "Failure to execute: $*"
        exit $rc
    fi
}

#test_build make ARCH=RV32 ocaml_emulator/riscv_ocaml_sim_RV32 -j24 
#test_build make ARCH=RV64 ocaml_emulator/riscv_ocaml_sim_RV64 -j24
#
#test_build make ARCH=RV32 c_emulator/riscv_sim_RV32 -j24
#test_build make ARCH=RV64 c_emulator/riscv_sim_RV64 -j24


#rm -rf generated_definitions/pytorch
#make generated_definitions/pytorch/pytorch.td -j24

#rm -rf generated_definitions/llvm
#make ARCH=RV64 generated_definitions/llvm/llvm.td -j24

rm -rf generated_definitions/qemu
make ARCH=RV64 generated_definitions/qemu/qemu.td -j24
