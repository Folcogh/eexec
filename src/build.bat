echo off

tigcc -v eexec.s -o eexec

move eexec.??z ../

del *.o *.??z
