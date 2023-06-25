RGen RISCV Sail Model
================

This repository contains an extension of the RISC-V Sail Model <https://github.com/riscv/sail-riscv>, to be used in conjunction with the extended Sail repository <https://github.com/derekztu22/sail/tree/rgen>.

Getting started
---------------

### Building the model
<p>This tutorial will be based on the matrix extesnion (MM) that RGen uses.</p>

Install [Sail](https://github.com/derekztu22/sail/tree/rgen) [using opam](https://github.com/rems-project/sail/blob/sail2/INSTALL.md) then:

#### LLVM Generation

```
$ make ARCH=RV64 generated_definitions/llvm/llvm.td
```

Within the generated_definitions/llvm folder will be all the files with generated code that need to be added to the LLVM RISC-V backend. Currently this repository uses an older [commit](https://github.com/llvm/llvm-project/commits/6f46ff3765dcdc178b9cf52ebd8c03437806798a) for LLVM.

<p>
Each file is already named to guide the user to which corresponding LLVM file the generated contents should be added to. This does not include RISCVInstrFormats_EXT_.td, RISCVInstrInfo_EXT_.d, and RISCVSchedule_EXT_.td as they can be directly copied over the the RISC-V target backend. The following list details how to add each of the generated contents to their respective files:
  
- **RISCVDisassembler.cpp**: This is generated because the matrix extension adds new registers. Add the generated code to line 174 in the corresponding LLVM file.
- **RISCVRegisterInfo.td**: This is generated because the matrix extension adds new registesr. Add the generated code to line 547 in the corresponding LLVM file.
- **RISCVInstrInfo.td**: Add the generated code to the end of the corresponding LLVM file.
- **RISCVSchedRocket.td/RISCVSchedSiFive7.td**: Add the first generated line of code to the UnsupportedFeatures list in the corresponding LLVM file. Add the second generated line of code with the rest of the unsupported extensions near the end of the corresponding LLVM file.
- **RISCVSchedule.td**: Add the generated code to the end of the corresponding LLVM file.
- **RISCVSubtarget.h**: Add the first line of generated code to line 60 and the second line of generated code to line 158 in the corresponding LLVM file.
- **RISCV.td**: Add the generated code to line 406 in the corresponding LLVM file.
</p>

<p>
Once the all the code has been added, LLVM can be built. These are some sample commands that can be used:
</p>

```
$ cd $LLVM_SOURCE
$ mkdir build && cd build
$ cmake -G Ninja -DCMAKE_BUILD_TYPE="Release"   -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True   -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False -DLLVM_ENABLE_PROJECTS="clang"   -DLLVM_TARGETS_TO_BUILD="RISCV"   ../llvm
$ cmake --build .
```

#### QEMU Generation

```
$ make ARCH=RV64 generated_definitions/qemu/qemu.td
```

This work uses [QEMU7.2.0](https://www.qemu.org/download/), and all the built files will be put into the _riscv_ folder.

The following list describes how each generated file is added to QEMU7.2.0:
- **helper.h**: Add the generated code to line 233 in _helper.h_ in the _riscv_ folder.
- **insn32.decode**: Add the generated code to the end of _insn32.decode_ in the _riscv_ folder.
- **matrix_helper.c**: Add the file to the _riscv_ folder. Additionally, in _meson.build_, add _'matrix.helper.c'_ to line 18.
- **trans_rvmm.c.inc**: Add the file to the _riscv/insn\_trans_ folder. Additionally, in _translate.c_ add _#include "insn\_trans/trans\_rvmm.c.inc"_ to line 1037.

Additionally, for the matrix extension, new registers are added so in the _cpu.h_ file we add:

```
uint32_t mregxy[64] QEMU_ALIGNED(16);
uint32_t mregz[32*32] QEMU_ALIGNED(16);
```
to the CPUArchState struct (lines 150 and 151).

Once the generated code is added QEMU can be built. Here are some sample commands:

```
$ cd $QEMU_ORIGIN
$ mkdir build
$ cd build
$  ../configure --enable-slirp --target-list=riscv64-linux-user,riscv64-softmmu
$ make
```

#### PyTorch Generation

```
$ make ARCH=RV64 generated_definitions/pytorch/pytorch.td
```
<p>TODO</p>

#### Bringing it all together

<p>TODO</p>

Licence
-------

The model is made available under the BSD two-clause licence in LICENCE.

Original Authors
-------

 Prashanth Mundkur, SRI International;
 Rishiyur S. Nikhil (Bluespec Inc.); 
 Jon French, University of Cambridge;
 Brian Campbell, University of Edinburgh;
 Robert Norton-Wright, University of Cambridge and Microsoft;
 Alasdair Armstrong, University of Cambridge;
 Thomas Bauereiss, University of Cambridge;
 Shaked Flur, University of Cambridge;
 Christopher Pulte, University of Cambridge;
 Peter Sewell, University of Cambridge;
 Alexander Richardson, University of Cambridge;
 Hesham Almatary, University of Cambridge;
 Jessica Clarke, University of Cambridge;
 Nathaniel Wesley Filardo, Microsoft;
 Peter Rugg, University of Cambridge;
 Scott Johnson, Aril Computer Corp.
