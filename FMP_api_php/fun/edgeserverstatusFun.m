<?php
/*
  +----------------------------------------------------------------------+
  | Name:edgeserverstatusFun.m
  +----------------------------------------------------------------------+
  | Comment:api for 智能路由控制中心
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2012年 7月27日 星期五 11时44分57秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-07-27 14:57:50
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; // 默认返回400 
header("Content-type: application/json; charset=utf-8");

switch ($GLOBALS['operation']) {
case(__OPERATION_READ): 
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE) {
        $server_grps=$_CONFIG['server_list'];
        foreach ((array)$server_grps as $gpName => $serverInfo) {
            $gpName=str_replace('type_','',$gpName);
            if (!is_numeric($gpName) && $GLOBALS['rowKey']==$gpName) { // 挑选自定义组的部分 
                foreach ((array)explode(',',$serverInfo) as $server) {
                    try {
                        $arr=$GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $server, "info:ip");
                        $ip=$arr[0]->value;
                        $arr=$GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $server, "info:status");
                        $status=$arr[0]->value;
                        $arr=$GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, $server, "config:carrier");
                        $carrier=$arr[0]->value;
                        $arr=$GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, $server, "config:district");
                        $district=$arr[0]->value;
                        if ($status!=5) { // 不监控的排除 
                            $status=$status>0?1:0; // 状态除了宕机就是在线 
                            $out[$gpName][]=array("$server","$ip","$status","$carrier","$district");
                        }
                    } catch (Exception $e) {
                        DebugInfo("[get edgeServerStats err][err:".$e->getMessage()."]",3);
                    }
                }
            }
        }
        echo json_encode($out);
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
    }
    break;
}
?>
