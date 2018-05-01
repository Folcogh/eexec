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


|===============================================================
|	ThrowError
|===============================================================
|	Called when a fatal error occurs
|
|	input	d7.w	#error
|	output	nothing
|	destroy	std+d7
|===============================================================
ThrowError:
	lea.l	NullString(%pc),%a0		|main block of error strings
StringLoop:
	tst.b	(%a0)+				|skip an entire string
	bne.s	StringLoop
	dbf.w	%d7,StringLoop			|until having reached the right one
	pea.l	(%a0)				|push it
	bsr.s	PushStrFormat
	.asciz	"%s\n"
	.even
PushStrFormat:
	pea.l	4<<16+0				|function + version
	bsr.s	PushStrPedroM			|push pedrom string ptr
	.asciz	"pedrom"
	.even
PushStrPedroM:
	.word	0xF000 + 29			|print text
	bra	Quit				|and quit
