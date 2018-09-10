#! /usr/bin/env python

import sys
from Bio import SeqIO

for record in SeqIO.parse(sys.argv[1], "fasta"):
	new_seq = str(record.seq).replace('N', '')
	if len(new_seq) > 0:
		print('>' + record.id + '\n' + new_seq)
