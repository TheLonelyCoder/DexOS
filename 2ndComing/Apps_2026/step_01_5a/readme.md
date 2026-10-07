# Step 01.5a – Open Watcom 16-bit MZ without DOS

## Goal

This experiment investigates whether a 16-bit MZ executable produced with a
current Open Watcom C compiler can be loaded directly by the BootProg loader
used with DexOS, without DOS and without the Open Watcom DOS runtime.

The intended execution chain is:

    BIOS
      |
      v
    BootProg boot sector
      |
      v
    KERNEL32.EXE (16-bit MZ)
      |
      v
    custom startup code
      |
      v
    C code / BIOS services

This is deliberately a small experiment.

The goal is not to build a complete C runtime, but to find out how much of the
Open Watcom toolchain can be used in a DOS-less 16-bit environment.


## Environment

The experiment was performed with:

    Open Watcom C x86 16-bit Optimizing Compiler
    Version 2.0 beta Sep 28 2026

    Open Watcom Linker
    Version 2.0 beta Sep 28 2026

Host system:

    Linux x86-64

Target:

    16-bit x86 real mode
    MZ executable
    BootProg boot loader
    BIOS services
    no DOS


## Starting point

BootProg is a FAT12 boot loader capable of loading a COM or MZ executable from
the root directory of a floppy disk.

The DexOS boot image contains a BootProg-based boot sector configured to load:

    KERNEL32.EXE

For this experiment the original KERNEL32.EXE is replaced with an executable
built using Open Watcom.


## First attempt

A normal Open Watcom DOS executable was created with the C compiler and the
standard DOS startup code.

The result was a valid MZ executable, but it could not run without DOS.

Disassembly showed that the Open Watcom startup code performed DOS services
before entering main(), for example:

    mov ah,4Ah
    int 21h

INT 21h requires DOS.

BootProg loads the executable directly after the BIOS boot process, so no DOS
kernel exists to service these calls.

Therefore the normal Open Watcom DOS startup code cannot be used.


## Removing the Open Watcom DOS runtime

The next step was to use a custom assembler startup and link the program
without the normal Watcom runtime.

The C source is compiled approximately as follows:

    wcc \
        -0 \
        -ms \
        -s \
        -zls \
        hellowat.c

Important options are:

    -0      generate 8086 instructions
    -ms     small memory model
    -s      remove stack overflow checks
    -zls    remove automatically inserted symbols

Without `-s`, the compiler generated a reference to:

    __STK

Without `-zls`, the object contained references such as:

    _cstart_
    _small_code_

These belong to the normal Open Watcom runtime environment and are not wanted
for this experiment.


## Linking an MZ without the DOS startup environment

Using:

    system dos

was not appropriate for the final freestanding link because it describes the
normal Open Watcom DOS environment.

Instead, WLINK is asked only to produce the DOS executable file format:

    format dos

The executable is linked from our own objects, approximately:

    wlink \
        format dos \
        option nodefaultlibs \
        option start=_start \
        name kernel32.exe \
        file start.o \
        file int86.o \
        file hellowat.o

This still produces a normal MZ executable, but without linking the standard
DOS runtime.


## Custom startup

The program provides its own entry point.

Conceptually:

    _start:
        initialize DS
        initialize ES
        call main_
        loop forever

The startup initializes DS and ES from DGROUP before calling C code.

This is necessary because the C compiler expects its data to be reachable
through the data segment.


## Stack

Initially the generated MZ header contained:

    SS = 0000
    SP = 0000

WLINK also reported:

    Warning! W1014: stack segment not found

Adding only a linker stack size option was not sufficient for this experiment.

A real stack segment was therefore added to the assembler startup:

    STACKSEG SEGMENT PARA STACK 'STACK'
        db 512 dup (?)
    STACKSEG ENDS

After linking, the MZ header contained:

    SS = 0008
    SP = 0200

The executable itself remained very small.

This is expected: the 512-byte stack does not have to occupy 512 bytes in the
executable file. The MZ header describes the additional memory required when
the program is loaded.


## Resulting executable

At one point the resulting executable was only:

    162 bytes

and was still recognized as:

    MS-DOS executable, MZ for MS-DOS

The small size is intentional.

The normal Open Watcom DOS startup, DOS error handling and runtime support have
been removed. The executable contains essentially only:

- the MZ header and relocation information
- the custom startup code
- the small C program
- the minimal BIOS interface code
- constant data


## First successful execution

To determine whether BootProg actually reached our MZ entry point, a diagnostic
BIOS call was placed directly at `_start`:

    mov ah,0Eh
    mov al,'X'
    mov bh,00h
    mov bl,07h
    int 10h

The machine displayed:

    X

This proves that:

1. BootProg finds KERNEL32.EXE.
2. BootProg accepts the Open Watcom generated MZ executable.
3. The executable is loaded.
4. The MZ entry point is reached.
5. BIOS services can be called directly from the loaded program.


## DGROUP test

A second diagnostic character was emitted after initializing DGROUP:

    mov ax,DGROUP
    mov ds,ax
    mov es,ax

The resulting output was:

    XY

This demonstrates that execution continues after the DGROUP setup.

For the scope of this experiment it also provides evidence that the relevant
MZ relocation/startup mechanism is working sufficiently for the custom startup
code.


## Open Watcom calling convention

Another useful result of the experiment was discovering how the compiler calls
the replacement `int86()` function.

The generated code contained approximately:

    lea bx,registers
    lea dx,registers
    mov ax,0010h
    call int86_

Open Watcom uses its `__watcall` register calling convention by default.

Our original assembler implementation incorrectly expected conventional
stack-based arguments.

The initial implementation therefore used code equivalent to:

    mov si,[bp+6]

which was incorrect for the generated call.

For the observed call, arguments are passed in registers, with the interrupt
number in AX and the REGS pointers passed in registers.

A minimal replacement implementation is currently being investigated.

This part of the experiment is not yet complete.


## What has been proven

The experiment has demonstrated that a current Open Watcom toolchain can be
used to produce a small 16-bit MZ executable which is loaded and executed by
the BootProg loader without DOS.

In particular:

    Open Watcom 2026
            |
            v
       16-bit objects
            |
            v
       custom startup
            |
            v
       WLINK MZ file
            |
            v
       BootProg loader
            |
            v
       BIOS / real mode

The program does not require the Open Watcom DOS startup code to reach and
execute custom machine code.


## What has NOT yet been proven

The complete C example is not yet working.

In particular, the following path is still under investigation:

    main()
      |
      v
    bios_putchar()
      |
      v
    replacement int86()
      |
      v
    BIOS INT 10h

The current visible `XY` output consists of diagnostic markers emitted directly
by the custom assembler startup.

Therefore this experiment should not yet be described as a complete Open
Watcom C runtime for DexOS.

It is a proof that Open Watcom can generate suitable 16-bit code and that an
MZ executable built with a custom startup can be loaded and entered without
DOS.


## Why this matters

The important result is not the two characters `XY`.

The important result is that Open Watcom does not have to be treated merely as
a compiler for programs running under DOS.

Its 16-bit C compiler and linker can be used while replacing the operating
environment underneath the generated code.

That opens the possibility of providing a small custom runtime for another
16-bit environment such as DexOS:

    C source
       |
       v
    Open Watcom compiler
       |
       v
    custom runtime / system interface
       |
       v
    DexOS

The next step is to complete the minimal C-to-BIOS path and eventually replace
the BIOS test interface with native DexOS services.


## Status

Current status:

    [x] Open Watcom produces 16-bit code
    [x] custom startup code
    [x] no Open Watcom DOS runtime
    [x] valid MZ executable
    [x] BootProg loads the executable
    [x] custom MZ entry point executes
    [x] stack described correctly by the MZ executable
    [x] direct BIOS INT 10h output works
    [x] DGROUP setup survives execution
    [ ] complete minimal int86() replacement
    [ ] "Hellorld!" from C
    [ ] native DexOS C runtime interface


## The current milestone

For now, the smallest visible proof of life is:

    XY

Two characters are not much.

But quite a few things have to work correctly before those two characters can
appear.