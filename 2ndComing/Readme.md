# DexOS: The Second Coming

This directory contains experiments for rebuilding, understanding and extending the original DexOS v6 system using development tools available on modern Linux systems.

The original DexOS sources are intentionally left untouched. New experiments are maintained in separate directories so that working intermediate stages remain available for reference.

## Development environment

The experiments are performed primarily on Linux Mint, using tools such as:

- FASM (Flat Assembler)
- TinyCC (TCC)
- GNU Binutils (`ld`, `objcopy`, `objdump`)
- Open Watcom
- mtools
- QEMU

Not every experiment uses all of these tools.

## Experiments

### Experiment 000 — Rebuilding Hello.dex

Directory: `Apps_2026/Hello_c`

The original `Apps_2012/Hello_c/Hello.asm` is assembled with FASM on Linux and compared byte-for-byte with the original `Hello.dex`.

**Status: Completed.**

This establishes that the original binary can be reproduced with the modern development environment.

### Experiment 001 — TinyCC-generated C code under DexOS

Directory: `Apps_2026/Hello_tcc`

A small C program is compiled with TinyCC on Linux, combined with an FASM startup module, converted into a native `.DEX` executable and run under DexOS.

The program prints the intentionally misspelled greeting:

`Hellorld!`

**Status: Completed.**

TinyCC itself still runs on Linux. This experiment does not constitute a native TinyCC port.

See `Apps_2026/Hello_tcc/readme.1st.md` for details.

### Experiment 01.5a — Open Watcom and a 16-bit MZ executable

Directory: `Apps_2026/step_01_5a`

This separate experiment investigates building a freestanding 16-bit MZ executable with Open Watcom and loading it through the original BootProg boot loader, without DOS.

A custom entry point and direct BIOS output have been demonstrated. The complete C-to-BIOS interface remains unfinished.

**Status: Partially completed.**

See `Apps_2026/step_01_5a/readme.md` for details.

### Experiment 002 — A small C runtime for DexOS

Directory: `Apps_2026/step_02`

The TinyCC experiment is extended with a separate startup module, a small assembly runtime and a C header.

The runtime currently provides:

- Native DexOS text output
- Keyboard input
- Support for initialized static data (`.data`)
- Explicit initialization of uninitialized static storage (`.bss`)
- Linking through GNU `ld` with a custom linker script

The `.bss` initialization was tested using a temporary `0xA5` memory pattern before restoring the C-required zero initialization.

The resulting executable runs successfully under DexOS and returns to its command-line interface.

**Status: Functionality tested; final integration and documentation in progress.**

See `Apps_2026/step_02/README.md` for technical details once that document is added.

## Long-term goal

The long-term goal is to investigate whether TinyCC can eventually run natively under DexOS.

The intended progression is:

1. Compile C code on Linux and execute it under DexOS. **Completed**
2. Establish a small reusable C/DexOS runtime. **In progress**
3. Build TinyCC itself as a DexOS executable.
4. Run TinyCC under DexOS.
5. Compile C source code using TinyCC running under DexOS.
6. Execute the resulting program under DexOS.
7. Compile TinyCC using TinyCC running under DexOS (self-hosting).

These are experimental milestones, not promises of compatibility or completion.

## Project principles

- Preserve the original DexOS sources and licensing information.
- Keep new work separate from the original 2012 code.
- Prefer small, understandable experiments.
- Preserve working intermediate stages.
- Document both successful results and limitations.

The objective is not merely to make old software run, but to understand how it works.

And occasionally:

**Hellorld!**