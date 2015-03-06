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
  | Last-Modified: 2015-03-03 14:51:27
  +----------------------------------------------------------------------+
 */

/* 版本号 */
define('__VERSION','1.0');        //主版本号',代表主要功能分支
define('__SUBVERSION','r1590');   //小版本号',即subversion版本号
/* {{{ db mysql setting*/
define('__DB_MYSQL_HOST', '127.0.0.1');
define('__DB_MYSQL_PORT', '3306');
define('__DB_MYSQL_USER', 'madcore');
define('__DB_MYSQL_PASS', 'madcore');
define('__DB_MYSQL_DB',   'fmp');
/* }}} */
/* {{{ mysql tables */
define('__TB_FMP_USER', 't_fmp_user');
/* }}} */
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
define('__SERVICE_JOIN',              'join');
define('__SERVICE_FMPUSER',           'fmpuser');
define('__SERVICE_LOGIN',             'login');
define('__SERVICE_FBLOGIN',           'fb_login');
define('__SERVICE_FBACCOUNT',         'fbaccount');
define('__SERVICE_CAMPAIGN',          'campaign');
define('__SERVICE_USER',              'user');
define('__SERVICE_GRAPH',             'graph');
define('__SERVICE_DISTRICT',          'district');
/* }}} */

/* {{{ services
 */
define('__PREFIX_JOIN',              'join');
define('__PREFIX_FMPUSER',           'fmpuser');
define('__PREFIX_USER',              'user');
define('__PREFIX_LOGIN',             'login');
define('__PREFIX_FBLOGIN',           'fb_login');
define('__PREFIX_FBACCOUNT',         'fbaccount');
define('__PREFIX_CAMPAIGN',          'campaign');
define('__PREFIX_GRAPH',             'graph');
define('__PREFIX_DISTRICT',          'district');
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
define('__SELECTOR_NEW',      '@new'); //是否为新用户，就是没有任何广告活动的 
define('__SELECTOR_MASS',     '@all');
define('__SELECTOR_GROUP',    '@group');


define('__SELECTOR_STEP1',    '@step1'); //广告第1步 
define('__SELECTOR_STEP2',    '@step2'); //广告第2步
define('__SELECTOR_STEP3',    '@step3'); //广告第3步
define('__SELECTOR_STEP4',    '@step4'); //广告第4步
define('__SELECTOR_STEP5',    '@step5'); //广告第5步


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

// 选择的广告类型Objective
define('__FMP_ADTYPE_MUTIPRO',  1); //Multi-Product Ads(Website Clicks) 
define('__FMP_ADTYPE_NEWSFEED', 2); //News feed(Website Clicks) 
define('__FMP_ADTYPE_RIGHTCOL', 3); //Right-Hand Column(Website Clicks) 

// 业务错误代码
define('__FMP_ERR_UPDATE_ADACCOUNT',  10553);
define('__FMP_ERR_UPDATE_FMP_FB_REL', 10554);
define('__FMP_ERR_SELECT_ADACCOUNT',  10555);
define('__FMP_ERR_SELECT_ACCTOK',     10556);

//graph url前缀
define('__FB_GRAPH', 'https://graph.facebook.com/v2.2');

//session
define('__SESSION_FMP_UID', 'fmp_uid');
define('__SESSION_FMP_USERNAME', 'username');
define('__SESSION_FB_UID', 'fb_uid');

//buyingType的种类
define('__BYT_CPC', 'cpc');
define('__BYT_CPM', 'cpm');
define('__BYT_OCPM','ocpm');
define('__BYT_CPA', 'cpa');

//objective的种类
define('__OBJT_MULTI_PRODUCT', 1);
define('__OBJT_NEWSFEED',      2);
define('__OBJT_RIGHTCOL',      3);


// 默认用户常量

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
