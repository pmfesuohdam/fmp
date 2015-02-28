<?php
/*
  +----------------------------------------------------------------------+
  | Name:warningEventFun.m
  +----------------------------------------------------------------------+
  | Comment:严重事件的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-12-20 14:16:24
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; // 默认返回400 
header("Content-type: application/json; charset=utf-8");

switch ($GLOBALS['selector']) {
case(__SELECTOR_MASS):
    /* {{{ 扫描所有主机
     */
    list($table_name, $start_row, $family) = array(__MDB_TAB_HOST, '', array('info')); // 从row的起点开始 
    try {
        $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
        while (true) {
            $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
            if (array_filter($get_arr) == null) break;
            foreach ( $get_arr as $TRowResult ) {
                if (!empty($TRowResult->row)) {
                    if (!empty($GLOBALS['rowKey'])) { // 如果URL里带了筛选,则保存选择的服务器 
                        $GLOBALS['rowKey']==$TRowResult->row && $host_arr[] = $TRowResult->row;
                        $GLOBALS['rowKey']==$TRowResult->row && $upload_time[$TRowResult->row] = $TRowResult->columns['info:last_upload']->value;
                    } else {
                        $host_arr[] = $TRowResult->row;
                        $upload_time[$TRowResult->row] = $TRowResult->columns['info:last_upload']->value;
                    }
                }
            }
        }
        $GLOBALS['mdb_client']->scannerClose($scanner); // 关闭scanner 
    } catch (Exception $e) {
        $err = true;
    }
    /* }}} */
    $host_arr = array_diff((array)$host_arr, (array)explode(',' ,$_CONFIG['not_monitored']['not_monitored']));
    if (!$err) {
        foreach ($host_arr as $host) {
            try {
                if (!empty($host)) {
                    /* 取出该host的监控信息,从即时信息表取出 */
                    $rs = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $host, array('info:'));
                    $uiWordArr = getEventUIDesc($host, $rs[0]->columns, false); // 对于即时表，info列族内的监控项列，不带有timestamp，第三个参数传false

                    $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $host, array("event:"));
                    $arr = $arr[0]->columns;
                    foreach ($arr as $eventCode => $eventVal) {
                        $eventCode = substr($eventCode, -4); // 事件代码 
                        $event_id = substr($eventCode, 0, 3); // 事件号 
                        $event_level = substr($eventCode, -1); // 事件等级
                        $duration_time = getDhms(time() - $eventVal->timestamp); 
                        if ($eventCode!=__EVENTCODE_DOWN && strtolower($event_level)=='w') { // 严重事件 
                            list($event_status, $event_desc) = explode('|', $eventVal->value); // 取得事件描述
                            /* 构造输出数组 */
                            $event_status==__EVENT_ACTIVE && @$temp_page[] = array($host, $event_item_map_table[$event_id][__EVENT_LANG_CHS], $event_id, __EVENT_CLASS_WARNING, $duration_time, date("Y-m-d H:i:s", $upload_time[$host]), $uiWordArr[$host][$event_id]);
                        }
                    }
                }
            } catch (Exception $e) { }
        }
    }
    if (!$err) {
        if (!empty($temp_page)) {
            // 暂时不分页，前端仍旧使用/get/event/@all的分页数据格式
            $temp_page = array('records'=>$temp_page, 'page_info'=>array('total_pages'=>1,'current_page'=>1,'line_per_page'=>100000,'next_page'=>0,'prev_page'=>0));
            echo json_encode($temp_page);
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        } else {
            //空返回200
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        }
    }
    break;
}
?>
