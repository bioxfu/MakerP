## create conda environment
conda create -n repeat_lib_tool blast blast-legacy mdust muscle rmblast hmmer genometools-genometools seqkit
source activate repeat_lib_tool

mkdir repeat_lib_tool && cd repeat_lib_tool

## install RECON
wget -c http://www.repeatmasker.org/RepeatModeler/RECON-1.08.tar.gz
tar xzf RECON-1.08.tar.gz
cd RECON-1.08/src && make && make install
cd -
## install RepeatScout
wget -c http://www.repeatmasker.org/RepeatScout-1.0.5.tar.gz
tar xzf RepeatScout-1.0.5.tar.gz
cd RepeatScout-1 && make
cd -
## install TRF
mkdir TRF && cd TRF
wget -c https://tandem.bu.edu/trf/downloads/trf404.linux64 -O trf
chmod +x trf
cd -
## install NSEG
mkdir NSEG && cd NSEG
wget ftp://ftp.ncbi.nih.gov/pub/seg/nseg/*
make
cd -
## install RepeatModeler
wget -c  http://www.repeatmasker.org/RepeatModeler/RepeatModeler-open-1.0.11.tar.gz
tar zxf RepeatModeler-open-1.0.11.tar.gz
cd RepeatModeler-open-1.0.11
perl configure
echo -e '\nexport PATH=$HOME/Git/MakerP/repeat_lib_tool/RepeatModeler-open-1.0.11:$PATH\n' >> ~/.bashrc
source ~/.bashrc
source activate repeat_lib_tool


## install MITE-Hunter
wget -c http://target.iplantcollaborative.org/mite_hunter/MITE%20Hunter-11-2011.zip -O MITE-Hunter.zip 
unzip MITE-Hunter.zip && rm -rf __MACOSX && mv MITE\ Hunter MITE-Hunter
cd MITE-Hunter
perl MITE_Hunter_Installer.pl -d $PWD/ -f formatdb -b blastall -m mdust -M muscle
cd -
## install CRL and other custom scripts
wget -c http://www.hrt.msu.edu/uploads/535/78637/CRL_Scripts1.0.tar.gz
tar zxf CRL_Scripts1.0.tar.gz
## install HMMER
wget -c http://eddylab.org/software/hmmer/hmmer-3.0.tar.gz
tar zxf hmmer-3.0.tar.gz
cd hmmer-3.0
./configure prefix=$PWD
make
make install
cd easel
make install
mv bin binaries
cd -
## install ProtExcluder
wget -c http://weatherby.genetics.utah.edu/MAKER/data/ProtExcluder1.1.tar.gz
tar xzf ProtExcluder1.1.tar.gz
cd ProtExcluder1.1 
./Installer.pl -m $PWD/../hmmer-3.0/ -p $PWD/
cd -


## download DNA/all transposase protein database and plant protein database
mkdir blastdb
wget -c http://www.hrt.msu.edu/uploads/535/78637/Tpases020812DNA.gz -P blastdb
wget -c http://www.hrt.msu.edu/uploads/535/78637/Tpases020812.gz -P blastdb
wget -c http://www.hrt.msu.edu/uploads/535/78637/alluniRefprexp070416.gz -P blastdb
gzip -d blastdb/Tpases020812DNA.gz
gzip -d blastdb/Tpases020812.gz
gzip -d blastdb/alluniRefprexp070416.gz 
makeblastdb -in blastdb/Tpases020812DNA -dbtype prot
makeblastdb -in blastdb/Tpases020812 -dbtype prot
makeblastdb -in blastdb/alluniRefprexp070416 -dbtype prot

