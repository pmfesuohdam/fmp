<?php
/*
  +----------------------------------------------------------------------+
  | Name:logFun.m
  +----------------------------------------------------------------------+
  | Comment:事件日志函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 17:44:34
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus']=__HTTPSTATUS_NOT_FOUND;
header("Content-type: application/json; charset=utf-8");

if (!canAccess('read_eventLog')) {
    $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
    return;
}
$err = false;
$host_arr=array();
$active_event=array();
$res_unfixed=array();
/* {{{ 扫描所有主机
 */
list($table_name,$start_row,$family) = array(__MDB_TAB_HOST, '', array('info')); //从row的起点开始 
try {
    $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
    while(true) {
        $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
        if(array_filter($get_arr) == null) break;
        foreach ( $get_arr as $TRowResult ) {
            if(!empty($TRowResult->row)) {
                $host_arr[] = $TRowResult->row;
            }
        }
    }
    $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
} catch (Exception $e) {
    $err = true;
}
/* }}} */

/* {{{ 获取每台服务器的在即时表所有存在的事件,if any
 */
if(!$err) {
    foreach((array)$host_arr as $row_key) {
        try{
            $res=$GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $row_key, array("event:"));
            $res=array_filter((array)($res[0]->columns));
            if(!empty($res)) {
                foreach($res as $event => $TCellobj) {
                    $event=str_replace("event:","",$event); //得到事件代码(如:011c)
                    if($event!=__EVENTCODE_DOWN) { //暂时不管宕机事件 TODO 
                        if($TCellobj->value==__EVENT_ACTIVE) {
                            $active_event[$row_key][]=$event;
                        }
                    }
                } 
            }
        } catch (Exception $e) {
            $err = true;
        }
    }
}
/* }}} */
/* {{{ 从即时信息表里获取全部未解决的事件 
 */
if(!$err) {
    foreach($active_event as $srv => $eventArr) {
        foreach($eventArr as $event){
            try{
                $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, $srv, "event:{$event}");
                //这里value是以|连接的2段，前一段为__EVENT_ACTIVE,后一段是事件的描述内容
                $res = array_filter((array)explode('|',$arr[0]->value));
                if(!empty($res) && count($res)==__NUM_EVENT_VALUE) {
                    list($event_status, $event_desc) = $res;
                    if($event_status == __EVENT_ACTIVE) {
                        $ts=$arr[0]->timestamp;
                        $res_unfixed[$ts][$srv][$event][__EVENT_ACTIVE]=$event_desc; //得到未解决事件数组 
                    }
                } else {
                    $err = true;
                }
            } catch (Exception $e) {
                $err = true;
            }
        }
    }
}
/* }}} */
/* {{{ 获取每台服务器的在历史表所有存在的事件,if any
 */
if(!$err) {
    foreach($host_arr as $row_key) {
        try{
            $res=$GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER_HISTORY, $row_key, array("event:"));
            $res=array_filter((array)($res[0]->columns));
            if(!empty($res)) {
                foreach($res as $event => $TCellobj) {
                    $event=str_replace("event:","",$event); //得到事件代码(如:011c)
                    if($event!=__EVENTCODE_DOWN) { //暂时不管宕机事件 TODO 
                        $history_event[$row_key][]=$event;
                    }
                } 
            }
        } catch (Exception $e) {
            $err = true;
        }
    }
}
/* }}} */
/* {{{ 从历史信息表里获取全部解决的事件
 */
//获取该事件的全部版本，即全部解决记录
if(!$err) {
    foreach((array)$history_event as $srv => $eventArr) {
        foreach($eventArr as $event){
            try{
                $res = $GLOBALS['mdb_client']->getVer(__MDB_TAB_SERVER_HISTORY, $srv, "event:{$event}", 1000);
                foreach($res as $TCellobj) {
                    //$start_ts = $TCellobj->value; 
                    $arr = $TCellobj->value; 
                    $arr = array_filter((array)explode('|',$arr));
                    if(!empty($arr) && count($arr)==__NUM_EVENT_VALUE) {
                        $start_ts = $arr[0];
                        $event_desc = $arr[1]; 
                        $fixed_ts = $TCellobj->timestamp;
                        $history_start_event[$start_ts][$srv][$event][__EVENT_ACTIVE] = $event_desc;
                        $history_fixed_event[$fixed_ts][$srv][$event][__EVENT_FIXED]  = $event_desc;
                    }
                }
            } catch (Exception $e) {
                $err = true;
            }
        }
    }
}
/* }}} */
/* {{{ 组成行数据
 */
if(!$err) {
    $last_arr=array();
    $last_arr+=(array)$res_unfixed;
    $last_arr+=(array)$history_start_event;
    $last_arr+=(array)$history_fixed_event;
    krsort($last_arr);
    foreach($last_arr as $ts => $srv) {
        foreach($srv as $srv_name => $eventArr) {
            if(@!$info_readed[$srv_name]) { //确保只读一次，否则性能低下 
                $rs = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER_HISTORY, $srv_name, array('info:'));
                $info_readed[$srv_name] = true;
            }
            foreach($eventArr as $event => $statusArr) {
                $event_lev=substr($event,3,1); //获取事件等级 
                $event_num=substr($event,0,3); //获取事件号 
                foreach($statusArr as $status => $desc) {
                    $status_txt = $status==__EVENT_ACTIVE? __EVENT_TEXT_ACTIVE: __EVENT_TEXT_FIXED;
                    switch($event_lev) {
                    case(__EVENT_LEV_NORMAL):
                        $log_arr[]=array(__EVENT_LEV_NORMAL_NUM,date("Y-m-d H:i:s", $ts), "[$status_txt]CURRENT EVENT STATUS: $desc");
                        break;
                    case(__EVENT_LEV_CAUTION):
                        $icon_status = $status==__EVENT_ACTIVE? __EVENT_LEV_CAUTION_NUM: __EVENT_LEV_NORMAL_NUM;
                        $log_arr[]=array($icon_status,date("Y-m-d H:i:s",$ts), "[$status_txt]CURRENT EVENT STATUS: $desc");
                        break;
                    case(__EVENT_LEV_WARNING):
                        $icon_status = $status==__EVENT_ACTIVE? __EVENT_LEV_WARNING_NUM: __EVENT_LEV_NORMAL_NUM;
                        $log_arr[]=array($icon_status,date("Y-m-d H:i:s",$ts), "[$status_txt]CURRENT EVENT STATUS: $desc");
                        break;
                    }
                }
            }
        }
    }
}
/* }}} */


//开始分页
$page_info = array(
    'total_page'=>1,
    'current_page'=>1,
    'line_per_page'=>20,
    'next_page'=>0,
    'prev_page'=>0
);
$res = array('record'=>$log_arr, 'page_info'=>$page_info);
if(!$err) {
    $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
    echo json_encode($res);
}
?>
