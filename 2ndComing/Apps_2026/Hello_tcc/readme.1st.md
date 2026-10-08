# TinyCC / DexOS Experiment

This directory contains an experiment to generate native DexOS applications
from C code using TinyCC on Linux.

The long-term goal is to investigate whether TinyCC can eventually be ported
to DexOS and, ultimately, become self-hosting.

For now, the much smaller first milestone has been reached:

> C code compiled with TinyCC on Linux can be linked with a small DexOS
> startup module, converted to a native `.DEX` flat binary and executed
> successfully under DexOS.

The first visible C program prints:

```text
Hellorld!
Greetings to Usagi Electric.
```

`Hellorld!` is intentional and is a small tribute to Usagi Electric.

## Development stages

`Hello_tcc` represents **Step 01** of the TinyCC/DexOS experiment:

1. Build and run a TCC-generated C program under DexOS. **DONE**
2. Build a small reusable C/DexOS development environment.
3. Build TinyCC itself as a DexOS executable.
4. Run TCC natively under DexOS.
5. Compile a C program using TCC running under DexOS.
6. Run the resulting program under DexOS.
7. Compile TinyCC with TinyCC running under DexOS (self-hosting).

## Current state 'Hello_tcc / Step 01': **DONE**

The current tool chain is:

```text
tcchello.c
    |
    | TinyCC - compile
    v
tcchello.o
    |
    |                         tccdexstart.asm
    |                              |
    |                              | FASM
    |                              v
    |                         tccdexstart.o
    |                              |
    +---------------+--------------+
                    |
                    | TinyCC - link
                    v
                hellotcc.elf
                    |
                    | objcopy -O binary
                    v
                hellotcc.dex
                    |
                    | mcopy
                    v
              DexOS FAT12 image
                    |
                    | QEMU
                    v
                  DexOS
```

Both intermediate object files are normal 32-bit ELF relocatable objects.
TinyCC is then used to link them at the DexOS application load address.

The resulting ELF file is only an intermediate format. `objcopy` converts
the loadable contents into the flat binary expected by DexOS.

## DexOS startup

DexOS applications are loaded at:

```text
0x01A00000
```

The startup module begins with the native DexOS signature convention:

```asm
jmp dex_start
db 'DEX6'
```

It then initializes the segment registers and obtains the DexOS function
table using interrupt `50h`.

The original DexOS `Dex.inc` is used for the function table definitions.

`tccdexstart.asm` also provides the first small bridge between the C calling
convention and the DexOS API.

For example, C calls:

```c
dex_print_string("Hellorld!\r\n");
```

using the normal 32-bit C calling convention. The assembly wrapper retrieves
the string pointer from the stack, places it in `ESI` as expected by DexOS,
and calls `PrintString_0` from the DexOS function table.

This is currently the beginning of a very small DexOS C runtime rather than
a complete C library.

## An important detail: `.text` is not enough

The first experiments extracted only the ELF `.text` section:

```bash
objcopy -O binary --only-section=.text ...
```

This worked while the C program contained only executable code.

As soon as the program contained:

```c
"Hellorld!\r\n"
```

TinyCC placed the string in the ELF `.data` section. Extracting only `.text`
therefore produced a valid-looking DexOS program without the data referenced
by the C code.

The current build consequently uses:

```bash
objcopy -O binary hellotcc.elf hellotcc.dex
```

so that the required loadable sections and their address layout are retained
in the flat binary.

## Build scripts

`build.sh` and `build2.sh` document the experimental steps used while
developing this proof of concept.

**Important:** these scripts currently contain paths from my local development
environment, including the location of the original DexOS floppy image.

They are therefore **not portable as-is**.

Before using them on another system, adjust the paths near the beginning of
the scripts to match your own directory layout.

My development tree currently uses locations such as:

```text
/RicksCafe/Git.Projects/DexOS/
~/VMs/images/dexos/
```

The scripts create a temporary copy of the original DexOS FAT12 floppy image
and use `mcopy` to place `HELLOTCC.DEX` into that image.

The original image is not modified.

## Tools currently used

The experiment currently uses:

- TinyCC (`tcc`)
- Flat Assembler (`fasm`)
- GNU `objcopy`
- GNU `objdump`
- `mtools`
- QEMU
- the original DexOS sources and `Dex.inc`

Development and compilation currently take place on Linux.

## What has been proven

At this point the experiment has demonstrated that:

1. TinyCC can generate 32-bit i386 code suitable for this experiment.
2. FASM and TinyCC generated ELF objects can be linked together.
3. The resulting program can be linked for the DexOS load address.
4. The ELF program can be converted into a DexOS-style flat binary.
5. DexOS accepts and executes that binary.
6. A TinyCC-generated C `main()` can be called and can return cleanly to DexOS.
7. C code can call a small assembly wrapper which in turn calls a native
   DexOS API function.
8. Static C data can be included in the generated flat binary.
9. The resulting C program can print text and return to the DexOS console.

This does **not** yet mean that TinyCC itself has been ported to DexOS.

The compiler still runs on Linux. At present, Linux/TinyCC is a
cross-development environment producing programs for DexOS.

## Possible next steps

The next experiments will probably involve extending the small runtime with
additional DexOS services, understanding data/BSS and memory handling more
completely, and determining what TinyCC itself would require in order to run
under DexOS.

The eventual and deliberately ambitious experiment would be:

```text
Linux TCC
    -> build TCC.DEX
        -> run TCC.DEX under DexOS
            -> compile C under DexOS
                -> compile TinyCC itself
```

If that works, DexOS would have a self-hosting C compiler.

For today, however:

```text
Hellorld!
```

is enough.