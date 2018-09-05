# Run MAKER using MPI
cp maker_opts.ctl.est2genome maker_opts.ctl
nohup mpiexec -n 26 maker < /dev/null &
# Collect the GFF3 file for the genome
gff3_merge -d pyu-contig.maker.output/pyu-contig_master_datastore_index.log -s > pyu-contig.all.est2genome.gff
# Make a directory for SNAP training and go to it
mkdir snap1
cd snap1
# Run maker2zff
maker2zff ../pyu-contig.all.est2genome.gff
# Run fathom with the categorize option
$HOME/Git/MakerP/maker/exe/snap/fathom -categorize 1000 genome.ann genome.dna
# Run fathom with the export option
$HOME/Git/MakerP/maker/exe/snap/fathom -export 1000 -plus uni.ann uni.dna
# Run forge
$HOME/Git/MakerP/maker/exe/snap/forge export.ann export.dna
# Run hmm-assembler.pl to generate the final SNAP species parameter/HMM file and return to MAKER working directory
$HOME/Git/MakerP/maker/exe/snap/hmm-assembler.pl pyu1 . > pyu1.hmm
cd ..

# Edit the maker_opts.ctl file to use the newly trained gene finder
cp maker_opts.ctl.snap1 maker_opts.ctl
nohup mpiexec -n 26 maker < /dev/null &
gff3_merge -d pyu-contig.maker.output/pyu-contig_master_datastore_index.log -s > pyu-contig.all.snap1.gff
mkdir snap2
cd snap2
maker2zff ../pyu-contig.all.snap1.gff
$HOME/Git/MakerP/maker/exe/snap/fathom -categorize 1000 genome.ann genome.dna
$HOME/Git/MakerP/maker/exe/snap/fathom -export 1000 -plus uni.ann uni.dna
$HOME/Git/MakerP/maker/exe/snap/forge export.ann export.dna
$HOME/Git/MakerP/maker/exe/snap/hmm-assembler.pl pyu2 . > pyu2.hmm
cd ..

# Edit the maker_opts.ctl file to use the newly trained gene finder
cp maker_opts.ctl.snap2 maker_opts.ctl
nohup mpiexec -n 26 maker < /dev/null &
gff3_merge -d pyu-contig.maker.output/pyu-contig_master_datastore_index.log -s > pyu-contig.all.snap2.gff
mkdir snap3
cd snap3
maker2zff ../pyu-contig.all.snap2.gff
$HOME/Git/MakerP/maker/exe/snap/fathom -categorize 1000 genome.ann genome.dna
$HOME/Git/MakerP/maker/exe/snap/fathom -export 1000 -plus uni.ann uni.dna
$HOME/Git/MakerP/maker/exe/snap/forge export.ann export.dna
$HOME/Git/MakerP/maker/exe/snap/hmm-assembler.pl pyu3 . > pyu3.hmm
cd ..

# Edit the maker_opts.ctl file to use the newly trained gene finder
cp maker_opts.ctl.snap3 maker_opts.ctl
nohup mpiexec -n 26 maker < /dev/null &
gff3_merge -d pyu-contig.maker.output/pyu-contig_master_datastore_index.log -s > pyu-contig.all.snap3.gff
