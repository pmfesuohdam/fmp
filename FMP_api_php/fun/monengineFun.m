<?php
/*
  +----------------------------------------------------------------------+
  | Name:monengineFun.m
  +----------------------------------------------------------------------+
  | Comment:监控引擎的模块
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 18:13:13
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

if (!canAccess('read_enginestatus')) {
    $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
    return;
}
if (!$err) {
    $result=$GLOBALS['mdb_client']->scannerOpen(__MDB_TAB_ENGINE, '', (array)'scan:usable');
    while (true) {
        $record = $GLOBALS['mdb_client']->scannerGet($result);
        if ($record == NULL) {
            break;
        }
        $recordArray = array();
        foreach($record as $TRowResult) {
            $row=$TRowResult->row;
            list(,$serverNode)=explode('|',$row);
            $tempArr = $GLOBALS['mdb_client']->get(__MDB_TAB_ENGINE, 'monitorengine|'.$serverNode, "scan:pid");
            $serverNodes[$serverNode]['process_pid']=$tempArr[0]->value;
            $tempArr = $GLOBALS['mdb_client']->get(__MDB_TAB_ENGINE, 'monitorengine|'.$serverNode, "scan:master");
            $serverNodes[$serverNode]['action_bemaster']=$tempArr[0]->value==1?0:1; // 是master bemaster就不出 
            $tempArr = $GLOBALS['mdb_client']->get(__MDB_TAB_ENGINE, 'monitorengine|'.$serverNode, "scan:usable");
            $serverNodes[$serverNode]['process_status']=$tempArr[0]->value==1?1:0;
            $serverNodes[$serverNode]['action_start']=$serverNodes[$serverNode]['process_status']?0:1;
            $serverNodes[$serverNode]['action_stop']=$serverNodes[$serverNode]['action_start']?0:1;
            $tempArr = $GLOBALS['mdb_client']->get(__MDB_TAB_ENGINE, 'monitorengine|'.$serverNode, "scan:procstart");
            $serverNodes[$serverNode]['process_starttime']=$tempArr[0]->value;

        }
    }
    foreach (array_keys($serverNodes) as $serverNode) {
        if (!empty($serverNodes[$serverNode]['process_starttime'])) {
            $process_starttime=date('Y-m-d H:i:s',$serverNodes[$serverNode]['process_starttime']);
        } else {
            $process_starttime='';
        }
        if (!empty($serverNodes[$serverNode]['process_starttime'])) {
            $process_uptime= getDhms(time()-$serverNodes[$serverNode]['process_starttime']);
        } else {
            $process_uptime ='';
        }
        if ($serverNodes[$serverNode]['action_bemaster']) {
            $process_uptime='已结束';
        }
        $tempStr[$serverNode]
                = array(
                "process_status"    => "{$serverNodes[$serverNode]['process_status']}",
                "action_start"      => "{$serverNodes[$serverNode]['action_start']}",
                "action_stop"       => "{$serverNodes[$serverNode]['action_stop']}",
                "action_restart"    => 1,
                "action_bemaster"   => "{$serverNodes[$serverNode]['action_bemaster']}",
                "process_starttime" => $process_starttime,
                "process_uptime"    => $process_uptime,
                "process_pid"       => "{$serverNodes[$serverNode]['process_pid']}" 
            );
    }
    echo json_encode($tempStr);
    $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
}
?>
