#!/usr/bin/env python
import sys
try:
    print("importing Bio")
    import Bio
    print("importing networkx")
    import networkx
except ImportError:
    sys.exit(1)
else:
    print("successfully imported packages")
    sys.exit(0)

