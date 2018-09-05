# Run MAKER using MPI
nohup mpiexec -n 26 maker < /dev/null &

# Collect the results from all individual contigs into genome wide annotations
BASE=dpp_contig
gff3_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log
fasta_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log
