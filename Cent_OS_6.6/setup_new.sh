rpm -Uvh http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum makecache
yum install -y vim tmux htop wget
yum install -y gcc

yum remove aclocal automake autoconf -y

wget http://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz
tar -zxvf autoconf-latest.tar.gz -C ./autoconf
cd autoconf
./configure --prefix=/usr/local
make && make install
cd ..

wget http://ftp.gnu.org/gnu/automake/automake-1.13.tar.gz
tar -zxvf automake-1.13.tar.gz
cd automake-1.13
./configure --prefix=/usr/local
make && make install
cd ..

#wget http://gnu.mirrors.hoobly.com/gnu/libtool/libtool-2.4.2.tar.gz
#tar -zxvf libtool-2.4.2.tar.gz
#cd libtool-2.4.2
#./configure --prefix=/usr
#make && make install
#cd ..
