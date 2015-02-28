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
  | Last-Modified: 2015-02-28 12:55:04
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
define('__SERVICE_LOGIN',             'login');
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
define('__SERVICE_EDGESERVER_STATUS', 'edgeserverstatus');
define('__SERVICE_TESTSPEED',         'speed');
define('__SERVICE_TESTSPEED_SITE',    'testspeed_site');
define('__SERVICE_METRIC',            'metric');
define('__SERVICE_PROCESS_DELETE_SERVER', 'process_delete_server');
define('__SERVICE_TIME',              'time');
define('__SERVICE_DOCS',              'docs');
define('__SERVICE_DOWNLOADS',         'downloads');
define('__SERVICE_GET_DOWNLOAD_FILE', 'get_download_file');
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
define('__PREFIX_EDGESERVER_STATUS', 'edgeserverstatus');
define('__PREFIX_TESTSPEED',         'speed');
define('__PREFIX_TESTSPEED_SITE',    'testspeed_site');
define('__PREFIX_METRIC',            'metric');
define('__PREFIX_PROCESS_DELETE_SERVER', 'process_delete_server');
define('__PREFIX_TIME',              'time');
define('__PREFIX_DOCS',              'docs');
define('__PREFIX_DOWNLOADS',         'downloads');
define('__PREFIX_GET_DOWNLOAD_FILE', 'get_download_file');
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

/* statusUnit的选择器 */
define('__SELECTOR_MONENGINE',       '@monengine');
define('__SELECTOR_MDB',             '@mdb');
define('__SELECTOR_MONHEALTH',       '@health'); 
define('__SELECTOR_MONEVENTSUMMARY', '@eventsummary'); 
define('__SELECTOR_LOGININFO',       '@logininfo');
define('__SELECTOR_MOBCLIENT',       '@mobclient'); // 智能手机客户端的接口 

/* server的选择器 */ 
define('__SELECTOR_SINGLE_DETAIL',  '@self_detail'); // 服务器的明细信息 
define('__SELECTOR_SINGLE_SETTING', '@self_setting'); // 服务器的设置(不含组信息以为的全部设置)
define('__SELECTOR_SINGLE_GROUP',   '@self_group'); // 服务器的所属的组
define('__SELECTOR_MASSUP',         '@allup'); // 全部在线的服务器 
define('__SELECTOR_MASSDOWN',       '@alldown'); // 全部宕机的服务器
define('__SELECTOR_MASSUNMON',      '@allunmonitored'); // 全部未监控的服务器
define('__SELECTOR_MASSMEMBER',     '@allmember'); // 全部成员(用户组使用)
define('__SELECTOR_MOBCLIENT_ALLUP', '@mobclient_allup'); // 全部在线的服务器for智能手机客户端 
define('__SELECTOR_MOBCLIENT_ALLDOWN', '@mobclient_alldown'); // 全部宕机的服务器for智能手机客户端 
define('__SELECTOR_MASSUNSCALING', '@allunscaling'); // 全部auto scaling未服务 
define('__SELECTOR_MOBCLIENT_ALLUNSCALING', '@mobclient_allunscaling'); // 全部auto scaling未服务for智能手机客户端 

/* event_setting的选择器 */
define('__SELECTOR_KEEPALIVE',      '@keepalive'); // 检查心跳请求超时秒数

/* event的选择器 */
define('__SELECTOR_UNHANDLED', '@unhandled'); // 未处理问题事件列表 
define('__SELECTOR_MASSCAUTION', '@allcaution'); // 全部注意的事件
define('__SELECTOR_MASSWARNING', '@allwarning'); // 全部严重的事件

/* detailSetting的选择器 */
define('__SELECTOR_GENERIC', '@generic');
define('__SELECTOR_MYSQL',   '@mysql');
define('__SELECTOR_SERVING', '@serving');
define('__SELECTOR_DAEMON',  '@daemon');
define('__SELECTOR_REPORT',  '@report');
define('__SELECTOR_MDN',     '@mdn');

/* ipsetting的选择器 */
define('__SELECTOR_HOSTIP',  '@hostip');

/* testspeed的选择器 */
define('__SELECTOR_ALLSITE', '@all'); // 全部站点 
define('__SELECTOR_SINGLE_SITE', '@self'); // 单个站点 
/* }}} */

/* httpstatus的选择器 */
define('__SELECTOR_HTTPSTATUS_ALL', '@httpstatus_all'); //全部HTTP状态 
define('__SELECTOR_HTTPSTATUS_2XX', '@httpstatus_2xx'); //全部HTTP2xx 
define('__SELECTOR_HTTPSTATUS_3XX', '@httpstatus_3xx'); //全部HTTP3xx 
define('__SELECTOR_HTTPSTATUS_4XX', '@httpstatus_4xx'); //全部HTTP4xx 
define('__SELECTOR_HTTPSTATUS_5XX', '@httpstatus_5xx'); //全部HTTP5xx 

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

/* {{{ (mmsapi)MDB表 
 */
if (!$conf['debug']) {
    define('__MDB_TAB_SERVER', 'monitor_server'); //MDB的server即时信息表 
    define('__MDB_TAB_SERVER_HISTORY', 'monitor_server_history'); //MDB的server历史信息表 
    define('__MDB_TAB_SERVERNAME', 'monitor_servername'); //MDB的servername表 
    define('__MDB_TAB_USER', 'monitor_user'); //MDB的user表 
    define('__MDB_TAB_USERGROUP', 'monitor_usergroup'); //MDB的usergroup表 
    define('__MDB_TAB_HOST', 'monitor_host'); //MDB的host表 
    define('__MDB_TAB_ENGINE', 'monitor_engine'); //MDB的engine表 
} else {
    define('__MDB_TAB_SERVER', 'monitor_server_beta'); //MDB的server即时信息表 
    define('__MDB_TAB_SERVER_HISTORY', 'monitor_server_history_beta'); //MDB的server历史信息表 
    define('__MDB_TAB_SERVERNAME', 'monitor_servername_beta'); //MDB的servername表 
    define('__MDB_TAB_USER', 'monitor_user_beta'); //MDB的user表 
    define('__MDB_TAB_USERGROUP', 'monitor_usergroup_beta'); //MDB的usergroup表 
    define('__MDB_TAB_HOST', 'monitor_host_beta'); //MDB的host表 
    define('__MDB_TAB_ENGINE', 'monitor_engine_beta'); //MDB的engine表 
}
define('__MDB_TAB_MDNDELIVER_BUCKET', 'MWS_MSS_BUCKET'); // MDB的mdn bucket表 
define('__MDB_TAB_MWS_USER', 'MWS_USER'); // MWS的USER表 
/* }}} */

/* {{{ (mmsapi)MDB的column 
 */
define('__MDB_COL_CONFIG_INI',     'config:ini'); //配置文件的列 
define('__MDB_COL_EVENT',          'event:item'); //事件的column
define('__MDB_COL_DELETED',        'info:deleted'); //删除标记（monitor_host表）
define('__MDB_COL_SERVERNAME_ALL', 'servername:all'); //全局服务器列表的column ,table为__MDB_TAB_SERVERNAME
define(__MDB_COL_SCAN_DURATION,  'scan:duration'); //扫描间隔时间的column， table为__MDB_TAB_ENGINE
define('__KEY_SERVGROUP',          'servgroup%s');
define('__MAX_DEFAULT_GROUP_NUM',  11); //默认组最大数 
define('__KEY_SCAN_DURATION',      'durationtime'); //扫描持续时间的key
/* }}} */

/* {{{ (mmsapi)MDB的key 
 */
define('__KEY_INIDATA', 'inidata'); //存最终生成后的INI配置文件(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI)
define('__KEY_INI_USERSETTING', 'user_setting'); //存用户设置的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI)
define('__KEY_INI_USERGROUPSETTING', 'usergroup_setting'); //存用户组设置的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI)
define('__KEY_INI_GENERALSETTING', 'generial_setting'); //存引擎基础设置的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI)
define('__KEY_INI_MAILSETTING', 'mail_setting'); //存邮件设置的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI)
define('__KEY_INI_SCANSETTING', 'scan_setting'); //存扫描设置的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI)
define('__KEY_INI_ALARMSETTING', 'alarm_setting'); //存报警设置的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI)
define('__KEY_INI_EVENTSETTING', 'event_setting'); //存事件设置的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI)
define('__KEY_INI_SERVLIST', 'servlist_setting'); //存服务器默认组列表的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI) 
define('__KEY_INI_GROUP_CUST', 'group_cust'); //存自定义服务器组的组名描述的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI)
define('__KEY_INI_SERVLIST_CUST', 'servlist_cust_setting'); //存服务器自定义组列表的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI) 
define('__KEY_INI_UNMONITORED', 'unmonitored'); //存未监控列表的json(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI) 
define('__KEY_TO_DELETE_SERVERS', 'todelete_servers'); //存待删除的服务器(table:__MDB_TAB_SERVER,column:__MDB_COL_CONFIG_INI) 
define('__TEMPLATE_VAR_CUSTGROUPS', 'type_cust'); //自定义组的模版变量 
define('__PREFIX_INI_SERVGROUP', 'type_'); //配置文件中组的前缀 
define('__MONITOR_TYPE_GENERIC',      1 ); //监控服务器基础类信息
define('__MONITOR_TYPE_MYSQL',          2 ); //监控数据库类信息
define('__MONITOR_TYPE_SERVING',     3 ); //监控SERVING类信息
define('__MONITOR_TYPE_DELIVERING',  3 ); //监控投放类信息
define('__MONITOR_TYPE_DAEMON',  4 ); //监控管理界面类信息
define('__MONITOR_TYPE_REPORT',      5 ); //监控报表类信息
define('__MONITOR_TYPE_MADN',      6 ); //监控MADN类信息
define('__MONITOR_TYPE_HADOOP',      7 ); //监控HADOOP类信息
define('__MONITOR_TYPE_BIZLOG',      8 ); //监控BIZLOG类信息
define('__MAX_MONITOR_TYPES',        8 ); //总计的监控种类
define('__KEY_HOST_DETAIL_SETTING', 'detail_setting|%s'); //存服务器的明细设置(监控哪些项目)
define('__KEY_HOST_DETAIL_ITEM_SETTING', 'detail_item_setting|%s'); //存服务器明细设置(各项的具体报警设置)
define('__KEY_TODELETE_SERVERS', 'todelete_servers'); //待删除服务器的key 
/* }}} */

// 默认用户常量
define('__MONITOR_DEFAULT_USER', 'monitoradmin'); //默认用户 
// 默认用户组常量
define('__MONITOR_DEFAULT_USERGROUP', 'monitoradmin'); //默认用户组的名字
define('__MONITOR_IS_MEMBER', 'member'); //对于用户组表的成员用户member:{userid}，给予其一个值member代表为这个用户为用户组的成员,对于用户组groupid:{groupid}亦然

// 权限常量
// 1=无权限 2=读取 3=读取创建 4=读取修改 5=读取创建修改 6=读取创建修改删除
define('__MONITOR_PRIVILEGE_OPERATION_MINNUM', 1); //对应的权限最小值 
define('__MONITOR_PRIVILEGE_OPERATION_MAXNUM', 6); //对应的权限最大值
define('__MONITOR_PRIVILEGE_NONE', 1); //无权限 
define('__MONITOR_PRIVILEGE_R',    2); //读取权限 
define('__MONITOR_PRIVILEGE_CR',   3); //创建读取权限 
define('__MONITOR_PRIVILEGE_CU',   4); //创建修改权限 
define('__MONITOR_PRIVILEGE_CRU',  5); //创建读取修改权限 
define('__MONITOR_PRIVILEGE_CRUD', 6); //创建读取修改删除权限 

// 报警类型
define('__MAILTYPE_NOSEND',  1); //不接收报警 
define('__MAILTYPE_CAUTION', 2); //普通报警 
define('__MAILTYPE_WARNING', 3); //严重报警 
define('__MAILTYPE_ALL',     4); //所有报警 


// 生成INI时用到的JSON的key
define('__JSONKEY_SERVER_GROUP', 'server_group');
define('__JSONKEY_USER', 'user');
define('__JSONKEY_USER_GROUP', 'user_group');

// 在线宕机的常量
define('__HOST_STATUS_UP',  '1'); //主机在线
define('__HOST_STATUS_DOWN', '0'); //主机宕机
define('__HOST_STATUS_UNKNOWN', '5'); //未监控的主机
define('__HOST_STATUS_UNSCALING', '6'); //auto scaling未服务的主机

// 事件号（不含等级） 
define('__EVN_DISK_CAPACITY',           '000'); //000---【磁盘占用率】
define('__EVN_DISK_INODE_CAPACITY',     '001'); //001---【磁盘INODE占用率】
define('__EVN_LOAD_AVERAGE',            '002'); //002---【平均LOAD数】
define('__EVN_MEMORY_USAGE',            '003'); //003---【内存占用率】
define('__EVN_TOTAL_PROCESS',           '004'); //004---【运行进程数】
define('__EVN_CPU_USAGE',               '005'); //005---【CPU占用率】
define('__EVN_TCP_PORT',                '006'); //006---【TCP端口】
define('__EVN_TCP_CONNECTION',          '007'); //007---【TCP连接数】
define('__EVN_NETWORK_FLOW',            '008'); //008---【网卡流量】
define('__EVN_SERVING_REQUEST_NUM',     '009'); //009---【Serving请求数】
define('__EVN_SERVING_WORK_NODES',      '010'); //010---【Serving工作节点数】
define('__EVN_SERVING_ADVT_PUBLISH',    '011'); //011---【Serving广告发布】
define('__EVN_DAEMON_WEB_SERVER',       '012'); //012---【Daemon互联网服务器】
define('__EVN_DAEMON_BACKEND_DAEMON',   '013'); //013---【Daemon后台守护进程】
define('__EVN_DAEMON_LOGIN',            '014'); //014---【Daemon的LOGIN】
define('__EVN_DAEMON_ADVT_DELIVER',     '015'); //015---【Daemon的广告投放】
define('__EVN_DAEMON_ERRORLOG',         '016'); //016---【Daemon的errorlog】
define('__EVN_MYSQL_CONNECTION',        '017'); //017---【Mysql的连接数】
define('__EVN_MYSQL_TABLE_SIZE',        '018'); //018---【Mysql的单表最大尺寸】
define('__EVN_MYSQL_THREADS',           '019'); //019---【Mysql的创建线程数】
define('__EVN_MYSQL_MSTSLV',            '020'); //020---【Mysql的Master和Slave】
define('__EVN_MYSQL_CRUCIAL_TABLE',     '021'); //021---【Mysql关键表控制】
define('__EVN_REPORT_WAIT_PROCESS_LOG', '022'); //022---【Report待处理日志数】
define('__EVN_SERVING_LOG_CREATION',    '023'); //023---【Serving的日志生成】
define('__EVN_SERVING_ADVT_FILLRATE',   '024'); //024---【Serving的广告填充率】
define('__EVN_MDN_DNS_ARECORD',         '026'); //025---【Mdn的dns之A记录】
define('__ENV_SINGLE_HOST_DOWN',        '997'); //997---【单台主机宕机】
define('__EVN_GROUP_DOWN',              '998'); //998---【整组宕机】
define('__EVN_ALL_DOWN',                '999'); //999---【全部宕机】

// 事件监控状态
define('__EV_MONITORED',   '1'); //监控该事件 
define('__EV_UNMONITORED', '0'); //不监控该事件 

// 事件的三种状态
define('__EVENT_TOTAL_STATUS', 3);

// 事件等级
define('__EVENT_LEV_NORMAL',  'n'); //正常的事件 
define('__EVENT_LEV_CAUTION', 'c'); //注意的事件 
define('__EVENT_LEV_WARNING', 'w'); //严重的事件 
define('__EVENT_LEV_DOWN_NUM',    '0'); //宕机的事件[前端使用的数字]
define('__EVENT_LEV_NORMAL_NUM',  '1'); //正常的事件[前端使用的数字]
define('__EVENT_LEV_CAUTION_NUM', '2'); //注意的事件[前端使用的数字]
define('__EVENT_LEV_WARNING_NUM', '3'); //严重的事件[前端使用的数字]
define('__EVENT_LEV_CAUTION_WARNING_NUM', '4'); //既有注意事件又有严重的事件[前端使用的数字]
define('__EVENT_LEV_UNMONITORED_NUM', '5'); //未监控任何事件

// 事件UI的文字
define('__EVENT_TEXT_FIXED',  'FIXED'); //事件已经解决 
define('__EVENT_TEXT_ACTIVE', 'ACTIVE'); //事件激活 

// 事件其他
define('__NUM_EVENT_VALUE', 2); //event:{eventCode}存的值，其中以|连接，分为为多少个部分，这里为2个部分，如1|disk /usr partition 99%,前面为事件

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

// 服务器设置的常量
define('__SERVER_SETTING_AUTHTYPE_NONE',  0);
define('__SERVER_SETTING_AUTHTYPE_TOKEN', 1);
define('__SERVER_SETTING_MONITORED_YES',  1);
define('__SERVER_SETTING_MONITORED_NO',   0);
define('__SERVER_IS_MEMBER_OF_THIS_GROUP', 'member'); //代表服务器为该组成员
define('__NO_ALIAS', 'no alias'); //服务器没有别名 
define('__UI_IS_SERVGRP_MEMBER',  1); //前端的常量，为该组成员
define('__UI_NOT_SERVGRP_MEMBER', 0); //前端的常量，不是该组成员

// 常规设置的常量
define('__GENERIAL_SETTING_SENDDAILYMAIL_YES', "1");
define('__GENERIAL_SETTING_SENDDAILYMAIL_NO', "0");

// 状态云显示多少server
define('__CLOUDVIEW_NUM_HOST', 50);

// 为监控的文字UI描述
define('__UI_UNMONITORED', '未监控');

// 未监控名单操作的常数
define('__UNMONITORED_ADD', 1);
define('__UNMONITORED_DELETE', 2);

// 显示事件文字的语种
define('__EVENT_LANG_CHS',  0);
define('__EVENT_LANG_ENG', 1);

// message queue
define(__MQ_TABLE, 'edgeServerStatus'); // 存消息队列的表名
define(__MQ_KEY,   'edgeServerList');   // for智能路由控制中心的队列

//memcache的key
define('__KEY_HBASEMASTER', 'hbasemaster'); //取monitor_server保存的hbasemaster的信息 
?>
