#!/usr/bin/python
import sys
for line in sys.stdin:

    sys.stdout.write(chr(int(line.rstrip(),base=2)))
