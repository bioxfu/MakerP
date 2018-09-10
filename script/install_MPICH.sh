# Download source code
VERSION=3.2.1
wget -c http://www.mpich.org/static/downloads/${VERSION}/mpich-${VERSION}.tar.gz
wget -c http://www.mpich.org/static/downloads/${VERSION}/mpich-${VERSION}-installguide.pdf

# Unpack the tar file.
tar xfz mpich-${VERSION}.tar.gz

# Choose an installation directory (the default is /usr/local/bin):
mkdir -p $HOME/opt/mpich-install-${VERSION}

# Choose a build directory
mkdir -p $HOME/opt/mpich-build-${VERSION}

# Configure MPICH
cd $HOME/opt/mpich-build-${VERSION}
$HOME/Git/MakerP/mpich-${VERSION}/configure --prefix=$HOME/opt/mpich-install-${VERSION} --enable-shared |& tee c.txt

# Build MPICH
make 2>&1 | tee m.txt

# Install the MPICH commands
make install |& tee mi.txt

# Add the bin subdirectory of the installation directory to your path
echo -e "\n# add MPICH $VERSION to PATH\nexport PATH=$HOME/opt/mpich-install-${VERSION}/bin:\$PATH\n" >> ~/.bashrc
. ~/.bashrc
which mpicc
which mpiexec

# Set LD_PRELOAD to the location of libmpi.so 
echo -e "\n export LD_PRELOAD=$HOME/opt/mpich-install-3.2.1/lib/libmpi.so\n" >> ~/.bash_profile
. ~/.bash_profile

