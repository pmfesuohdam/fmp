<?php
/*
  +----------------------------------------------------------------------+
  | Name: process_delete_serverFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理界面上设置好的待删除的服务器，重新生成INI
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2012年11月19日 星期一 16时15分07秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-11-19 16:15:16
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

switch($GLOBALS['operation']) {
case(__OPERATION_DELETE):
    if ( $GLOBALS['selector'] == __SELECTOR_MASS ) {
        mdbDelSrvUpdateIni(); // 删除服务器方式更新MDB中的INI配置文本
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        echo "ok:deleted";
    }
    break;
}
?>
