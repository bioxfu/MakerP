
cd repeat
RepeatMasker -lib LTR99.lib -dir . LTR85.lib
$DIR_CRL/remove_masked_sequence.pl --masked_elements LTR85.lib.masked --outfile FinalLTR85.lib
cat LTR99.lib FinalLTR85.lib|sed 's/(/[/'|sed 's/)/]/' > allLTR.lib
cat allLTR.lib MITE.lib > combine_MITE_LTR.lib
cd ..


#### collect repetitive sequences by RepeatModeler
## the genomic sequence is masked by (allLTR.lib + MITE.lib = allMITE_LTR.lib)
## split the genome into small files
seqkit split -s 1 $SEQFILE
cd repeat
mkdir seq_split
cd seq_split
find ../../${SEQFILE}.split/*.fasta|parallel --gnu "RepeatMasker -lib ../combine_MITE_LTR.lib -dir . {}"
cat *.masked > ${SEQFILE}.masked
cd ..

## remove the masked elements
mkdir RepeatModeler
../script/rmaskedpart.py ${SEQFILE}.masked > RepeatModeler/umseqfile.fa



BuildDatabase -name RepeatModeler/umseqfiledb -engine ncbi RepeatModeler/umseqfile.fa
nohup RepeatModeler -engine ncbi -pa 30 -database RepeatModeler/umseqfiledb >& RepeatModeler/umseqfile.out
RM=RM_18933.FriSep70812112018
$DIR_CRL/repeatmodeler_parse.pl --fastafile $RM/consensi.fa.classified --unknowns repeatmodeler_unknowns.fasta --identities repeatmodeler_identities.fasta 


blastx -query repeatmodeler_unknowns.fasta -db ../Tpases/Tpases020812  -evalue 1e-10 -num_descriptions 10 -out modelerunknown_blast_results.txt
$DIR_CRL/transposon_blast_parse.pl --blastx modelerunknown_blast_results.txt --modelerunknown repeatmodeler_unknowns.fasta

mv unknown_elements.txt ModelerUnknown.lib
cat identified_elements.txt repeatmodeler_identities.fasta > ModelerID.lib

## exclusion of gene fragments
makeblastdb -in ../script/alluniRefprexp070416 -dbtype prot

blastx -num_threads 26 -query ModelerUnknown.lib -db ../script/alluniRefprexp070416 -evalue 1e-10 -num_descriptions 10 -out ModelerUnknown.lib_blast_results.txt
blastx -num_threads 26 -query MITE.lib -db ../script/alluniRefprexp070416 -evalue 1e-10 -num_descriptions 10 -out MITE.lib_blast_results.txt
blastx -num_threads 26 -query allLTR.lib -db ../script/alluniRefprexp070416 -evalue 1e-10 -num_descriptions 10 -out allLTR.lib_blast_results.txt
blastx -num_threads 26 -query ModelerID.lib -db ../script/alluniRefprexp070416 -evalue 1e-10 -num_descriptions 10 -out ModelerID.lib_blast_results.txt

../script/ProtExcluder1.1/ProtExcluder.pl ModelerUnknown.lib_blast_results.txt ModelerUnknown.lib
../script/ProtExcluder1.1/ProtExcluder.pl MITE.lib_blast_results.txt MITE.lib
../script/ProtExcluder1.1/ProtExcluder.pl allLTR.lib_blast_results.txt allLTR.lib
../script/ProtExcluder1.1/ProtExcluder.pl ModelerID.lib_blast_results.txt ModelerID.lib
rm *_blast_results.txt.* *.libnPr *.ssi temp

cat MITE.libnoProtFinal allLTR.libnoProtFinal ModelerID.libnoProtFinal > KnownRepeats.lib
cat KnownRepeats.lib ModelerUnknown.libnoProtFinal > allRepeats.lib
