mysqlroot="cerNet2"
cactidb="cacti"
cactidbown="cactiuser"
mysqlcacti="cactisecret"

cacti_home="/usr/share/cacti"
workingpath=$(pwd)
plugins_path="${path}/plugins"

#base setup
function base_setup()
{
    rpm -Uvh http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
    yum makecache
    yum install -y vim tmux htop wget
}
#install LAMP

function install_lamp()
{
yum install -y httpd mysql-server php phpMyAdmin

#configure mysql

service mysqld restart
#=================================
# DB    | OWNER    | PASSWORD    |
#---------------------------------
# mysql | root     | cerNet2     |
#=================================

mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';"
mysql -e "DROP DATABASE test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "UPDATE mysql.user SET Password=PASSWORD('$mysqlroot') WHERE User='root';"
mysql -e "FLUSH PRIVILEGES;"

# set ACL(s) for phpMyAdmin
#sed -i '/166.111.143.192/d' /etc/httpd/conf.d/phpMyAdmin.conf
#sed -i '/Allow from ::1/i\\   Allow from 166.111.143.192/26' /etc/httpd/conf.d/phpMyAdmin.conf

# start apache to access http://localhost/phpmyadmin
service httpd restart
}

function install_rrdtool(){
#install rrdtool
yum install -y rrdtool

#update rrdtool
wget http://packages.express.org/rrdtool/rrdtool-1.4.7-1.el6.wrl.x86_64.rpm
wget http://packages.express.org/rrdtool/rrdtool-devel-1.4.7-1.el6.wrl.x86_64.rpm
wget http://packages.express.org/rrdtool/rrdtool-perl-1.4.7-1.el6.wrl.x86_64.rpm
yum localinstall rrdtool-1.4.7-1.el6.wrl.x86_64.rpm rrdtool-devel-1.4.7-1.el6.wrl.x86_64.rpm rrdtool-perl-1.4.7-1.el6.wrl.x86_64.rpm

}
#install cacti

function install_cacti(){
yum install -y cacti

#configure cacti
# create and setup MySQL databases for Cacti and Syslog, then import the tables
#=================================
# DB    | OWNER    | PASSWORD    |
#---------------------------------
# cacti | cactiuser| cactisecret |
#---------------------------------
# syslog| cactiuser| cactisecret |
#=================================
#
#mysqladmin --user=root --password=$mysqlroot create cacti
mysql --user=root --password=$mysqlroot -e 'CREATE DATABASE `cacti` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql --user=root --password=$mysqlroot -e 'CREATE DATABASE `syslog` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'

# create MySQL username and password for cacti/syslog database
mysql --user=root --password=$mysqlroot -e "GRANT ALL ON cacti.* TO cactiuser@localhost IDENTIFIED BY '$mysqlcacti';"
mysql --user=root --password=$mysqlroot -e "GRANT ALL ON syslog.* TO cactiuser@localhost IDENTIFIED BY '$mysqlcacti';"
mysql --user=root --password=$mysqlroot -e "FLUSH PRIVILEGES;"

# import the default cacti database
mysql --user=root --password=$mysqlroot cacti < /usr/share/doc/cacti-0.8.8b/cacti.sql
}

function install_plugins()
{
which wget > /dev/null 2>&1 || yum install wget -y
which unzip > /dev/null 2>&1 || yum install unzip -y
which svn > /dev/null 2>&1 || yum install subversion -y
cd ${plugins_path}

# 1. plugins packaged in tarball
for url in http://docs.cacti.net/_media/plugin:settings-v0.71-1.tgz \
  http://docs.cacti.net/_media/plugin:clog-v1.7-1.tgz \
  http://docs.cacti.net/_media/plugin:cycle-v2.3-1.tgz \
  http://docs.cacti.net/_media/plugin:errorimage-v0.2-1.tgz \
  http://docs.cacti.net/_media/plugin:aggregate-v0.75.tgz \
  http://docs.cacti.net/_media/plugin:spikekill-v1.3-2.tgz \
  http://docs.cacti.net/_media/plugin:docs-v0.4-1.tgz \
  http://docs.cacti.net/_media/plugin:monitor-v1.3-1.tgz \
  http://docs.cacti.net/_media/plugin:thold-v0.5.0.tgz \
  http://docs.cacti.net/_media/plugin:discovery-v1.5-1.tgz \
  http://docs.cacti.net/_media/plugin:hmib-v1.4-2.tgz \
  http://docs.cacti.net/_media/plugin:nectar-v0.35a.tgz \
  http://docs.cacti.net/_media/plugin:dsstats-v1.4-1.tgz \
  http://docs.cacti.net/_media/plugin:autom8-v0.35.tgz \
  http://docs.cacti.net/_media/plugin:mactrack-v2.9-1.tgz \
  http://docs.cacti.net/_media/plugin:realtime-v0.5-2.tgz \
  http://docs.cacti.net/_media/plugin:rrdclean-v0.41.tgz \
  http://docs.cacti.net/_media/plugin:boost-v5.1-1.tgz \
  http://docs.cacti.net/_media/plugin:ugroup-v0.2-2.tgz \
  http://docs.cacti.net/_media/plugin:slowlog-v1.3-1.tgz \
  http://docs.cacti.net/_media/plugin:flowview-v1.1-1.tgz \
  http://docs.cacti.net/_media/plugin:ntop-v0.2-1.tgz \
  http://docs.cacti.net/_media/plugin:domains-v0.1-1.tgz \
  http://docs.cacti.net/_media/plugin:remote_v01.tar.gz \
  http://docs.cacti.net/_media/plugin:routerconfigs-v0.3-1.tgz \
  http://docs.cacti.net/_media/plugin:mikrotik_v1.0.tar.gz \
  http://docs.cacti.net/_media/plugin:syslog-v1.22-2.tgz \
  http://sourceforge.net/projects/gibtmirdas/files/npc-2.0.4.tar.gz \
  http://sourceforge.net/projects/murlin/files/mURLin-0.2.4.tar.gz \
  http://runningoffatthemouth.com/unifiedtrees-latest.tgz \
  https://github.com/Super-Visions/cacti-plugin-acceptance/archive/acceptance-v1.1.1.tar.gz
do
  name=${url##*/}
  name=${name##*:}
  name=${name%%-*}
  name=${name%%_*}
  [ ! -f $name.tgz ] && wget $url -O $name.tgz
  [ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
  tar xfpz $name.tgz -C ${cacti_home}/plugins
done

name=reportit
[ ! -f $name.tgz ] && wget http://sourceforge.net/projects/cacti-reportit/files/latest/download -O $name.tgz
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
tar xfpz $name.tgz -C ${cacti_home}/plugins

name=dashboard
if [ ! -f $name.tgz ]; then
  wget http://docs.cacti.net/_media/userplugin:dashboardv_v1.2.tar -O $name.tar
  gzip $name.tar
  mv $name.tar.gz $name.tgz
fi
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
tar xfpz $name.tgz -C ${cacti_home}/plugins

name=mobile
[ ! -f $name.tgz ] && wget http://docs.cacti.net/_media/plugin:mobile-latest.tgz  -O $name.tgz
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
tar xfpz $name.tgz -C ${cacti_home}/plugins
mv ${cacti_home}/plugins/$name-0.1 ${cacti_home}/plugins/$name

name=loginmod
[ ! -f $name.tgz ] && wget  http://docs.cacti.net/_media/plugin:loginmod-latest.tgz  -O $name.tgz
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
tar xfpz $name.tgz -C ${cacti_home}/plugins
mv ${cacti_home}/plugins/$name-1.0 ${cacti_home}/plugins/$name

# 2. plugins packaged with zip
for url in http://thingy.com/haj/cacti/superlinks-0.8.zip \
  http://thingy.com/haj/cacti/titlechanger-0.1.zip \
  http://thingy.com/haj/cacti/quicktree-0.2.zip \
  http://gilles.boulon.free.fr/manage/manage-0.6.2.zip \
  http://docs.cacti.net/_media/userplugin:timeshift-0.1.1.zip \
  http://docs.cacti.net/_media/userplugin:predict_1.0.0.zip
do
  name=${url##*/}
  name=${name##*:}
  name=${name%%-*}
  name=${name%%_*}
  [ ! -f $name.zip ] && wget $url -O $name.zip
  [ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
  unzip -q $name.zip -d ${cacti_home}/plugins
done

name=weathermap
[ ! -f $name.zip ] && wget http://network-weathermap.com/files/php-weathermap-0.97c.zip -O $name.zip
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
unzip -q $name.zip -d ${cacti_home}/plugins


# 3. plugins downloaded from web forum 

name=cdnd
[ ! -f $name.tgz ] && wget -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36' 'http://forums.cacti.net/download/file.php?id=29886' -O $name.tgz
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
tar xfpz $name.tgz -C ${cacti_home}/plugins

name=intropage
[ ! -f $name.tgz ] && wget -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36' 'http://forums.cacti.net/download/file.php?id=29498&sid=f873048221497fa62591429927732777' -O ${name}.tgz
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
tar xfpz $name.tgz -C ${cacti_home}/plugins
cd ${cacti_home}/plugins/$name; patch -p1 < ${plugins_path}/$name.patch; cd ${plugins_path}

name=watermark
#wget -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36' 'http://forums.cacti.net/download/file.php?id=16973' -O $name.zip
[ ! -f $name.tgz ] && wget -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36' 'http://forums.cacti.net/download/file.php?id=28440' -O $name.tgz
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
tar xfpz $name.tgz -C ${cacti_home}/plugins

name=jqueryskin
[ ! -f $name.tgz ] && wget -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36' 'http://forums.cacti.net/download/file.php?id=28439' -O $name.tgz
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
tar xfpz $name.tgz -C ${cacti_home}/plugins

# 4. plugins check out from svn/cvs/github
name=maint
if [ ! -f $name.tgz ] ; then 
  svn co svn://svn.cacti.net/cacti_plugins/maint/trunk 
  if [ -d trunk ] ; then
    mv trunk $name
    tar cfpz $name.tgz $name
    rm -fr $name
  fi
fi
[ -d ${cacti_home}/plugins/$name ] && rm -fr ${cacti_home}/plugins/$name
tar xfpz $name.tgz -C ${cacti_home}/plugins
 

# plugins need to be patched and/or configured

# weathermap
# bug fix: wrong version no
sed -i 's/97b/97c/' ${cacti_home}/plugins/weathermap/setup.php
# enable editing
sed -i 's/^$ENABLED=false;/$ENABLED=true;/' ${cacti_home}/plugins/weathermap/editor.php
# split() oboleted
sed -i 's/$parts = split/$parts = explode/' ${cacti_home}/plugins/weathermap/editor.php
# keep generated htmls and images
output=${cacti_home}/plugins/weathermap/output
#chown -R cacti:apache ${output}
#chmod  g+w ${output}/  ${output}/*
# easy and simple but secure way to configure SELinux to allow the Apache/httpd to 
# write at the Weathemaps configs folder without disable it
chcon -R -t httpd_cache_t ${cacti_home}/plugins/weathermap/configs

# superlinks
# configure SELinux to allow superlinks accessible
chcon -R -t httpd_cache_t ${cacti_home}/plugins/superlinks/

# thold
# bug fix: some graphs invisible
sed -i 's/explode('"'"'"'"'"'/explode("'"'"'"/g' ${cacti_home}/plugins/thold/setup.php

# monitor
# for mointor to show thold breach legend
sed -i '/^if (in_array(/a\\if (true) {' ${cacti_home}/plugins/monitor/monitor.php
sed -i 's/^if (in_array(/\/\/if (in_array(/' ${cacti_home}/plugins/monitor/monitor.php
sed -i '/^$thold = (in_array(/a\\$thold = true;' ${cacti_home}/plugins/monitor/monitor.php
#sed -i '$i\$plugins[]='"'"'thold'"'"';' ${cacti_home}/include/config.php

# realtime
# cache image generated on-the-fly
install -d -m 755 ${cacti_home}/plugins/realtime/cache
#Console > Settings > Misc > Cache Directory ${cacti_home}/plugins/realtime/cache

# autom8
mv ${cacti_home}/plugins/trunk ${cacti_home}/plugins/autom8

# acceptance
mv ${cacti_home}/plugins/cacti-plugin-acceptance-acceptance-v1.1.1 ${cacti_home}/plugins/acceptance

# syslog
install -m 644 syslog-partitions.sql $cacti_home/plugins/syslog
install -m 644 syslog-plugin-setup.sql $cacti_home/plugins/syslog
mysql --user=root --password=$mysqlroot syslog < $cacti_home/plugins/syslog/syslog-partitions.sql
mysql --user=root --password=$mysqlroot cacti < $cacti_home/plugins/syslog/syslog-plugin-setup.sql

# quicktree
cd ${cacti_home}/plugins/quicktree; patch -p1 < ${plugins_path}/quicktree.patch; cd ${plugins_path}

# manage
cd ${cacti_home}/plugins/manage/sql; patch -p0 < ${plugins_path}/9-uninstall.sql.patch ; cd ${plugins_path}

# boost
install -d -m 755 ${cacti_home}/plugins/boost/cache
chmod -R 755 ${cacti_home}/plugins/boost/cache
install -m 755 ${cacti_home}/plugins/boost/cacti_rrdsvc /etc/rc.d/init.d
chkconfig --add cacti_rrdsvc

# extra directory making and permisson setting

chown apache:apache -R ${cacti_home}/plugins
chown apache:apache -R ${cacti_home}/scripts
chmod 755 ${cacti_home}/scripts
chown apache:apache -R ${cacti_home}/resource
chmod 755 ${cacti_home}/resource
chmod 755 ${cacti_home}/resource/script_queries
chmod 755 ${cacti_home}/resource/script_server
chmod 755 ${cacti_home}/resource/snmp_queries

#rrdclean
install -d -m 755 ${cacti_home}/rra/backup
chown cacti:root ${cacti_home}/rra/backup
install -d -m 755 ${cacti_home}/rra/archive
chown cacti:root ${cacti_home}/rra/archive

}



