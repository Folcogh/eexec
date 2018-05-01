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
|	FLAGS(%fp)
|
|	# of the bit set in d6 (the lower byte is used to store
|	the lock status of the source file)
|===============================================================
.set	FLAG_ADD,		0
.set	FLAG_SRC,		1
.set	FLAG_ARG,		2
.set	FLAG_ARC,		3
.set	FLAG_REM,		4
.set	FLAG_DRY,		5
.set	FLAG_SYM_ADDED,		6	|set if a symbol has been correctly added to the VAT
