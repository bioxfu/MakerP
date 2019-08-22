# http://weatherby.genetics.utah.edu/MAKER/wiki/index.php/MAKER_Tutorial_for_WGS_Assembly_and_Annotation_Winter_School_2018
wget http://weatherby.genetics.utah.edu/data/maker_tutorial.tgz
tar -zxf maker_tutorial.tgz

# A minimal input file set for MAKER would generally consist of a FASTA file for the genomic sequence, 
# a FASTA file of RNA (ESTs/cDNA/mRNA transcripts) from the organism, 
# and a FASTA file of protein sequences from the same or related organisms (or a general protein database). 

cd maker_tutorial/example_01_basic

# You can create a set of generic configuration files in the current working directory by typing the following.
maker -CTL

# This creates three files:
#     maker_exe.ctl - contains the path information for the underlying executables.
#     maker_bopt.ctl - contains filtering statistics for BLAST and Exonerate
#     maker_opt.ctl - contains all other information for MAKER, including the location of the input genome file. 
cp opts1.txt maker_opts.ctl
maker

mpiexec -n 4 maker 

# merge files containing all of your output (i.e. a single GFF3 and FASTA file containing all genes)
cd dpp_contig.maker.output
fasta_merge -d dpp_contig_master_datastore_index.log
gff3_merge -d dpp_contig_master_datastore_index.log

# loading MAKER's output into JBrowse by running maker2jbrowse inside of the JBrowse installation directory 
maker2jbrowse

 cp opts2.txt maker_opts.ctl

# Most MPI programs can be run with the command mpiexec

source activate maker
conda env export > environment.yml
conda env create -f environment.yml

/home/xfu/miniconda2/envs/maker/bin/mpicc
/home/xfu/miniconda2/envs/maker/include/mpi.h
/usr/bin/mpicc 
/usr/include/mpi

/home/xfu/miniconda2/envs/maker/lib/libmpi.so