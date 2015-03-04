<?php
/*
  +----------------------------------------------------------------------+
  | Name: campaignFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理campaign的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-03 14:53:02
  +----------------------------------------------------------------------+
*/
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
if ($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    $ret=null;
    $ret['status']="true";
    $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
    echo json_encode($ret);
}
?>
