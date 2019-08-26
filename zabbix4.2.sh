#!/bin/sh

export PATH=

# 1、下载zabbix版本：
	get() {
	wget https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.0.1/zabbix-4.0.1.tar.gz
	wget https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.2.1/zabbix-4.2.1.tar.gz
	}
# 2、解决以来关系：
	yum install mariadb mariadb-devel libxml2 libxml2-devel  libcurl libcurl-devel net-snmp-devel  net-snmp-utils  libevent libevent-devel -y
sleep 3
# 3、搭建LAMP 环境平台：
	lamp_install() {
	yum install -y mariadb mariadb-server mariadb-devel php php-devel php-mysql httpd
	systemctl start httpd
	systemctl start mariadb
# 3.1、修改php.ini 的时区
	sed -i '878idate.timezone = Asia/Shanghai' /etc/php.ini
# 5.2、创建测试页：
	echo '<?php echo phpinfo();?>' > var/www/html/test.php
#	5.3、登录数据库创建zabbix库：
	mysql -u root -p  -e "create database zabbix character set utf8 collate utf8_bin;
	grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
	flush privileges;"
	}
# 4、解压安装zabbix 4.2.1 版本
	install_zabbix() {
		tar xf zabbix-4.2.1.tar.gz -C /usr/src
		cd /usr/src/zabbix-4.2.1
		./configure   --enable-server --enable-porxy --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 && make && make install
		ln -s /usr/local/zabbix4.0/sbin/* /usr/local/sbin
		ln -s /usr/local/zabbix4.0/bin/* /usr/local/bin
		ln -s /usr/local/zabbix4.0/etc/* /usr/local/etc
		RAEVLE=$?
		return raevle
	}

# 5、创建zabbix web 目录
	web_zabbix() {
		mkdir /var/www/html/zabbix
		cp -a /usr/src/zabbix-4.2.1/frontends/php/* /var/www/html/zabbix/
		chown apache.apache -R  /var/www/html
	}
# 6、配置zabbix服务
	config_zabbix() {
		#sed -i '36iLogFile=/tmp/zabbix_server.log' /usr/local/zabbix4.2/etc/zabbix_server.conf
		sed -i  '85iDBHost=127.0.0.1' /usr/local/zabbix4.2/etc/zabbix_server.conf
		sed -i '118iDBPassword=zabbix' /usr/local/zabbix4.2/etc/zabbix_server.conf
	}
# 7、 导入数据库信息
cd /usr/src/zabbix-4.0.1/database/mysql
mysql -uzabbix -pzabbix  zabbix < schema.sql 
mysql -uzabbix -pzabbix  zabbix < images.sql 
mysql -uzabbix -pzabbix  zabbix < data.sql 
