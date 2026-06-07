/* Freestanding i686 kernel link script for LiOS M1 hello_kern (multiboot1). */
OUTPUT_FORMAT(elf32-i386)
OUTPUT_ARCH(i386)
ENTRY(_start)

PHDRS
{
  mbpt PT_LOAD FLAGS(7);
}

SECTIONS
{
  . = 0x100000;
  .multiboot : {
    LONG(0x1BADB002)
    LONG(0)
    LONG(0xE4514FFE)
  }
  .text : {
    KEEP(*(.text._start))
    *(.text*)
  }
  .rodata : { *(.rodata*) }
  .data : { *(.data*) }
  .bss : {
    __bss_start = .;
    *(.bss*) *(COMMON)
    __bss_end = .;
  }
  . = ALIGN(16);
  . += 0x4000;
  __stack_top = .;
  /DISCARD/ : {
    *(.eh_frame)
    *(.comment)
    *(.note*)
  }
}
