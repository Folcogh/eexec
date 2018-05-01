|EExec: AMS-like exec function program
|Copyright (C) 2009 Martial Demolins (mdemolins at gmail dot com)
|
| This program is free software: you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation, either version 3 of the License, or
| (at your option) any later version.
|
| This program is distributed in the hope that it will be useful,
| but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
| GNU General Public License for more details.

| You should have received a copy of the GNU General Public License
| along with this program.  If not, see <http://www.gnu.org/licenses/>.


	.include	"kernel.h"
	.include	"sframe.h"
	.include	"errors.h"
	.include	"flags.h"

	.xdef	_main
	.xdef	_flag_2			|console app: no redraw screen
	.xdef	_flag_3			|execute in flash if archived
	.xdef	_comment

	.xdef	_ti89
	.xdef	_ti89ti
	.xdef	_ti92plus
	.xdef	_v200

|===============================================================
|	Main part of eexec
|===============================================================
|
|	REGISTERS USAGE
|
|	a0-a1/d0-d2	assumed they are destroyed by all functions
|
|	a2		ARGV
|	a3		Used while parsing the command line. Callback to compute src ptr
|	a4		Used while parsing the command line
|	a5		...
|	a6		Used as frame pointer. Points to the stack frame
|
|	d3		ARGC. Then size of the file to create
|	d4		Binary handle. Must be initialized at 0
|	d5		Used while parsing command line. Used while computing bin handle size
|	d6		Bits 0-6: flags. Must be initialized at 0
|	d7		# error message
|
|===============================================================
_main:	addq.l	#4,%sp					|remove return adress
	move.w	(%sp)+,%d3				|read ARGC
	movea.l	(%sp),%a2				|read ARGV
	lea.l	-SFRAME_SIZE(%sp),%sp			|create the stack frame

	|===============================================================
	|	Init some registers and data
	|===============================================================
	moveq.l	#0,%d4					|reset bin handle, in case of error (not created yet)
	moveq.l	#0,%d6					|reset flags
	moveq.l	#ERROR_SYNTAX,%d7			|default: fail to parse command line
	movea.l	%sp,%fp					|set the frame pointer
	clr.b	(%fp)					|first byte of SYM_STR

|===============================================================
|	Parse the command line. Will throw an error if something
|	goes wrong.
|===============================================================
CheckArgsLoop:
	addq.l	#4,%a2					|next arg (first pass : skip 'pexec')
	subq.w	#1,%d3					|remaining args ?
	beq.s	EndOfParsing				|no, end of treatment
	movea.l	(%a2),%a4				|read &arg
	cmpi.b	#'-',(%a4)+				|valid option ?
	bne	ThrowError				|no, fatal
		lea.l	CmdLineStrings(%pc),%a3		|get &options
		moveq.l	#0,%d5				|offset of the flag (1 bit) and in the pc-relative jump table
FindOptionLoop:
		pea.l	(%a4)				|push arg
		pea.l	(%a3)				|push option
		RC	strcmp				|compare them
		addq.l	#8,%sp				|pop args
		tst.w	%d0				|equal ?
		beq.s	ExecuteOption			|yes ! do the stuff for it
			addq.w	#1,%d5			|option++ (table of bytes)
			addq.l	#4,%a3			|splendid hack: all options are 4 bytes long :D
			tst.b	(%a3)			|end of table ?
			bne.s	FindOptionLoop		|no, try with the next option
				bra	ThrowError	|else quit because no option matches

ExecuteOption:
	lea.l	DEST_FILENAME(%fp),%a0			|default field to fill
	bset.l	%d5,%d6					|set the flag of the option
	move.b	ExecOption(%pc,%d5.w),%d5		|read offset, upper part of d5.w is clean
	jmp	ExecOption(%pc,%d5.w)			|and execute the right routine

ExecOption:
	.byte	OptionAdd-ExecOption			|pc-relative jump table, to access sub-routine of each option
	.byte	OptionSrc-ExecOption
	.byte	OptionArg-ExecOption
	.byte	OptionArc-ExecOption
	.byte	OptionRem-ExecOption
	.byte	OptionDry-ExecOption

|===============================================================
|	All these labels are accesed by the pc-relative jump table
|	They are set in a accurate order, according to offsets in
|	the stack frame (sframe.h), and according to the order of
|	the strings of the options (strings.s).
|
|	Don't modify the order of any of these routines,
|	they are ordered to allow a lot of size/speed optimizations
|===============================================================
OptionArg:	addq.l	#4,%a0			|next offset in the stack frame
OptionSrc:	addq.l	#4,%a0			|idem
OptionAdd:	addq.l	#4,%a2			|next arg
		subq.w	#1,%d3			|remain some args ?
		beq	ThrowError		|no, this is an error
			move.l	(%a2),(%a0)	|store &arg in the stack frame
OptionArc:
OptionRem:
OptionDry:		bra.s	CheckArgsLoop	|and handle the next arg


|===============================================================
|	Now we must have something to exec
|	Compute the size of the bin handle to create, according to
|	FLAG_SRC and FLAG_ARG
|
|	If both flags are set, FLAG_SRC is ignored
|	If no one of these is set, disp an help and quit
|===============================================================
EndOfParsing:
	movea.l	HEX_PTR(%fp),%a0			|default: the hex value is provided in the command line
	btst.l	#FLAG_ARG,%d6				|is it true ?
	beq.s	CheckFlagSrc				|no, so the value to exec should be in a file

	|===============================================================
	|	Get the lenght of the string, to know the size of the handle to create
	|===============================================================
	lea.l	GetPtrCmdLine(%pc),%a3			|callback to get the ptr of the hex value
	pea.l	(%a0)					|ptr to the hex str
	RC	strlen					|get is size
	move.l	%d0,%d3					|save it
	bra.s	ComputeBinSize				|and continue

		|===============================================================
		|	Size of the input string is odd, report an error and quit
		|===============================================================
ErrorSizeIsOdd:
		moveq.l	#ERROR_HEX_STR,%d7
		bra	ThrowError


|===============================================================
|	FLAG_ARG is not set, so FLAG_SRC must be set
|===============================================================
CheckFlagSrc:
	moveq.l	#ERROR_HELP,%d7				|default error: nothing to exec, sodisp a help
	btst.l	#FLAG_SRC,%d6				|the hex value is in a file ?
	beq	ThrowError				|no, disp a help text and quit

	|===============================================================
	|	Else search for the file
	|	- create its SYM_STR and save a ptr to it
	|	- find it
	|	- read its lenght
	|	- check its type
	|	- compute the size of the binary handle
	|===============================================================
	moveq.l	#ERROR_NAME,%d7				|default : name is invalid
	movea.l	SRC_FILENAME(%fp),%a0			|&filename
	lea.l	SYM_STR_FRAME+1(%fp),%a2		|buffer
	moveq.l	#8+1+8+1-1,%d0				|counter: "folder\filename",0
CopySymStr:
	move.b	(%a0)+,(%a2)+				|copy filename
	beq.s	EndOfCopy				|end reached
	dbf.w	%d0,CopySymStr				|else loop
		bra	ThrowError			|if we execute that, name is too long => error
EndOfCopy:
	subq.l	#1,%a2					|SYM_STR*
	|===============================================================
	|	Find the file, check if it exists, and check its type
	|===============================================================
	clr.w	-(%sp)					|flags
	pea.l	(%a2)					|SYM_STR*
	RC	SymFindPtr				|get &SYM_ENTRY
	move.l	%a0,%d0					|file found ?
	beq	ThrowError				|no, terminate
		moveq.l	#ERROR_TYPE,%d7			|default error: the file hasn't the right type
		movea.w	12(%a0),%a0			|read handle
		trap	#3				|deref it
		moveq.l	#0,%d3				|clear d3 (useless for a valid file, beacuse its max size should be 65520/2 : <32ko)
		move.w	(%a0),%d3			|read size
		move.b	1(%a0,%d3.l),%d0		|read TAG
		|===============================================================
		|	A text has a header of 2 bytes + a leading space + a terminal 0 + a tag == 5 bytes of data
		|===============================================================
		cmpi.b	#0xE0,%d0			|is it a text ?
		bne.s	NoText				|no
			lea.l	GetPtrTextFile(%pc),%a3	|callback
			subq.w	#2+1+1+1,%d3		|remove header + leading space + terminal 0 + tag
			bra.s	ComputeBinSize

		|===============================================================
		|	A string has a header of 1 byte + a terminal 0 + a tag == 3 bytes
		|===============================================================
NoText:		cmpi.b	#0x2D,%d0			|is it a string ?
		bne	ThrowError			|no, fatal error
			lea.l	GetPtrStrFile(%pc),%a3	|callback
			subq.w	#1+1+1,%d3		|remove leading 0 + terminal 0 + tag
ComputeBinSize:		lsr.w	#1,%d3			|2 chars make 1 byte
			bcs.s	ErrorSizeIsOdd
			addq.w	#4,%d3			|add size + tag + padding


|===============================================================
|	Now we know the size of the handle to create. Let's do it.
|===============================================================
	moveq.l	#ERROR_ADD_SYM,%d7			|default: can't add file (memory)
	move.l	%d3,(%sp)				|the upper part of d3 is clear
	RC	HeapAlloc				|try to alloc
	move.w	%d0,%d4					|check the handle, saving it
	beq	ThrowError


|===============================================================
|	Get a pointer to the hex value to compute. We use a callback,
|	because the header size is not the same for STR and TEXT files.
|===============================================================
	jmp	(%a3)

	|===============================================================
	|	Get a pointer to the hex value in the command line
	|===============================================================
GetPtrCmdLine:
	movea.l	HEX_PTR(%fp),%a1
	bra.s	DerefBin

	|===============================================================
	|	Get a pointer to the hex value in a text file
	|===============================================================
GetPtrTextFile:
	moveq.l	#5,%d5					|size of the header
	bra.s	GetPtrFile

	|===============================================================
	|	Get a pointer to the hex value in a string file
	|===============================================================
GetPtrStrFile:
	moveq.l	#3,%d5					|size of the header
GetPtrFile:
	clr.w	(%sp)					|flags
	pea.l	(%a2)					|push SYM_STR*
	RC	SymFindPtr
	movea.w	12(%a0),%a0				|read handle
	trap	#3					|deref oit
	lea.l	0(%a0,%d5.w),%a1			|add header size

|===============================================================
|	We are now ready to create binary with hexadecimal string.
|	MakeByte create 4 bits of binary.
|	When complete, write asm file tag.
|	a2 points to the source file, a0 to the binary file.
|===============================================================
DerefBin:
	movea.w	%d4,%a0					|read binary handle
	trap	#3					|deref it
	subq.w	#3,%d3
	move.w	%d3,(%a0)+
	subq.w	#2,%d3
	moveq.l	#5,%d2					|needed by MakeByte
	moveq.l	#ERROR_HEX_STR,%d7
CreateBin:
	bsr.s	MakeByte				|create 4 bits
	bsr.s	MakeByte				|and a complete byte
	move.b	%d1,(%a0)+				|write it
	dbf.w	%d3,CreateBin
	move.b	#0xF3,(%a0)				|write ASM_TAG

|===============================================================
|	Check if the file has to be added to the VAT,
|	and do it if necessary
|===============================================================
	btst.l	#FLAG_ADD,%d6				|filename provided ?
	beq	ExecuteFile				|no, execute now !

	|===============================================================
	|	Create the SYM_STR, checking its size
	|===============================================================
	movea.l	DEST_FILENAME(%fp),%a0
	lea.l	SYM_STR_FRAME+1(%fp),%a2		|buffer
	moveq.l	#8+1+8+1-1,%d0				|counter: "folder\filename\0"
CopySymStr2:
	move.b	(%a0)+,(%a2)+				|copy filename
	beq.s	EndOfCopy2				|end reached
	dbf.w	%d0,CopySymStr2				|else loop
		moveq.l	#ERROR_NAME,%d7
|		bra	ThrowError

		.include	"errors.s"
		.include	"byte.s"		|included here, because it allow a short branch to jump to it

EndOfCopy2:
	subq.l	#1,%a2					|SYM_STR*. Used to archive file if needed

	|===============================================================
	|	Here, create a try/endrty structure using ER_catch,
	|	because SymAdd can fail without coming back to the program
	|===============================================================
	pea.l	ERROR_FRAME(%fp)			|*frame
	RC	ER_catch				|set the frame handler
	moveq.l	#ERROR_ADD_SYM,%d7			|default: SymAdd has failed
	tst.w	%d0					|test it
	bne	ThrowError				|failed...
	pea.l	(%a2)					|else we can add it
	RC	SymAdd					|create symbol
	move.l	%d0,(%sp)				|push and test its HSYM
	beq	ThrowError				|shit...
		RC	DerefSym			|get SYM_ENTRY *
		move.w	%d4,12(%a0)			|and store handle
		RC	ER_success			|pop error frame
		bset.b	#FLAG_SYM_ADDED,%d6		|set success flag
		btst.l	#FLAG_ARC,%d6			|must archive ?
		beq.s	ExecuteFile			|no, can execute file now
			moveq.l	#ERROR_ARC_SYM,%d7	|default error: can't archive file
			clr.l	(%sp)			|no HSYM
			pea.l	(%a2)			|but SYM_STR *
			RC	EM_moveSymToExtMem	|push it in archive. It changes the handle !!!
			tst.w	%d0			|success ?
			beq	ThrowError		|no
				clr.w	(%sp)		|flags
				pea.l	(%a2)		|push SYM_STR *
				RC	SymFindPtr	|get SYM_ENTRY *
				move.w	12(%a0),%d4	|read handle, all it's ok now

|===============================================================
|
|	Now run the file ! No protection, no register saved etc, the kernel handles that.
|
|===============================================================
ExecuteFile:
	btst.l	#FLAG_DRY,%d6				|dry run ?
	bne.s	Quit					|ok, quit now
		move.w	%d4,%d0				|handle, arg of kernel::exec
		.word	0xF000 + 22			|kernel::exec


|===============================================================
|	Remove symbol and binary handle if they musn't be kept.
|	A lot of test are needed, because flags can be inconsistents
|===============================================================
Quit:
	|===============================================================
	|	Remove symbol if it has been created and musn't be kept
	|===============================================================
	btst.l	#FLAG_SYM_ADDED,%d6			|has it been created ?
	beq.s	NoDelSymbol				|no, nothing to remove
		btst.l	#FLAG_REM,%d6			|must be kept ?
		beq.s	NoDelSymbol			|yes
			clr.l	(%sp)			|always unarc file, even if it's in RAM. It will just throw an error
			pea.l	(%a2)			|SYM_STR*
			RC	EM_moveSymFromExtMem	|unarchive it
			clr.w	(%sp)			|flags
			pea.	(%a2)			|need to get the new handle
			RC	SymFindPtr		|SYM_ENTRY *
			move.w	12(%a0),%d4		|handle has changed
			pea.l	(%a2)			|SYM_STR* again
			RC	SymDel			|del symbol
NoDelSymbol:

	|===============================================================
	|	Remove bin handle if needed
	|===============================================================
	move.w	%d4,(%sp)				|test it
	beq.s	NoDelHandle				|something has failed
		btst.l	#FLAG_SYM_ADDED,%d6		|has it been added ?
		beq.s	DelHandle			|no, so it must be always deleted
			btst.l	#FLAG_REM,%d6		|must be removed ?
			beq.s	NoDelHandle		|no
DelHandle:			RC	HeapFree	|else free it
NoDelHandle:

	|===============================================================
	|	Quit, restoring nothing, thx kernel::exit
	|===============================================================
	.word	0xF000 + 42				|kernel::exit


|===============================================================
|	String which could be anywhere in the source...
|===============================================================
	.include	"strings.s"
