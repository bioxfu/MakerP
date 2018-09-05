# Download MAKER from http://www.yandell-lab.org/software/maker.html
wget -c http://yandell.topaz.genetics.utah.edu/maker_downloads/80D0/C130/B4C0/D84D2F0BB497AD6E0090F1CB01C3/maker-2.31.10.tgz
tar zxf maker-2.31.10.tgz

mkdir maker-3 && cd maker-3 
wget -c http://yandell.topaz.genetics.utah.edu/maker_downloads/80D0/C130/B4C0/D84D2F0BB497AD6E0090F1CB01C3/maker-3.01.02-beta.tgz
tar zxf maker-3.01.02-beta.tgz && cd ..
cp ./maker-3/maker/src/bin/*.pl maker/src/bin

cd maker/src/
perl Build.PL

# configure for MPI
# path to mpicc: /home/xfu/opt/mpich-install-3.2.1/bin/mpicc
# path to the directory containing mpi.h: /home/xfu/opt/mpich-install-3.2.1/include

./Build status           #Shows a status menu
./Build installdeps      #installs missing PERL dependencies
./Build installexes      #installs missing external programs
# RepBase_username=fengkuang
# RepBase_password=a1lovt

./Build snap        #installs SNAP
./Build augustus    #installs Augustus
#./Build jbrowse     #installs JBrowse (MAKER copy, not web accecible)
#./Build webapollo   #installs WebApollo (use maker2wap to create DBs); 

./Build install          #installs MAKER
echo -e "\n# add MAKER to PATH\nexport PATH=$HOME/Git/MakerP/maker/bin:\$PATH\n" >> ~/.bashrc
echo -e "\nexport ZOE=$HOME/Git/MakerP/maker/exe/snap/Zoe\n" >> ~/.bashrc
echo -e "\nexport AUGUSTUS_CONFIG_PATH=$HOME/Git/MakerP/maker/exe/augustus/config\n" >> ~/.bashrc
. ~/.bashrc

# if Repeatmasker can't locate Text/Soundex.pm
# cpan Text::Soundex


