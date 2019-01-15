## Plant Genome Annotation by MAKER-P
### 0. Install required softwares (optional)
```
./script/install_MPICH.sh
./script/install_MakerP.sh
./script/install_InterProScan.sh
./script/install_repeat_lib_tools.sh
```

### 1. Download protein evidence from UniProt/SwissProt
```
mkdir sprot
DATE=`date +"%Y%m%d"`
wget -c ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/taxonomic_divisions/reldate.txt -O sprot/reldate_${DATE}.txt
wget -c ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/taxonomic_divisions/uniprot_sprot_plants.dat.gz -O sprot/uniprot_sprot_plants_${DATE}.dat.gz

# convert swissprot to fasta
source activate gmatic
./script/swissprot2fasta.py sprot/uniprot_sprot_plants_20180906.dat.gz > sprot/uniprot_sprot_plants.fa
```
### 2. *De novo* transcriptome assembly by Trinity
```
# merge biology replicates
mkdir -p trinity/raw
DATAPATH=/cluster/oldgroup/extremophiles/rawdata/millet/proso_millet/mRNA/EPGSP0001

for NAME in 1-3D 1W 3W-S 8W-In 8W-L 8W-R 8W-S MS
do
    ls $DATAPATH/*${NAME}*/*_R1_001.fastq.gz|xargs -I {} cat {} >> trinity/raw/${NAME}_R1.fastq.gz
    ls $DATAPATH/*${NAME}*/*_R2_001.fastq.gz|xargs -I {} cat {} >> trinity/raw/${NAME}_R2.fastq.gz
done

# clean reads
adapter=$HOME/miniconda2/envs/gmatic/share/trimmomatic/adapters/TruSeq3-PE-2.fa
cd trinity/raw

for NAME in 1-3D 1W 3W-S 8W-In 8W-L 8W-R 8W-S MS
do
    echo $NAME
    nohup trimmomatic PE -threads 3 -phred33 ${NAME}_R1.fastq.gz ${NAME}_R2.fastq.gz ${NAME}_R1_paired.fastq.gz ${NAME}_R1_unpaired.fastq.gz ${NAME}_R2_paired.fastq.gz ${NAME}_R2_unpaired.fastq.gz ILLUMINACLIP:${adapter}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 &
done

cd - && mkdir -p trinity/clean trinity/fastqc
mv trinity/raw/*_paired.fastq.gz trinity/clean 
rm trinity/raw/*_unpaired.fastq.gz

nohup fastqc -o trinity/fastqc -t 16 trinity/clean/*.fastq.gz &

# run trinity (v2.6.6)
mkdir trinity/assembly
find trinity/clean/*_R1_paired.fastq.gz -printf "%f\n"|sed -r 's/_R1.+//'|xargs -I {} Trinity --seqType fq --max_memory 100G --left trinity/clean/{}_R1_paired.fastq.gz --right trinity/clean/{}_R2_paired.fastq.gz --CPU 10 --SS_lib_type RF --output trinity/assembly/trinity_output_{} &
disown

# Sometimes Trinity seems to run forever, just kill the process and run it again.
# Before you rerun the Trinity, check the FailedCommands file and remove the failed command from recursive_trinity.cmds.ok file

# run CD-Hit
for NAME in 8W-R 8W-S MS
do
    echo $NAME
    nohup cd-hit-est -i trinity/assembly/trinity_output_${NAME}/Trinity.fasta -o trinity/assembly/trinity_output_${NAME}/Trinity_nr80.fasta -c 0.8 -n 4 -T 20 -M 0 &
done
```
### 3. Repeat library construction - [Advanced](http://weatherby.genetics.utah.edu/MAKER/wiki/index.php/Repeat_Library_Construction-Advanced)
```
mkdir repeat

# set environment variable
source activate repeat_lib_tool
ROOT=$PWD
GENOMEPATH=$ROOT/genome
GENOME=Pm_genome_V2.4.fasta
PREFIX=Pm
SEQFILE=$GENOMEPATH/Pm_genome_V2.4_formatID.fasta
SEQINDEX=$GENOMEPATH/Pm_genome_V2.4_formatID_index
TRNA=$HOME/Gmatic7/GtRNAdb/eukaryotic-tRNAs.fa
DIR_CRL=$ROOT/repeat_lib_tool/CRL_Scripts1.0
TPASES_DNA=$ROOT/repeat_lib_tool/blastdb/Tpases020812DNA
TPASES=$ROOT/repeat_lib_tool/blastdb/Tpases020812
PLANT_PROT=$ROOT/repeat_lib_tool/blastdb/alluniRefprexp070416
RM_DIR=$ROOT/maker/exe/RepeatMasker/
ProtEx_DIR=$ROOT/repeat_lib_tool/ProtExcluder1.1

# FASTA sequence IDs must NOT have "_" or "." in them for this pipeline to function properly
cat $GENOMEPATH/$GENOME | sed -r 's/_.+//' > $SEQFILE

# find MITEs (miniature inverted repeat transposable elements)
perl repeat_lib_tool/MITE-Hunter/MITE_Hunter_manager.pl -i $SEQFILE -g $PREFIX -n 30 -c 30 -S 12345678
cat ${PREFIX}_Step8_*.fa > repeat/MITE.lib
rm ${PREFIX}* *.log

# build GenomeTools index
gt suffixerator -db $SEQFILE -indexname $SEQINDEX -tis -suf -lcp -des -ssp -dna

# find relatively recent LTR retrotransposons (LTR99)
mkdir repeat/LTR_recent && cd repeat/LTR_recent
../../script/find_LTR_recent.sh $SEQINDEX $TRNA $DIR_CRL $ROOT/repeat/MITE.lib $TPASES_DNA $RM_DIR
cd -

# find relatively old LTR retrotransposons (LTR85)
mkdir repeat/LTR_old && cd repeat/LTR_old
../../script/find_LTR_old.sh $SEQINDEX $TRNA $DIR_CRL $ROOT/repeat/MITE.lib $TPASES_DNA $RM_DIR
cd -

# remove the LTR99.lib sequences masked from the LTR85.lib
# and combine recent and old LTR
cd repeat
$RM_DIR/RepeatMasker -pa 30 -lib LTR_recent/LTR99.lib -dir LTR_old LTR_old/LTR85.lib
$DIR_CRL/remove_masked_sequence.pl --masked_elements LTR_old/LTR85.lib.masked --outfile LTR_old/FinalLTR85.lib
cat LTR_recent/LTR99.lib LTR_old/FinalLTR85.lib|sed 's/(/[/'|sed 's/)/]/' > allLTR.lib
cat allLTR.lib MITE.lib > allMITE_LTR.lib
cd -

# mask and remove MITE and LTR from genome
./script/remove_masked_MITE_LTR.sh $SEQFILE $RM_DIR

# collect repetitive sequences by RepeatModeler (takes a long time)
mkdir repeat/RepeatModeler && cd repeat/RepeatModeler
BuildDatabase -name umseqfiledb -engine ncbi ${SEQFILE}.umseqfile.fa
nohup RepeatModeler -engine ncbi -pa 30 -database umseqfiledb >& umseqfile.out

# generate known and unknown model
RM=`ls|grep 'RM_'`
$DIR_CRL/repeatmodeler_parse.pl --fastafile $RM/consensi.fa.classified --unknowns repeatmodeler_unknowns.fasta --identities repeatmodeler_identities.fasta 
blastx -num_threads 30 -query repeatmodeler_unknowns.fasta -db $TPASES -evalue 1e-10 -num_descriptions 10 -out modelerunknown_blast_results.txt
$DIR_CRL/transposon_blast_parse.pl --blastx modelerunknown_blast_results.txt --modelerunknown repeatmodeler_unknowns.fasta
cat unknown_elements.txt > ../ModelerUnknown.lib
cat identified_elements.txt repeatmodeler_identities.fasta > ../ModelerID.lib
cd ..

# exclusion of gene fragments
blastx -num_threads 30 -query MITE.lib -db $PLANT_PROT -evalue 1e-10 -num_descriptions 10 -out MITE.lib_blast_results.txt
blastx -num_threads 30 -query allLTR.lib -db $PLANT_PROT -evalue 1e-10 -num_descriptions 10 -out allLTR.lib_blast_results.txt
blastx -num_threads 30 -query ModelerID.lib -db $PLANT_PROT -evalue 1e-10 -num_descriptions 10 -out ModelerID.lib_blast_results.txt
blastx -num_threads 30 -query ModelerUnknown.lib -db $PLANT_PROT -evalue 1e-10 -num_descriptions 10 -out ModelerUnknown.lib_blast_results.txt

$ProtEx_DIR/ProtExcluder.pl MITE.lib_blast_results.txt MITE.lib
$ProtEx_DIR/ProtExcluder.pl allLTR.lib_blast_results.txt allLTR.lib
$ProtEx_DIR/ProtExcluder.pl ModelerID.lib_blast_results.txt ModelerID.lib
$ProtEx_DIR/ProtExcluder.pl ModelerUnknown.lib_blast_results.txt ModelerUnknown.lib
rm *_blast_results.txt* *.libnPr *.ssi temp

cat MITE.libnoProtFinal allLTR.libnoProtFinal ModelerID.libnoProtFinal > KnownRepeats.lib
cat KnownRepeats.lib ModelerUnknown.libnoProtFinal > allRepeats.lib
```
