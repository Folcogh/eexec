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
|	MakeByte
|===============================================================
|	Create a byte with two digits of an hexa string
|
|	input	(a1).w	bytes to compute
|		d0-d1	null
|	output	d1.b	byte created
|	destroy	std
|===============================================================
MakeByte:
	lsl.b	#4,%d1					|useless for the first pass, but save the first 4 bits before the second one
	move.b	(%a1)+,%d0				|read a byte
	subi.b	#'0',%d0				|a valid char can be 0-9, a-f or A-F
	bmi.s	InvalidHexValue				|char is < #0
	cmpi.b	#9,%d0					|char =< #9 ?
	bls.s	ValidChar				|yes, char is ready.
	subi.b	#'A'-'0',%d0				|char < A ?
	bmi.s	InvalidHexValue				|yes, quit...
	cmp.b	%d2,%d0					|char =< F ?
	bls.s	ValidCharAdd10				|yes, success
	subi.b	#'a'-'A',%d0				|char < a ?
	bmi.s	InvalidHexValue				|yes, quit...
	cmp.b	%d2,%d0					|char =< f ?
	bls.s	ValidCharAdd10				|yes, success
InvalidHexValue:					|else char is wrong...
		bra	ThrowError
ValidCharAdd10:
	addi.b	#10,%d0					|digit was a-f or A-F
ValidChar:
	or.b	%d0,%d1
	rts
