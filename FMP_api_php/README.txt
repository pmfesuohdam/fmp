软件说明：监控的restful API

配置方法：

inc/const.m中
修改以下常量为实际运行环境的hbase参数
define('__MDB_HOST',        '127.0.0.1'); // TODO 这里也改成用ini配置的方式 
define('__MDB_PORT',        '9090');
define('__MDB_SENDTIMEOUT', '6000');  //6 seconds
define('__MDB_RECVTIMEOUT', '6000');  //6 seconds
define('__MQ_HOST',         '127.0.0.1');
define('__MQ_PORT',         '6379');

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
