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
|	Command line args
|===============================================================
CmdLineStrings:
	.asciz	"add"			|add the binary file to the vat
	.asciz	"src"			|use an existing file as source
	.asciz	"arg"			|imediate value to exec
	.asciz	"arc"			|archive the file before running it
	.asciz	"rem"			|remove the file after its execution
	.asciz	"dry"			|perform a dry run

|===============================================================
|	Marker of end of options block/beginning of error block
|===============================================================
NullString:	.byte	0

|===============================================================
|	Error messages
|===============================================================
	.asciz	"Bad syntax"
	.asciz	"Wrong file name"
	.asciz	"Wrong file type"
	.asciz	"Invalid string"
	.asciz	"Can't create file"
	.asciz	"Can't archive file"
	.ascii	"$ eexec [options] -arg <hexa value>\n"		|not really an error, but an help text
	.ascii	"$ eexec [options] -src <[folder\\]file>\n"
	.ascii	"Options: add arc rem dry\n"
	.asciz	"Type 'man eexec' for more info"

|===============================================================
|	Comment of the program
|===============================================================
_comment :	.asciz	"Extended Exec by Folco"