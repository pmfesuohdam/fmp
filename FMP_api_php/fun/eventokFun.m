<?php
/*
  +----------------------------------------------------------------------+
  | Name:okEventFun.m
  +----------------------------------------------------------------------+
  | Comment:正常事件的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2011-10-17 11:25:44
  +----------------------------------------------------------------------+
 */
header("Content-type: application/json; charset=utf-8");

switch ($GLOBALS['selector']) {
case(__SELECTOR_MASS):
    /* 获取全部server */
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
    /* 排除不监控的 */
    $host_arr = array_diff((array)$host_arr, (array)explode(',', $_CONFIG['not_monitored']['not_monitored']));
    sort($host_arr);

    /* 全部事件 */
    $event_num = count($event_map_table)/__EVENT_TOTAL_STATUS;

    /* 遍历服务器，显示全部正常的事件 */
    foreach ($host_arr as $host) {
        try { // 判断事件是否存在 
            $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $host, array('event:'));
            $arr = $arr[0]->columns;
            foreach ($arr as $eventCode => $eventVal) {
                $eventCode = substr($eventCode, -4);
                $eventNum = substr($eventCode, 0, 3);
                $eventLev = substr($eventCode, -1);
                list($isActive, $eventDesc) = explode('|', $eventVal->value);
                $eventCode!=__EVENTCODE_DOWN && $isActive && $eventArr[$host][$eventNum]['eventDesc'] = $eventDesc;
                $eventCode!=__EVENTCODE_DOWN && $isActive && $eventArr[$host][$eventNum]['eventLev'] = $eventLev;
            }
        } catch (Exception $e) {
        }
    }
    foreach ($host_arr as $host) {
        // 从即时表中取出该host的监控信息，可能不及时，暂时先这么处理 // TODO  
        $rs = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $host, array('info:'));
        $uiWordArr = getEventUIDesc($host, $rs[0]->columns, false); // 对于即时表，info列族内的监控项列，不带有timestamp，第三个参数传false
        for ($current_event=0; $current_event<$event_num; $current_event++) {
            $event_id = str_pad($current_event, __NUM_EVENTCODE, "0", STR_PAD_LEFT); // 构造本行的事件(不足以0补充 )
            if (isset($eventArr[$host][$event_id])) {
                continue;
            }
            $line[] = array(
                $host,
                $event_item_map_table[$event_id][__EVENT_LANG_CHS],
                $event_id,
                __EVENT_CLASS_NORMAL,
                'N/A',
                @date('Y-m-d H:i:s', $upload_time[$host]),
                $uiWordArr[$host][$event_id]
            );
        }
    }
    if (!$err) {
        if (!empty($line)) {
            // 暂时不分页，前端仍旧使用/get/event/@all的分页数据格式
            $temp_page = array('records'=>$line, 'page_info'=>array('total_pages'=>1,'current_page'=>1,'line_per_page'=>100000,'next_page'=>0,'prev_page'=>0));
            echo json_encode($temp_page);
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        } else {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_NOT_FOUND;
        }
    }
    break;
}
?>
