<?php
/*
  +----------------------------------------------------------------------+
  | Name:fun/metricFun.m
  +----------------------------------------------------------------------+
  | Comment:度量指标函数
  +----------------------------------------------------------------------+
  | Author: Yinjia
  +----------------------------------------------------------------------+
  | Created: 2012-11-07 18:11:46
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 17:35:22
  +----------------------------------------------------------------------+
 */
header("Content-type: application/json; charset=utf-8");
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; // 默认返回400 
if (!canAccess('read_monitorEvent')) {
    $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
    return;
}
switch ($GLOBALS['selector']) {
case(__SELECTOR_MASS):
    foreach ($monitor_item_arr as $class => $metricInfo) {
        foreach (array_keys($metricInfo) as $metric) {
            $metricCode=$AllSubMonItems[$metric];
            $metrics[]=array("{$class}.{$metric}"=>$metricCode);
        }
    }
    $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
    echo json_encode($metrics);
    break;
}
?>
