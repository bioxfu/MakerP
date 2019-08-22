source activate maker

#### merge biology replicates
mkdir -p RNA-Seq/raw/EPGSP0001
DATAPATH=/cluster/oldgroup/extremophiles/rawdata/millet/proso_millet/mRNA/EPGSP0001

for NAME in 1-3D 1W 3W-S 8W-In 8W-L 8W-R 8W-S MS
do
	ls $DATAPATH/*${NAME}*/*_R1_001.fastq.gz|xargs -I {} cat {} >> RNA-Seq/raw/EPGSP0001/${NAME}_R1.fastq.gz
	ls $DATAPATH/*${NAME}*/*_R2_001.fastq.gz|xargs -I {} cat {} >> RNA-Seq/raw/EPGSP0001/${NAME}_R2.fastq.gz
done

#### clean reads
adapter=/cluster/home/xfu/miniconda2/envs/maker/share/trimmomatic/adapters/TruSeq3-PE-2.fa
cd RNA-Seq/raw/EPGSP0001/

for NAME in 1-3D 1W 3W-S 8W-In 8W-L 8W-R 8W-S MS
do
	echo $NAME
	nohup trimmomatic PE -threads 3 -phred33 ${NAME}_R1.fastq.gz ${NAME}_R2.fastq.gz ${NAME}_R1_paired.fastq.gz ${NAME}_R1_unpaired.fastq.gz ${NAME}_R2_paired.fastq.gz ${NAME}_R2_unpaired.fastq.gz ILLUMINACLIP:${adapter}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 &
done
cd -

mkdir -p RNA-Seq/clean/EPGSP0001
cat RNA-Seq/raw/EPGSP0001/*_R1_paired.fastq.gz > RNA-Seq/clean/EPGSP0001/all_R1.fastq.gz 
cat RNA-Seq/raw/EPGSP0001/*_R2_paired.fastq.gz > RNA-Seq/clean/EPGSP0001/all_R2.fastq.gz 
rm RNA-Seq/raw/EPGSP0001/*paired.fastq.gz

mkdir RNA-Seq/clean/EPGSP0001/fastqc
fastqc -o RNA-Seq/clean/EPGSP0001/fastqc -t 2 RNA-Seq/clean/EPGSP0001/all_R*.fastq.gz 

#### in silico read normalization
# Issue with fastool when parsing compressed files
# https://github.com/trinityrnaseq/trinityrnaseq/issues/190
MAX_COV=30
nohup insilico_read_normalization.pl --seqType fq --JM 100G --max_cov $MAX_COV --left RNA-Seq/clean/EPGSP0001/all_R1.fastq.gz --right RNA-Seq/clean/EPGSP0001/all_R2.fastq.gz --pairs_together --PARALLEL_STATS --CPU 10 --output RNA-Seq/normalization_${MAX_COV}X &

#### de nove assembly 
nohup Trinity --seqType fq --max_memory 100G --left RNA-Seq/normalization_${MAX_COV}X/left.norm.fq --right RNA-Seq/normalization_${MAX_COV}X/right.norm.fq --CPU 20 --SS_lib_type RF --no_normalize_reads --output trinity_out_dir_${MAX_COV}X &

#### examine the statistic
TrinityStats.pl trinity_out_dir_${MAX_COV}X/Trinity.fasta > trinity_out_dir_${MAX_COV}X/Trinity.fasta.statistic

#### CD-Hit
cp trinity_out_dir_${MAX_COV}X/Trinity.fasta Trinity_30X.fasta 
cd-hit-est -i Trinity_30X.fasta -o Trinity_30X_nr80.fasta -c 0.8 -n 4 -T 20 -M 0

