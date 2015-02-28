<?php
/*
  +----------------------------------------------------------------------+
  | Name: loginFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理登录的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-02-28 13:37:28
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

if($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ):
        //UNUSED
        break;
    case(__OPERATION_UPDATE):
        /* {{{ 登录处理
         */
        /* }}} */
        break;
    case(__OPERATION_DELETE):
        /* {{{ 退出登录
         */
        /* }}} */
        break;
    }
}

?>
