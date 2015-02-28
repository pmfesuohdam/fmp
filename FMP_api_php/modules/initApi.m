<?php
/*
  +----------------------------------------------------------------------+
  | Name:modules/initApi.m
  +----------------------------------------------------------------------+
  | Comment:初始化api,确定配置
  +----------------------------------------------------------------------+
  | Author: Yinjia
  +----------------------------------------------------------------------+
  | Created:2011-02-23 10:44:39
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-02-28 10:17:02
  +----------------------------------------------------------------------+
 */
$moduleName=basename(__FILE__);

//默认配置
$_uriHasVersion=true;  //uri中是否包含version信息
$_uriHasOperation=true;//uri中是否包含

//debug级别默认为1,可在各自模块单独修改
$_debugLevel=3;
$GLOBALS['debugLevel']=empty($_REQUEST['debug'])?3:(int)$_REQUEST['debug'];  //支持参数指定debug级别
$GLOBALS['debugOutput']=(isset($_REQUEST['debug_output']) && $_REQUEST['debug_output']==='1')?true:false;

//输出内容,是个数组
$GLOBALS['outputContent']=array();


?>
