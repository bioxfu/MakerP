mkdir interproscan
cd interproscan
wget -c ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.30-69.0/interproscan-5.30-69.0-64-bit.tar.gz
wget -c ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.30-69.0/interproscan-5.30-69.0-64-bit.tar.gz.md5
md5sum -c interproscan-5.30-69.0-64-bit.tar.gz.md5

tar -pxvzf interproscan-5.30-69.0-*-bit.tar.gz

