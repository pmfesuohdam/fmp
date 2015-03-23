<?php
/*
  +----------------------------------------------------------------------+
  | Name:syncFun.m
  +----------------------------------------------------------------------+
  | Comment:同步facebook广告帐号数据的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-23 14:16:17
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
if($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    if ($_SERVER['REQUEST_METHOD'] == 'GET') {
        switch($GLOBALS['operation']) {
        case(__OPERATION_READ):
            //adaccount必须存在且属于当前用户
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            $ret['status']='true';
            echo json_encode($ret);
            break;
        }
    }
}
?>
