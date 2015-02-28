<?php
/*
  +----------------------------------------------------------------------+
  | Name:inc/const.m                                                     |
  +----------------------------------------------------------------------+
  | Comment:MMS RESTful API const                                        |
  +----------------------------------------------------------------------+
  | Author:Evoup                                                         |
  +----------------------------------------------------------------------+
  | Created:2011-02-22 10:30:48                                          |
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-02-28 13:34:48
  +----------------------------------------------------------------------+
 */

/* 版本号 */
define('__VERSION','1.0');        //主版本号',代表主要功能分支
define('__SUBVERSION','r1590');   //小版本号',即subversion版本号

/* {{{ mdb setting
 */
define('__MDB_HOST',        '127.0.0.1'); // TODO 这里也改成用ini配置的方式 
define('__MDB_PORT',        '9090');
define('__MDB_SENDTIMEOUT', '20000');  //20 seconds
define('__MDB_RECVTIMEOUT', '20000');  //20 seconds
/* }}} */
/* {{{ redis server
 */
define('__REDIS_HOST',      '127.0.0.1');
define('__REDIS_PORT',      '6379');
/* }}} */
/* {{{ services
 */
define('__SERVICE_FMPUSER',           'fmpuser');
define('__SERVICE_LOGIN',             'login');

define('__SERVICE_SERVER',            'server');   
define('__SERVICE_STATUS',            'status');
define('__SERVICE_SERVER_GROUP',      'servergroup');
define('__SERVICE_EVENT',             'event');
define('__SERVICE_EVENT_CAUTION',     'eventcaution');
define('__SERVICE_EVENT_WARNING',     'eventwarning');
define('__SERVICE_EVENT_OK',          'eventok');
define('__SERVICE_MAILSETTING',       'mailsetting');
define('__SERVICE_ALARMSETTING',      'alarmsetting');
define('__SERVICE_MONITOR',           'monitor');
define('__SERVICE_USERGROUP',         'usergroup');
define('__SERVICE_USER',              'user');
define('__SERVICE_MONITORITEM',       'monitoritem');
define('__SERVICE_LOG',               'log');
define('__SERVICE_EVENT_SETTING',     'event_setting');
define('__SERVICE_GENERIC_SETTING',   'generic_setting');
define('__SERVICE_CLOUDVIEW',         'cloudview');
define('__SERVICE_MONENGINE',         'monengine');
define('__SERVICE_SCAN_SETTING',      'scan_setting');
define('__SERVICE_GRAPH',             'graph');
define('__SERVICE_RRDGRAPH',          'rrdgraph');
define('__SERVICE_DETAIL_SETTING',    'detailsetting');
define('__SERVICE_IP_SETTING',        'ipsetting');
define('__SERVICE_MDNDELIVER_SETTING','mdndeliver_setting');
define('__SERVICE_DISTRICT',          'district');
define('__SERVICE_CARRIER',           'carrier');
define('__SERVICE_PROCESS_DELETE_SERVER', 'process_delete_server');
define('__SERVICE_TIME',              'time');
/* }}} */

/* {{{ services
 */
define('__PREFIX_FMPUSER',           'fmpuser');
define('__PREFIX_SERVER',            'server');
define('__PREFIX_SERVER_GROUP',      'serverGroup');
define('__PREFIX_STATUS',            'status');
define('__PREFIX_EVENT',             'event');
define('__PREFIX_EVENT_CAUTION',     'eventcaution');
define('__PREFIX_EVENT_WARNING',     'eventwarning');
define('__PREFIX_EVENT_OK',          'eventok');
define('__PREFIX_MAILSETTING',       'mailSetting');
define('__PREFIX_ALARMSETTING',      'alarmSetting');
define('__PREFIX_MONITOR',           'monitor');
define('__PREFIX_USERGROUP',         'usergroup');
define('__PREFIX_USER',              'user');
define('__PREFIX_LOGIN',             'login');
define('__PREFIX_MONITORITEM',       'monitoritem');
define('__PREFIX_LOG',               'log');
define('__PREFIX_EVENT_SETTING',     'event_setting');
define('__PREFIX_GENERIC_SETTING',   'generic_setting');
define('__PREFIX_CLOUDVIEW',         'cloudview');
define('__PREFIX_MONENGINE',         'monengine');
define('__PREFIX_SCAN_SETTING',      'scan_setting');
define('__PREFIX_GRAPH',             'graph');
define('__PREFIX_RRDGRAPH',          'rrdGraph');
define('__PREFIX_DETAIL_SETTING',    'detailSetting');
define('__PREFIX_IP_SETTING',        'ipsetting');
define('__PREFIX_MDNDELIVER_SETTING','mdndeliver_setting');
define('__PREFIX_DISTRICT',          'district');
define('__PREFIX_CARRIER',           'carrier');
define('__PREFIX_PROCESS_DELETE_SERVER', 'process_delete_server');
define('__PREFIX_TIME',              'time');
/* }}} */

/* {{{ operations
 */
define('__OPERATION_CREATE', 'create');
define('__OPERATION_READ',   'get');
define('__OPERATION_UPDATE', 'update');
define('__OPERATION_DELETE', 'delete');
/* }}} */

/* {{{ http status define
 */
define('__HTTPSTATUS_OK',                    200);
define('__HTTPSTATUS_CREATED',               201);
define('__HTTPSTATUS_NO_CONTENT',            204);
define('__HTTPSTATUS_RESET_CONTENT',         205);
define('__HTTPSTATUS_BAD_REQUEST',           400);
define('__HTTPSTATUS_UNAUTHORIZED',          401);
define('__HTTPSTATUS_FORBIDDEN',             403);
define('__HTTPSTATUS_NOT_FOUND',             404);
define('__HTTPSTATUS_METHOD_NOT_ALLOWED',    405);
define('__HTTPSTATUS_METHOD_CONFILICT',      409);
define('__HTTPSTATUS_INTERNAL_SERVER_ERROR', 500);
/* }}} */

/* {{{ selector
 */
define('__SELECTOR_SINGLE',   '@self');
define('__SELECTOR_MASS',     '@all');
define('__SELECTOR_GROUP',    '@group');

define('__SELECTOR_REPORT',  '@report');
define('__SELECTOR_ALLSITE', '@all'); // 全部站点 
define('__SELECTOR_SINGLE_SITE', '@self'); // 单个站点 
/* }}} */


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

/* {{{ (mmsapi)DB表 
 */
if (!$conf['debug']) {
} else {
}
/* }}} */


// 默认用户常量
define('__MONITOR_DEFAULT_USER', 'monitoradmin'); //默认用户 

// 权限常量
// 1=无权限 2=读取 3=读取创建 4=读取修改 5=读取创建修改 6=读取创建修改删除
// ...


// 分页的常量
define('__PAGE_PREV_YES', '1'); //有上一页 
define('__PAGE_PREV_NO',  '0'); //没有上一页 
define('__PAGE_NEXT_YES', '1'); //有下一页 
define('__PAGE_NEXT_NO',  '0'); //没有下一页 
define('__EVENTCODE_DOWN', '997w'); //宕机事件代码
define('__EVENT_CLASS_CAUTION', '2'); //注意事件 
define('__EVENT_CLASS_WARNING', '3'); //严重事件 
define('__EVENT_CLASS_NORMAL',  '1'); //普通事件 
define('__SUFFIX_EVENT_CAUTION', 'c'); //注意事件的后缀 
define('__SUFFIX_EVENT_WARNING', 'w'); //严重事件的后缀 
define('__SUFFIX_EVENT_NORMAL',  'n'); //普通事件的后缀 
define('__NUM_EVENTCODE', 3); //事件代码的前三位代表一个监控事件项 
define('__EVENT_ACTIVE', 1); //事件激活状态
define('__EVENT_FIXED', 0); //事件已解决
define('__HAS_THIS_PAGE', 1); //分页时候标记存在此页,而不获取数据，仅仅作为一个计数器 

// cookie
if (!$conf['debug']) {
    define('__CO_MMSUID', '__CO_MMSUID');
    define('__CO_MMSUNAME', '__CO_MMSUNAME');
} else {
    define('__CO_MMSUID', '__CO_MMSUID_BETA');
    define('__CO_MMSUNAME', '__CO_MMSUNAME_BETA');
}


// message queue
//define(__MQ_TABLE, 'edgeServerStatus'); // 存消息队列的表名
//define(__MQ_KEY,   'edgeServerList');   // for智能路由控制中心的队列

//memcache的key
//define('__KEY_HBASEMASTER', 'hbasemaster'); //取monitor_server保存的hbasemaster的信息 
?>
