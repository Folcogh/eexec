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
|	eexec stack frame offsets
|
|	Warning !
|
|	These offsets are set accordingly to the order in which
|	the variables are initialized in eexec.s
|	Check the boot of the program before modifying them !
|
|===============================================================

.set	SYM_STR_FRAME,		0	|20	where is stored the SYM_STR of the source or the file to create
.set	DEST_FILENAME,		20	|4	ptr to the filename to create
.set	SRC_FILENAME,		24	|4	points to the hex arg
.set	HEX_PTR,		28	|4	ptr to the src filename
.set	ERROR_FRAME,		32	|4*15	error frame for ER_CATCH

.set	SFRAME_SIZE,		92	|total size
