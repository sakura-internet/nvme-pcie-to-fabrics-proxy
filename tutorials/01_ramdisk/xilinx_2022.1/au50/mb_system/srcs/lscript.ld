/*******************************************************************/
/*                                                                 */
/* This file is automatically generated by linker script generator.*/
/*                                                                 */
/* Version: 2018.3                                                 */
/*                                                                 */
/* Copyright (c) 2010-2019 Xilinx, Inc.  All rights reserved.      */
/*                                                                 */
/* Description : MicroBlaze Linker Script                           */
/*                                                                 */
/*******************************************************************/

_STACK_SIZE = DEFINED(_STACK_SIZE) ? _STACK_SIZE : 0x400;
_HEAP_SIZE = DEFINED(_HEAP_SIZE) ? _HEAP_SIZE : 0x800;

/* Define Memories in the system */

MEMORY
{
   embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem : ORIGIN = 0x50, LENGTH = 0x1FFB0
   pcie_xdma_baseaddr_CTL0 : ORIGIN = 0x400000000, LENGTH = 0x100000000
   pcie_xdma_axibar_0_BAR0 : ORIGIN = 0x1000000000000, LENGTH = 0x1000000000000
   dram : ORIGIN = 0xa8000000, LENGTH = 0x08000000
}

/* Specify the default entry point to the program */

ENTRY(_start)

/* Define the sections, and where they are mapped in memory */

SECTIONS
{
.vectors.reset 0x0 : {
   KEEP (*(.vectors.reset))
} 

.vectors.sw_exception 0x8 : {
   KEEP (*(.vectors.sw_exception))
} 

.vectors.interrupt 0x10 : {
   KEEP (*(.vectors.interrupt))
} 

.vectors.hw_exception 0x20 : {
   KEEP (*(.vectors.hw_exception))
} 

.text : {
   *(.text)
   *(.text.*)
   *(.gnu.linkonce.t.*)
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.note.gnu.build-id : {
   KEEP (*(.note.gnu.build-id))
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.init : {
   KEEP (*(.init))
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.fini : {
   KEEP (*(.fini))
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.ctors : {
   __CTOR_LIST__ = .;
   ___CTORS_LIST___ = .;
   KEEP (*crtbegin.o(.ctors))
   KEEP (*(EXCLUDE_FILE(*crtend.o) .ctors))
   KEEP (*(SORT(.ctors.*)))
   KEEP (*(.ctors))
   __CTOR_END__ = .;
   ___CTORS_END___ = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.dtors : {
   __DTOR_LIST__ = .;
   ___DTORS_LIST___ = .;
   KEEP (*crtbegin.o(.dtors))
   KEEP (*(EXCLUDE_FILE(*crtend.o) .dtors))
   KEEP (*(SORT(.dtors.*)))
   KEEP (*(.dtors))
   PROVIDE(__DTOR_END__ = .);
   PROVIDE(___DTORS_END___ = .);
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.rodata : {
   __rodata_start = .;
   *(.rodata)
   *(.rodata.*)
   *(.gnu.linkonce.r.*)
   __rodata_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.sdata2 : {
   . = ALIGN(8);
   __sdata2_start = .;
   *(.sdata2)
   *(.sdata2.*)
   *(.gnu.linkonce.s2.*)
   . = ALIGN(8);
   __sdata2_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.sbss2 : {
   __sbss2_start = .;
   *(.sbss2)
   *(.sbss2.*)
   *(.gnu.linkonce.sb2.*)
   __sbss2_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.data : {
   . = ALIGN(4);
   __data_start = .;
   *(.data)
   *(.data.*)
   *(.gnu.linkonce.d.*)
   __data_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.got : {
   *(.got)
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.got1 : {
   *(.got1)
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.got2 : {
   *(.got2)
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.eh_frame : {
   *(.eh_frame)
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.jcr : {
   *(.jcr)
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.gcc_except_table : {
   *(.gcc_except_table)
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.sdata : {
   . = ALIGN(8);
   __sdata_start = .;
   *(.sdata)
   *(.sdata.*)
   *(.gnu.linkonce.s.*)
   __sdata_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.sbss (NOLOAD) : {
   . = ALIGN(4);
   __sbss_start = .;
   *(.sbss)
   *(.sbss.*)
   *(.gnu.linkonce.sb.*)
   . = ALIGN(8);
   __sbss_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.tdata : {
   __tdata_start = .;
   *(.tdata)
   *(.tdata.*)
   *(.gnu.linkonce.td.*)
   __tdata_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.tbss : {
   __tbss_start = .;
   *(.tbss)
   *(.tbss.*)
   *(.gnu.linkonce.tb.*)
   __tbss_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.bss (NOLOAD) : {
   . = ALIGN(4);
   __bss_start = .;
   *(.bss)
   *(.bss.*)
   *(.gnu.linkonce.b.*)
   *(COMMON)
   . = ALIGN(4);
   __bss_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

_SDA_BASE_ = __sdata_start + ((__sbss_end - __sdata_start) / 2 );

_SDA2_BASE_ = __sdata2_start + ((__sbss2_end - __sdata2_start) / 2 );

/* Generate Stack and Heap definitions */

.heap (NOLOAD) : {
   . = ALIGN(8);
   _heap = .;
   _heap_start = .;
   . += _HEAP_SIZE;
   _heap_end = .;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

.stack (NOLOAD) : {
   _stack_end = .;
   . += _STACK_SIZE;
   . = ALIGN(8);
   _stack = .;
   __stack = _stack;
} > embedded_system_ilmb_bram_if_Mem_embedded_system_dlmb_bram_if_Mem

_end = .;


.storage (NOLOAD) : {
	. = ALIGN(4);
	*(.storage)
} > dram
}

