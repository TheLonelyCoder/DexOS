# Step 02 — A Small C Runtime for DexOS

## Goal

The purpose of Step 02 is to extend the successful TinyCC experiment from Step 01 into a small, reusable development environment for native DexOS applications written in C.

The C compiler still runs on Linux. The resulting program runs directly under DexOS.

This is not yet a native port of TinyCC.

**Status: Completed and tested under DexOS v6.**

## Development environment

The experiment uses:

- TinyCC 0.9.27 — C compiler
- FASM — assembler
- GNU `ld` — ELF linker
- GNU `objcopy` — conversion to flat binary
- mtools — copying files into a FAT12 floppy image
- QEMU — running DexOS

The development host is Linux Mint.

## Project files

| File | Purpose |
|---|---|
| `tcchello.c` | C test application |
| `dexos.h` | C declarations for the runtime |
| `tccdexstart.asm` | DexOS executable header and C startup |
| `dexruntime.asm` | Assembly wrappers for DexOS services |
| `Dex.inc` | Original DexOS API definitions |
| `dexos.ld` | GNU linker script defining memory layout |
| `build.sh` | Build and floppy-image preparation |

The assembly startup and runtime are deliberately separate.

This allows additional DexOS services to be added without changing the program entry point.

## Build process

The build process is:

```text
tcchello.c
    |
    | TinyCC
    v
tcchello.o

tccdexstart.asm       dexruntime.asm
       |                     |
       | FASM                | FASM
       v                     v
tccdexstart.o          dexruntime.o
       |                     |
       +----------+----------+
                  |
             tcchello.o
                  |
                  | GNU ld + dexos.ld
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

The original floppy image is copied to a temporary test image. The build process does not modify the original image.

The paths in `build.sh` are specific to the local development environment and must be adjusted when building on another system.

## DexOS executable format

The program is linked to the fixed DexOS application load address:

```text
0x01A00000
```

The startup module begins with:

```asm
_start:
    jmp dex_start
    db 'DEX6'
```

The DexOS command-line loader recognizes the `DEX6` signature and transfers control to the application.

The application uses 32-bit protected mode.

Before entering C code, the startup routine initializes the data segment registers:

```asm
mov ax,18h
mov ds,ax
mov es,ax
```

## C startup

The startup routine performs three tasks:

1. Initialize the `.bss` section.
2. Initialize the DexOS runtime interface.
3. Call the C `main()` function.

After `main()` returns, the startup routine returns control to DexOS.

The current implementation does not provide a complete standard C runtime.

## DexOS API wrappers

DexOS exposes operating-system functions through a function table obtained using interrupt `50h`.

The assembly runtime currently provides two functions to C:

```c
void dex_print_string(const char *text);
void dex_wait_for_key(void);
```

`dex_print_string()` translates the normal 32-bit C calling convention into the register-based interface expected by DexOS.

`dex_wait_for_key()` calls the corresponding DexOS keyboard function.

These wrappers allow the C program to use native DexOS services without embedding assembly code in the application itself.

## Memory layout

Step 02 investigates how C program sections are represented in a native DexOS executable.

### `.text`

Contains executable machine code.

### `.rodata`

Contains read-only program data, when emitted by the compiler.

### `.data`

Contains initialized static data.

For example:

```c
char second_greeting[] = "Hellorld from .data!\r\n";
```

The initialized string is included in the generated `.DEX` file and can be printed successfully under DexOS.

### `.bss`

Contains uninitialized static storage, including global and `static` variables without explicit initializers.

For example:

```c
char bss_buffer[80];
```

According to the C language rules, this storage must contain zero values when the C program begins.

Unlike `.data`, `.bss` does not need to occupy space in the executable file.

## Why `.bss` initialization is necessary

The DexOS command-line loader reads the flat `.DEX` executable into memory.

It does not receive the ELF section metadata or the `.bss` size.

Therefore, the C startup code must initialize `.bss` explicitly.

The GNU linker script provides two symbols:

```text
__bss_start
__bss_end
```

The startup routine uses them to determine the size of the section:

```asm
mov edi,__bss_start
mov ecx,__bss_end
sub ecx,edi

xor eax,eax
cld
rep stosb
```

This fills the complete `.bss` section with zero bytes before `main()` is called.

## Testing `.bss` initialization

A test that merely finds zero values in memory is insufficient to prove that the startup routine initialized them.

The memory might already have contained zeros.

To test the actual initialization mechanism, the startup routine was temporarily modified to fill `.bss` with the pattern:

```text
0xA5 = 10100101
```

The C program then checked whether the expected pattern was present throughout an 80-byte global buffer.

The test succeeded.

An important C detail was encountered: plain `char` may be signed.

The correct comparison therefore uses:

```c
if ((unsigned char)bss_buffer[i] != 0xA5)
{
    /* Pattern mismatch */
}
```

Without the cast, the value `0xA5` may be interpreted as `-91` when read through a signed `char`.

The experiment demonstrated that the startup routine writes the expected pattern into `.bss`.

The temporary initialization value was then changed back to zero, as required by C.

Both stages were preserved in the Git history.

## Switching to GNU ld

Step 01 used TinyCC for both compilation and linking.

Step 02 introduces GNU `ld` and a custom linker script, `dexos.ld`.

The linker script defines the memory layout and the `.bss` boundary symbols.

It also produces a more compact executable by avoiding the larger alignment gaps observed with the original TinyCC linking process.

The generated program was successfully executed under DexOS.

GNU `ld` currently emits a warning about an ELF LOAD segment with read, write and execute permissions.

This warning is known and does not prevent execution in the current DexOS environment.

## Successful runtime tests

The following functionality has been tested under DexOS v6:

- Execution of TinyCC-generated C code
- Calls from C into the assembly runtime
- Native DexOS console output
- Waiting for keyboard input
- Initialized global data
- Reading and writing global `.bss` storage
- Filling `.bss` with a diagnostic pattern
- Returning from `main()` to the DexOS command line
- Linking with GNU `ld`

The application returns `42` from `main()`. The current startup does not pass that value to an operating-system process exit interface.

## Limitations

Step 02 is a minimal freestanding C environment, not a complete C library.

It does not yet provide:

- Standard C file I/O
- Dynamic memory allocation
- Standard library functions such as `printf()` or `malloc()`
- A complete implementation of C runtime initialization
- A native TinyCC compiler running under DexOS

Memory management and additional DexOS services will require further experiments.

## Result

Step 02 establishes a small working C runtime for native DexOS applications.

The development chain is now:

```text
C source
   |
   v
TinyCC on Linux
   |
   v
FASM + GNU ld
   |
   v
Native DexOS executable
   |
   v
DexOS v6
```

This provides a foundation for the next major experiment: investigating what is required to build TinyCC itself as a native DexOS application.

**Hellorld!**