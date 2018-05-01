|EExec : AMS-like exec function program
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
|	Errors list
|===============================================================
.set	ERROR_SYNTAX,	0	|an option doesn't begin with -
.set	ERROR_NAME,	1	|provided filename is too long
.set	ERROR_TYPE,	2	|src file is not a text
.set	ERROR_HEX_STR,	3	|a char of the string is not 0-9/A-F/a-f
.set	ERROR_ADD_SYM,	4	|failed to add the symbol to the vat
.set	ERROR_ARC_SYM,	5	|symbol created, but an eror has occured when archiving it
.set	ERROR_HELP,	6	|no source file or immediate value provided, nothing to exec
