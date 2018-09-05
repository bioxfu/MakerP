${BASE}=dpp_contig
# Generate an id mapping file using maker_map_ids
maker_map_ids --prefix DMEL_ --justify 6 ${${BASE}}.all.gff > ${${BASE}}.all.map

# Backup the original files
cp ${${BASE}}.all.gff ${${BASE}}.all.gff.old
cp ${${BASE}}.all.maker.proteins.fasta ${${BASE}}.all.maker.proteins.fasta.old
cp ${${BASE}}.all.maker.transcripts.fasta ${${BASE}}.all.maker.transcripts.fasta.old

# Use the map file to change the ids in the FASTA and GFF3 file
map_gff_ids ${${BASE}}.all.map ${${BASE}}.all.gff
map_fasta_ids ${${BASE}}.all.map ${${BASE}}.all.maker.proteins.fasta
map_fasta_ids ${${BASE}}.all.map ${${BASE}}.all.maker.transcripts.fasta
