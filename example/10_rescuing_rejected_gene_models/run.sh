# Run MAKER using MPI
nohup mpiexec -n 26 maker < /dev/null &

# Collect the results from all individual contigs into genome wide annotations
BASE=pyu-contig
gff3_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log
fasta_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log

# Run InterProScan on the MAKER generated proteins to identify proteins with known functional domains.
$HOME/Git/MakerP/interproscan/interproscan-5.30-69.0/interproscan.sh -appl PfamA -cpu 26 -iprlookup -goterms -f tsv -i pyu-contig.all.maker.proteins.fasta

# Update teh MAKER generated GFF3 file with the InterProScan results using ipr_update_gff
ipr_update_gff pyu-contig.all.gff pyu-contig.all.maker.proteins.fasta.tsv > pyu-contig.max.functional_ipr.gff

# Use the quality_filter.pl script distributed with MAKER to filter the gene models based on domain content and evidence support
quality_filter.pl -d pyu-contig.max.functional_ipr.gff > pyu-contig.default.functional_ipr.gff
quality_filter.pl -s pyu-contig.max.functional_ipr.gff > pyu-contig.standard.functional_ipr.gff
