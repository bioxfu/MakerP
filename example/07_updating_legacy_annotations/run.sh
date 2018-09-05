# Run MAKER using MPI
nohup mpiexec -n 26 maker < /dev/null &

# Collect the results from all individual contigs into genome wide annotations
BASE=legacy-contig
gff3_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log
fasta_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log

# Check the number of gene and UTR 
grep -cP '\tgene\t' ../maker_inputs/legacy_data/legacy-set1.gff
grep -cP '\tgene\t' ../maker_inputs/legacy_data/legacy-set2.gff
grep -cP '\tgene\t' ${BASE}.all.gff
grep -cP '\t(three|five)_prime_UTR\t' ${BASE}.all.gff
