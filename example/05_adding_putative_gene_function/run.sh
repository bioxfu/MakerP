
# Index the UniProt/Swiss-Prot multi-FASTA file using makeblastdb
$HOME/Git/MakerP/maker/exe/blast/bin/makeblastdb -in uniprot_sprot.fasta -input_type fasta -dbtype prot

# BLAST the MAKER-generated protein FASTA file to UniProt/Swiss-Prot with BLASTP
$HOME/Git/MakerP/maker/exe/blast/bin/blastp -db uniprot_sprot.fasta -query dpp_contig.all.maker.proteins.fasta \
-out maker2uni.blastp -evalue .000001 -outfmt 6 -num_alignments 1 -seg yes -soft_masking true -lcase_masking -max_hsps_per_subject 1

# Add the protein homology data to the MAKER GFF3 and FASTA files with maker_functional_gff and maker_functional_fasta
maker_functional_gff uniprot_sprot.fasta maker2uni.blastp dpp_contig.all.gff > dpp_contig_functional_blast.gff
maker_functional_fasta uniprot_sprot.fasta maker2uni.blastp dpp_contig.all.maker.proteins.fasta > dpp_contig.all.maker.proteins_functional_blast.fasta
maker_functional_fasta uniprot_sprot.fasta maker2uni.blastp dpp_contig.all.maker.transcripts.fasta > dpp_contig.all.maker.transcripts_functional_blast.fasta
