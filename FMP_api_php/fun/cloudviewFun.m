<?php
/*
  +----------------------------------------------------------------------+
  | Name: cloudview.m
  +----------------------------------------------------------------------+
  | Comment: 状态云的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 18:05:32
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

if ($GLOBALS['operation'] == __OPERATION_READ) {
    if (!canAccess('read_cloudview')) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
        return;
    }
    $last_host_arr=getHostFinalStatus();
    uasort($last_host_arr,'sortDown'); //将有问题的放到前面 
    /* {{{ 未监控的
     */
    $temp_last_host_arr = $last_host_arr;
    foreach (array_keys($temp_last_host_arr) as $host) {
        if (in_array($host, (array)explode(',', $_CONFIG['not_monitored']['not_monitored']))) {
            $last_host_arr[$host]=__EVENT_LEV_UNMONITORED_NUM;
        }
    }
    unset($temp_last_host_arr);
    /* }}} */
    if (!$err) {
        echo json_encode((array)array_slice($last_host_arr,0,__CLOUDVIEW_NUM_HOST)); //取出前50台给状态云显示 
        $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
    }
}
?>
