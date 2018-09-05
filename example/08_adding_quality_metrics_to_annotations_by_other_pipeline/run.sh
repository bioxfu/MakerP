# Run MAKER using MPI
cp maker_opts.ctl.set1 maker_opts.ctl 
nohup mpiexec -n 26 maker < /dev/null &

# Collect the results from all individual contigs into genome wide annotations
BASE=legacy-contig
gff3_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log
#fasta_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log
mv ${BASE}.all.gff ${BASE}.set1.gff

cp maker_opts.ctl.set2 maker_opts.ctl 
nohup mpiexec -n 26 maker < /dev/null &
gff3_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log
mv ${BASE}.all.gff ${BASE}.set2.gff

# Check the AED of mRNAs
AED_cdf_generator.pl -b 0.025 ${BASE}.set1.gff ${BASE}.set2.gff > AED_cdf.tsv
Rscript plot_AED_cdf.R
