<?php
/*
  +----------------------------------------------------------------------+
  | Name: timeFun.m 
  +----------------------------------------------------------------------+
  | Comment: 返回扫描时间的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2012年12月11日 星期二 13时01分25秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-12-11 13:35:29
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
try {
    $arr=$GLOBALS['mdb_client']->get(__MDB_TAB_ENGINE, __KEY_SCAN_DURATION, __MDB_COL_SCAN_DURATION);
    $ts=$arr[0]->timestamp;
    $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
    if (time()-$ts/1000>1800) {
        $status="0";
    } else {
        $status="1";
    }
    $last_update=Date('Y/m/d H:i:s', $ts/1000);
    echo json_encode( array('status'=>$status,'last_update'=>$last_update) );
} catch (Exception  $e) {
    DebugInfo("[get time err][err:".$e->getMessage()."]",3);
}


?>
