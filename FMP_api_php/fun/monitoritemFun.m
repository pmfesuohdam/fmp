<?php
/*
  +----------------------------------------------------------------------+
  | Name: monitoritemfun.m
  +----------------------------------------------------------------------+
  | Comment: 监控项的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-12-04 17:41:02
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

switch($GLOBALS['operation']) {
case(__OPERATION_READ): 
    //读取全部监控项
    $temp_monitor_item_arr=$monitor_item_arr;
    try {
        $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, sprintf(__KEY_HOST_DETAIL_SETTING, 
            $GLOBALS['rowKey']), __MDB_COL_CONFIG_INI);
        $ServerMonEventNumArr = (array)explode('|',$arr[0]->value);
    } catch (Exception $e) {
        $err=true;
    }
    $ServerMonEventNumArr=array_filter($ServerMonEventNumArr);
    //如果监控字符串为空，则默认全部监控，界面设置为未监控，不出现设置监控项界面
    if (!empty($ServerMonEventNumArr) || empty($GLOBALS['rowKey'])) {
        foreach ($monitor_item_arr as $monBigCls => $tmpArr) {
            foreach ($tmpArr as $detailItem => $beMonitored) {
                if (empty($GLOBALS['rowKey'])) {
                    $temp_monitor_item_arr[$monBigCls][$detailItem]=0; //新建服务器组会用到
                } elseif (!in_array($AllSubMonItems[$detailItem], $ServerMonEventNumArr)) {
                    $temp_monitor_item_arr[$monBigCls][$detailItem]=0; //设置为0则不监控 
                } 
            }
        }
    }
    if (!$err) {
        echo json_encode($temp_monitor_item_arr); //输出json 
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; 
    }
    break;
}
?>
