SEQINDEX=$1
TRNA=$2
DIR_CRL=$3
MITElib=$4
TPASES_DNA=$5
RM_DIR=$6
SIM=85

echo "run LTRharvest to collect relatively old LTRs by reducing the similarity between LTRs to 85% and not associated with terminal sequence motif"
gt ltrharvest -index $SEQINDEX -out seqfile.out${SIM} -outinner seqfile.outinner${SIM} -gff3 seqfile.gff${SIM} -minlenltr 100 -maxlenltr 6000 -mindistltr 1500 -maxdistltr 25000 -mintsd 5 -maxtsd 5 -similar ${SIM} -vic 10  > seqfile.result${SIM}

echo "run LTRdigest to find elements with PPT (poly purine tract) or PBS (primer binding site)"
gt gff3 -sort seqfile.gff${SIM} > seqfile.gff${SIM}.sort
gt ltrdigest -trnas $TRNA seqfile.gff${SIM}.sort $SEQINDEX > seqfile.gff${SIM}.dgt
$DIR_CRL/CRL_Step1.pl --gff seqfile.gff${SIM}.dgt

echo "further filtering of the candidate elements"
$DIR_CRL/CRL_Step2.pl --step1 CRL_Step1_Passed_Elements.txt --repeatfile seqfile.out${SIM} --resultfile seqfile.result${SIM} --sequencefile $SEQFILE --removed_repeats CRL_Step2_Passed_Elements.fasta
mkdir fasta_files
mv Repeat_*.fasta fasta_files
mv CRL_Step2_Passed_Elements.fasta fasta_files
cd fasta_files
$DIR_CRL/CRL_Step3.pl --directory $PWD --step2 CRL_Step2_Passed_Elements.fasta --pidentity 60 --seq_c 25 
mv CRL_Step3_Passed_Elements.fasta ..
cd ..

echo "identify elements with nested insertions"
$DIR_CRL/ltr_library.pl --resultfile seqfile.result${SIM} --step3 CRL_Step3_Passed_Elements.fasta --sequencefile $SEQFILE
cat lLTR_Only.lib $MITElib  > repeats_to_mask_LTR${SIM}.fasta
$RM_DIR/RepeatMasker -lib repeats_to_mask_LTR${SIM}.fasta -nolow -dir . seqfile.outinner${SIM}
$DIR_CRL/cleanRM.pl seqfile.outinner${SIM}.out seqfile.outinner${SIM}.masked > seqfile.outinner${SIM}.unmasked
$DIR_CRL/rmshortinner.pl seqfile.outinner${SIM}.unmasked 50 > seqfile.outinner${SIM}.clean

blastx -query seqfile.outinner${SIM}.clean -db $TPASES_DNA -evalue 1e-10 -num_descriptions 10 -out seqfile.outinner${SIM}.clean_blastx.out.txt
$DIR_CRL/outinner_blastx_parse.pl --blastx seqfile.outinner${SIM}.clean_blastx.out.txt --outinner seqfile.outinner${SIM}

echo "building representative sequences (examplars)"
$DIR_CRL/CRL_Step4.pl --step3 CRL_Step3_Passed_Elements.fasta --resultfile seqfile.result${SIM} --innerfile passed_outinner_sequence.fasta --sequencefile $SEQFILE
makeblastdb -in lLTRs_Seq_For_BLAST.fasta -dbtype nucl
makeblastdb -in Inner_Seq_For_BLAST.fasta -dbtype nucl
blastn -query lLTRs_Seq_For_BLAST.fasta -db lLTRs_Seq_For_BLAST.fasta -evalue 1e-10 -num_descriptions 1000 -out lLTRs_Seq_For_BLAST.fasta.out
blastn -query Inner_Seq_For_BLAST.fasta -db Inner_Seq_For_BLAST.fasta -evalue 1e-10 -num_descriptions 1000 -out Inner_Seq_For_BLAST.fasta.out
$DIR_CRL/CRL_Step5.pl --LTR_blast lLTRs_Seq_For_BLAST.fasta.out --inner_blast Inner_Seq_For_BLAST.fasta.out --step3 CRL_Step3_Passed_Elements.fasta --final LTR${SIM}.lib --pcoverage 90 --pidentity 80

