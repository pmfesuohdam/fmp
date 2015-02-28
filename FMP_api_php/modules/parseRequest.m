<?php
/*
  +----------------------------------------------------------------------+
  | Name: modules/parseRequest.m                                          |
  +----------------------------------------------------------------------+
  | Comment: 处理访问信息                                                 |
  +----------------------------------------------------------------------+
  | Author: Evoup                                                         |
  +----------------------------------------------------------------------+
  | Created: 2011-02-23 10:19:45                                          |
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-02-28 13:01:34
  +----------------------------------------------------------------------+
*/
$moduleName=basename(__FILE__);

/* 读取uri信息 */
$arrPathInfo=parse_url($_SERVER['REQUEST_URI']);
DebugInfo("[{$arrPathInfo['path']}][start---------]",2);
$MmsQs=explode('/',$arrPathInfo['path']);
array_shift($MmsQs);        //数组第一项为空

/* {{{ 获取版本(如果需要的话)
 */
if ($_uriHasVersion) {
    $GLOBALS['protocolVer']=$MmsQs[0];
    array_shift($MmsQs);
} else {
    $GLOBALS['protocolVer']=__VERSION;
}
/* }}} */

//获取操作符
if ($_uriHasOperation) {
    $GLOBALS['operation']=$MmsQs[0];
    array_shift($MmsQs);
} else {    //为以后转为纯净的REST留点可能性
    //...
}

//获取service名称
$GLOBALS['serviceName']=strtolower($MmsQs[0]);
array_shift($MmsQs);

// selector
$GLOBALS['selector']=strtolower($MmsQs[0]);
array_shift($MmsQs);

//rowkey
$GLOBALS['rowKey']=empty($MmsQs[0])?null:$MmsQs[0];

//filter
$GLOBALS['filterFields']=isset($_GET['fields'])?explode(',',$_GET['fields']):array();    //用户自定义过滤字段
$GLOBALS['filterStart']=isset($_GET['start'])?$_GET['start']:null;  //起始id
$GLOBALS['filterCount']=isset($_GET['count'])?(int)$_GET['count']:null; //最大数字

//获取post数据
$GLOBALS['postData']=file_get_contents("php://input");

//加载相关函数
if (!empty($GLOBALS['serviceName'])) {
    switch($GLOBALS['serviceName']) {
    case __SERVICE_FMPUSER:
        $GLOBALS['prefix']=__PREFIX_FMPUSER;
        break;
    //case __SERVICE_LOGIN:
        //$GLOBALS['prefix']=__PREFIX_LOGIN;
        //break; 
    case __SERVICE_EVENT:
        $GLOBALS['prefix']=__PREFIX_EVENT;
        break;
    case __SERVICE_EVENT_CAUTION:
        $GLOBALS['prefix']=__PREFIX_EVENT_CAUTION;
        break;
    case __SERVICE_EVENT_WARNING:
        $GLOBALS['prefix']=__PREFIX_EVENT_WARNING;
        break;
    case __SERVICE_EVENT_OK:
        $GLOBALS['prefix']=__PREFIX_EVENT_OK;
        break;
    case __SERVICE_MAILSETTING:
        $GLOBALS['prefix']=__PREFIX_MAILSETTING;
        break;
    case __SERVICE_ALARMSETTING:
        $GLOBALS['prefix']=__PREFIX_ALARMSETTING;
        break;
    case __SERVICE_USERGROUP:
        $GLOBALS['prefix']=__PREFIX_USERGROUP;
        break;
    case __SERVICE_USER:
        $GLOBALS['prefix']=__PREFIX_USER;
        break;
    case __SERVICE_LOG:
        $GLOBALS['prefix']=__PREFIX_LOG;
        break;
    case __SERVICE_MONITOR:
        $GLOBALS['prefix']=__PREFIX_MONITOR;
        break;
    case __SERVICE_MONITORITEM:
        $GLOBALS['prefix']=__PREFIX_MONITORITEM;
        break;
    case __SERVICE_EVENT_SETTING:
        $GLOBALS['prefix']=__PREFIX_EVENT_SETTING;
        break;
    case __SERVICE_GENERIC_SETTING:
        $GLOBALS['prefix'] =__PREFIX_GENERIC_SETTING;
        break;
    case __SERVICE_CLOUDVIEW:
        $GLOBALS['prefix'] =__PREFIX_CLOUDVIEW;
        break;
    case __SERVICE_MONENGINE:
        $GLOBALS['prefix'] =__PREFIX_MONENGINE;
        break;
    case __SERVICE_SCAN_SETTING:
        $GLOBALS['prefix']=__PREFIX_SCAN_SETTING;
        break;
    case __SERVICE_GRAPH:
        $GLOBALS['prefix']=__PREFIX_GRAPH;
        break;
    case __SERVICE_RRDGRAPH:
        $GLOBALS['prefix']=__PREFIX_RRDGRAPH;
        break;
    case __SERVICE_DETAIL_SETTING:
        $GLOBALS['prefix']=__PREFIX_DETAIL_SETTING;
        break;
    case __SERVICE_IP_SETTING:
        $GLOBALS['prefix']=__PREFIX_IP_SETTING;
        break;
    case __SERVICE_DISTRICT:
        $GLOBALS['prefix']=__PREFIX_DISTRICT;
        break;
    default:
        break;
    }
    DebugInfo("[globals_prefix:".$GLOBALS['prefix']."]",2);
    $funcFile=__API_ROOT.'fun/'.$GLOBALS['prefix'].'Fun.m';    //这里要求各个service的命名需要规范
    if (file_exists($funcFile)) {
        DebugInfo("[$moduleName] [$funcFile][include]",2);
        include_once($funcFile);
    } else {
        DebugInfo("[$moduleName] [$funcFile][file_not_exists]",2);
    }
} else {
    DebugInfo("[$moduleName] [none_service]",2);
}

DebugInfo("[$moduleName] [protocolVer:{$GLOBALS['protocolVer']}]-[operation:{$GLOBALS['operation']}]-[serviceName:{$GLOBALS['serviceName']}]-[selector:{$GLOBALS['selector']}]-[rowKey:{$GLOBALS['rowKey']}]",2);
?>
