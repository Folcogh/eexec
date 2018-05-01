#!/bin/sh

tigcc -v eexec.s -o eexec

mv eexec.??z ..

rm -f *.o *.??z *~ ../*~
