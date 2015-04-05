<?php
/*
  +----------------------------------------------------------------------+
  | Name:index            
  +----------------------------------------------------------------------+
  | Comment:mmsapi入口PHP脚本      
  +----------------------------------------------------------------------+
  | Author:evoup evoex@126.com   
  +----------------------------------------------------------------------+
  | Created:2011-02-22 10:41:44                                      
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-04-05 04:46:14
  +----------------------------------------------------------------------+
 */
session_start();
ini_set('default_socket_timeout', 120);
define(__API_ROOT,    dirname(__FILE__).'/');
//error_reporting(E_ALL | E_STRICT);
error_reporting(0);
$conf = parse_ini_file(dirname(__FILE__).'/conf/api.conf'); //配置文件 

/* {{{ 载入常数
 */
include_once(__API_ROOT.'inc/const.m');
/* }}} */

/* {{{ 基础函数
 */
include_once(__API_ROOT.'fun/common.m');
include_once(__API_ROOT.'fun/safe.m');
include_once(__API_ROOT.'fun/base.m');
include_once(__API_ROOT.'fun/log.m');
include_once(__API_ROOT.'lib/Predis.php');
include_once(__API_ROOT.'fun/mq.m');
/* }}} */

/* {{{ 初始化(载入配置等)
 * $GLOBALS['debugLevel'],debug级别
 * $GLOBALS['debugOutput']
 * $GLOBALS['timeNow']
 * $GLOBALS['timeDesc']
 */
include_once(__API_ROOT.'modules/initApi.m');
/* }}} */

/* {{{ 分析请求,生成全局数组,加载需要的函数
 * $GLOBALS['prefix'], 前缀,与services相关
 * $GLOBALS['postData'], post数据
 * $GLOBALS['serviceName'], 服务名称
 * $GLOBALS['operation'], 操作名
 * $GLOBALS['selector']
 * $GLOBALS['protocolVer'],请求协议版本
 * $GLOBALS['filterStart'],结果过滤相关信息
 * $GLOBALS['filterCount'],结果过滤相关信息
 * $GLOBALS['filterFields'],结果过滤相关信息
 */
ob_start();
include_once(__API_ROOT.'modules/parseRequest.m');
//die;
/* }}} */

/* {{{ api运行
 * $GLOBALS['httpStatus'], REST return
 * $GLOBALS['outputContent'], REST output
 */
apiRun();
/* }}} */
