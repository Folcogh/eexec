|=======================================================|
|							|
|			Extended Exec			|
|							|
|=======================================================|


Infos
-----

Extended Exec v1.0 by Martial Demolins

This soft is designed to offer a way to execute hexadecimal code
like the "exec()" command of AMS.

This program should run on TI89 / TI89ti  / TI92+ / v200
Thanx to report bugs to mdemolins >> gmail >> com

Sorry for my poor english (en gros si vous etes pas content, apprenez
le francais, ca ira tout de suite mieux :p).


Requirements
------------

The minimum required version of PedroM is 0.82 RC7, else it will crash.

Don't try this soft under AMS, it will certainly crash.


Run the program
---------------

Just send the binary file (eexec.??z). Then type
:>eexec <options> -arg <hexadecimal value>
:>eexec <options> -src <[folder\]filename>

Options:
	-add <[folder\]filename>
		add the file to the vat. The filename can contain a path.
		By default, eexec executes the code from RAM without
		adding it to the VAT.

	-arc	archive the file before running it.

	-rem	remove the file after having run it.

	-arg <hexadecimal value>
		built the hexa value to do a binary executable

	-src <[folder\]filename>
		use the specified file to get the hex value. It must be a
		text or a string file. A text file musn't have trailing spaces
		or EOL to be valid.

	-dry	don't run the built program. It will be added to the VAT if
		specified. Will do nothing if the file isn't added, but you will
		be sure that your hex value is valid if no error is returned.

If both -arg and -src are specified, -src is ignored.
If -arc or -rem are specified without -add, they are ignored.


Tip
---

When run archived, this program uses 0 bytes of RAM, beacause the binary has a
read-only flag, and doesn't contain self-modifying code. Nice, isn't it ? :)

As a consequence, EExec is reentrant, an can be run in multiple instances in
different shells.



Compilation
-----------

Run the "build.sh" script in an Unix-like environment.
Run the "build.bat" script under MS-Windows.


License
-------

GPL v3. Look at the file 'license.txt'


Credits
-------

Thanks to:
- the GCC4TI team: http://trac.godzil.net/gcc4ti/
- the TIGCC team for TIGCCLIB (http://tigcc.ticalc.org/)
- Kernel Killer (Kevin Kofler) for some help on irc
  (freequest/#tigcc and  http://tigcc.ticalc.org/linux/)
- PpHd (Patrick Pelissier) for its wonderfull OS PedroM !!!
  (http://www.yaronet.com/t3/) and for all its tips
- Romain Lievin and Kevin Kofler for TiEmu
  (http://lpg.ticalc.org/prj_tiemu/)
- the french community (mainly on http://www.yaronet.com)
  for all its tips and support !

Special thanks to PpHd for having added a RAM_THROW extension !
