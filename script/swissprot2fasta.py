#! /usr/bin/env python

## http://biopython.org/DIST/docs/api/Bio.SwissProt.Record-class.html

from __future__ import print_function
import sys, gzip
import Bio.SwissProt as sp

with gzip.open(sys.argv[1]) as handle:
	records = sp.parse(handle)
	for record in records:
		print(">%s | %s\n%s" % (record.entry_name, record.organism, record.sequence))
