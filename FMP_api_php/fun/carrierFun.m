<?php
/*
  +----------------------------------------------------------------------+
  | Name:carrierFun.m
  +----------------------------------------------------------------------+
  | Comment:处理运营商的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:2012年 7月26日 星期四 10时42分40秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-07-26 10:42:52
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; // 默认返回400 
header("Content-type: application/json; charset=utf-8");

$err = false;
switch ($GLOBALS['selector']) {
case(__SELECTOR_MASS):
    if (!$err) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; 
        $carrier=Array('00' => '未知', '01' => '移动', '02' => '电信', '03' => '联通');
    }
    echo json_encode($carrier);
    break;
default:
    break;
}
?>
