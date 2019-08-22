source activate maker

wget -c http://weatherby.genetics.utah.edu/CPB_MAKER/CPB_MAKER.tar.gz
tar zxvf CPB_MAKER.tar.gz
export PATH_TO_CBP=$HOME/Project/MAKER/CPB_maker

mkdir protocols
cd protocols

#### Basic Protocol 1: de novo genome annotation using MAKER
mkdir BP1
cd BP1
# 1. Generate MAKER control files (maker_opts.ctl, maker_bopts.ctl, maker_exe.ctl)
maker -CTL
# 2. Edit maker_opts.ctl file
# 3. Run MAKER
maker 2> maker.error &
# 4. Check standard error output and datastore index file to see if MAKER is finished
# 5. Collect the results from all individual contigs into genome wide annotations
gff3_merge -d dpp_contig.maker.output/dpp_contig_master_datastore_index.log
fasta_merge -d dpp_contig.maker.output/dpp_contig_master_datastore_index.log
# Once the GFF3 and FASTA files are merged together the structural protein-coding gene annotation is complete.
cd ..

#### Alternate Protocol 1: de novo genome annotation using pre-existing evidence alignments and gene predictions
mkdir AP1
cd AP1
# 1. Generate MAKER control files (maker_opts.ctl, maker_bopts.ctl, maker_exe.ctl)
maker -CTL
# 2. Edit maker_opts.ctl file
# 3. Run MAKER
maker 2> maker.error &
# 4. Check standard error output and datastore index file to see if MAKER is finished
# 5. Collect the results from all individual contigs into genome wide annotations
gff3_merge -d dpp_contig.maker.output/dpp_contig_master_datastore_index.log
fasta_merge -d dpp_contig.maker.output/dpp_contig_master_datastore_index.log
# Once the GFF3 and FASTA files are merged together the structural protein-coding gene annotation is complete.
cd ..


#### Support Protocol 1: Training gene finders for use with MAKER
mkdir SP1
cd SP1
# 1. Generate MAKER control files (maker_opts.ctl, maker_bopts.ctl, maker_exe.ctl)
maker -CTL
# 2. Edit maker_opts.ctl file
# 3. Run MAKER
maker 2> maker.error &
# 4. Collect the GFF3 file for the genome
gff3_merge -d pyu-contig.maker.output/pyu-contig_master_datastore_index.log
# 5. Make a directory for SNAP training and go to it
mkdir snap1
cd snap1
# 6. Run maker2zff
maker2zff ../pyu-contig.all.gff
# 7. Run fathom with the categorize option
fathom -categorize 1000 genome.ann genome.dna
# 8. Run fathom with the export option
fathom -export 1000 -plus uni.ann uni.dna
# 9. Run forge
forge export.ann export.dna
# 10. Run hmm-assembler.pl to generate the final SNAP species parameter/HMM file and return to MAKER working directory
hmm-assembler.pl pyu1 . > pyu1.hmm
cd ..
# 11. Edit the maker_opts.ctl file to use the newly trained gene finder
# 12. Optional bootstrap training can be done by repeating step 3 to 10
# Generally there is little further improvement after two rounds of bootstrap training with the same evidence.
cd ..

#### Support Protocol 2: Renaming genes for GenBank submission
# 1. Generate an id mapping file using maker_map_ids
cd BP1
maker_map_ids --prefix DMEL_ --justify 6 dpp_contig.all.gff > dpp_contig.all.map
# 2. Use the map file to change the ids in the FASTA and GFF3 file
cp dpp_contig.all.gff dpp_contig.all.gff.bk
cp dpp_contig.all.maker.proteins.fasta dpp_contig.all.maker.proteins.fasta.bk
cp dpp_contig.all.maker.transcripts.fasta dpp_contig.all.maker.transcripts.fasta.bk

map_gff_ids dpp_contig.all.map dpp_contig.all.gff
map_fasta_ids dpp_contig.all.map dpp_contig.all.maker.proteins.fasta
map_fasta_ids dpp_contig.all.map dpp_contig.all.maker.transcripts.fasta

