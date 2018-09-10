SEQFILE=$1
RM_DIR=$2

# the genomic sequence is masked by (allLTR.lib + MITE.lib = allMITE_LTR.lib)
# split the genome into small files
seqkit split -s 1 $SEQFILE
mkdir repeat/seq_split && cd repeat/seq_split
find ../../${SEQFILE}.split/*.fasta|parallel --gnu "$RM_DIR/RepeatMasker -lib ../allMITE_LTR.lib -dir . {}"
cat *.masked > ${SEQFILE}.masked
cd -

## remove the masked elements
source activate gmatic
./script/rmaskedpart.py ${SEQFILE}.masked > ${SEQFILE}.umseqfile.fa
