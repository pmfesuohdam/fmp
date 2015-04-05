软件说明：fmp的restful API

环境依赖：
yum groupinstall development
libxml2-devel
openssl-devel
libcurl-devel
libmcrypt-devel

php5.4
编译参数
'./configure'  '--prefix=/usr/local/php5_facebook' '--with-layout=GNU'
'--with-config-file-scan-dir=/usr/local/php5_facebook/etc/php' '--enable-dom'
'--enable-filter' '--enable-hash' '--enable-json' '--with-mcrypt'
'--with-curl' '--with-pcre-regex' '--enable-mbstring' '--enable-ctype'
'--enable-session' '--with-libxml-dir' '--enable-libxml' '--enable-simplexml'
'--enable-pdo' '--with-pdo-mysql=mysqlnd' '--with-mysqli=mysqlnd'
'--with-mysql=mysqlnd' '--enable-sysvsem' '--enable-pcntl' '--enable-dba'
'--enable-sysvmsg' '--enable-sysvshm' '--enable-sockets' '--enable-ftp'
'--with-zlib' '--with-pear=/usr/local/pear' '--enable-xml' '--with-openssl'
'--enable-fpm' '--enable-exif'

memcache和gd扩展，暂时以so方式安装


配置方法：

inc/const.m中
修改以下常量为实际运行环境的参数

修改以下常量为实际运行环境的syslog参数
/* {{{ syslog(fancility&level)
 */
if (!$conf['debug']) {
    define('__SYSLOG_FACILITY_API', 'LOG_LOCAL4');
} else {
    define('__SYSLOG_FACILITY_API', 'LOG_LOCAL5');
}
//level
define('__SYSLOG_LV_DEBUG',     'LOG_ERR');
/* }}} */
