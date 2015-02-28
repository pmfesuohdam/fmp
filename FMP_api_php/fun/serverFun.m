<?php
/*
  +----------------------------------------------------------------------+
  | Name:fun/serverFun.m                                                
  +----------------------------------------------------------------------+
  | Comment:处理server的函数                                            
  +----------------------------------------------------------------------+
  | Author:evoup                                                         
  +----------------------------------------------------------------------+
  | Created:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-03-22 14:19:21
  +----------------------------------------------------------------------+
 */

$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; // 默认返回400 
header("Content-type: application/json; charset=utf-8");

$err = false;
/* 获取全部主机之后，进行分页，对每页上需要的数据在从mdb中获取对应数据 */ 

// 获取当前扫描的节点
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
        $tempArr = $GLOBALS['mdb_client']->get(__MDB_TAB_ENGINE, 'monitorengine|'.$serverNode, "scan:master");
        if ($tempArr[0]->value) {
            $monitorNode=$serverNode;
            break 2;
        } else {
            $monitorNode='--';
        }
    }
}

switch ($GLOBALS['selector']) {
case(__SELECTOR_MASSUP):
case(__SELECTOR_MASSDOWN):
case(__SELECTOR_MASSUNMON):
case(__SELECTOR_MASS):
case(__SELECTOR_MOBCLIENT_ALLUP):
case(__SELECTOR_MOBCLIENT_ALLDOWN):
case(__SELECTOR_MASSUNSCALING):
case(__SELECTOR_MOBCLIENT_ALLUNSCALING):
    $autoScaleServers=getAutoScalingSrvs();
    if (!canAccess('read_serverList')) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
        return;
    }
    /* {{{ 扫描所有主机或者带过滤的获取服务器列表
     */
    $hst_stat_arr=getHostFinalStatus();
    if ($GLOBALS['operation'] == __OPERATION_READ) {
        list($table_name, $start_row, $family) = array(__MDB_TAB_HOST, '', array('info')); // 从row的起点开始 
        switch (ltrim(trim($GLOBALS['rowKey']))) {
        case(''): // 没有过滤，get全部 
            try {
                $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
                while (true) {
                    $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                    if (array_filter($get_arr) == null) break;
                    foreach ( $get_arr as $TRowResult ) {
                        if ($TRowResult->columns['info:deleted']) { // 对于删除的不用显示了,交给服务端删
                            continue;
                        }
                        $last_check_time = !empty($TRowResult->columns['info:last_check']->value) ?@date("Y-m-d H:i:s", $TRowResult->columns['info:last_check']->value) :'wait scan';
                        if (!empty($TRowResult->row)) {
                            /*{{{ 获取监控状态
                             */
                            $Monitored = in_array($TRowResult->row, explode(',', $_CONFIG['not_monitored']['not_monitored'])) ?__UI_UNMONITORED :$monitorNode; // 从配置文件中一次性取出增加性能 
                            /* }}} */
                            switch ($GLOBALS['selector']) {
                            case(__SELECTOR_MASSUP): // 全部在线的服务器 
                            case(__SELECTOR_MOBCLIENT_ALLUP): // (for 智能手机客户端)  // TODO 这部分逻辑独立到一个控制器 
                                if ($Monitored!=__UI_UNMONITORED && $TRowResult->columns['info:status']->value==__HOST_STATUS_UP) {
                                    if ($GLOBALS['selector']==__SELECTOR_MASSUP) {
                                        $host_arr[$TRowResult->row] = array(
                                            $TRowResult->columns['info:status']->value, // 状态 
                                            $TRowResult->columns['info:ip']->value, // IP 
                                            @date("Y-m-d H:i:s",$TRowResult->columns['info:last_upload']->value), // 上次上传时间 
                                            //$last_check_time, // 上次检查时间 
                                            $monitorNode,
                                            getDhms($TRowResult->columns['info:summary_uptime']->value) // 总计运行时间 
                                        );
                                    } elseif ($GLOBALS['selector']==__SELECTOR_MOBCLIENT_ALLUP) {
                                        $allOnlineHosts++;
                                    }
                                }
                                break;
                            case(__SELECTOR_MASSUNSCALING):
                            case(__SELECTOR_MOBCLIENT_ALLUNSCALING):
                                if ($Monitored!=__UI_UNMONITORED && $TRowResult->columns['info:status']->value==__HOST_STATUS_DOWN
                                 && in_array($TRowResult->row,$autoScaleServers)) {
                                    if ($GLOBALS['selector']==__SELECTOR_MASSUNSCALING) {
                                            $host_arr[$TRowResult->row] = array(
                                                __HOST_STATUS_UNSCALING, // 状态
                                                $TRowResult->columns['info:ip']->value, // IP 
                                                @date("Y-m-d H:i:s",$TRowResult->columns['info:last_upload']->value), // 上次上传时间 
                                                //$last_check_time, // 上次检查时间 
                                                $monitorNode,
                                                getDhms($TRowResult->columns['info:summary_uptime']->value) // 总计运行时间 
                                            );
                                    } else {
                                        $allUnscalingHosts++;
                                    }
                                }
                                break;
                            case(__SELECTOR_MASSDOWN): // 全部宕机的服务器 
                            case(__SELECTOR_MOBCLIENT_ALLDOWN): // (for 智能手机客户端) 
                                if ($Monitored!=__UI_UNMONITORED && $TRowResult->columns['info:status']->value==__HOST_STATUS_DOWN) {
                                    if ($GLOBALS['selector']==__SELECTOR_MASSDOWN && !in_array($TRowResult->row,$autoScaleServers)) {
                                        $host_arr[$TRowResult->row] = array(
                                            $TRowResult->columns['info:status']->value, // 状态 
                                            $TRowResult->columns['info:ip']->value, // IP 
                                            @date("Y-m-d H:i:s",$TRowResult->columns['info:last_upload']->value), // 上次上传时间 
                                            //$last_check_time, // 上次检查时间 
                                            $monitorNode,
                                            getDhms($TRowResult->columns['info:summary_uptime']->value) // 总计运行时间 
                                        );
                                    } elseif ($GLOBALS['selector']==__SELECTOR_MOBCLIENT_ALLDOWN && !in_array(
                                    $TRowResult->row,$autoScaleServers)) {
                                        $allDownHosts++;
                                    }
                                }
                                break;
                            case(__SELECTOR_MASSUNMON): // 全部未监控的服务器 
                                $Monitored==__UI_UNMONITORED && $host_arr[$TRowResult->row] = array(
                                    __HOST_STATUS_UNKNOWN,
                                    $TRowResult->columns['info:ip']->value,
                                    @date("Y-m-d H:i:s",$TRowResult->columns['info:last_upload']->value), // 上次上传时间 
                                    $monitorNode,
                                    getDhms($TRowResult->columns['info:summary_uptime']->value) // 总计运行时间 
                                );
                                break;
                            default: // 全部服务器 
                                if (in_array($TRowResult->row,$autoScaleServers)) { //auto scale撤销的server不算宕
                                    if ($hst_stat_arr[$TRowResult->row]==__HOST_STATUS_DOWN) {
                                        $hst_stat_arr[$TRowResult->row]=__HOST_STATUS_UNSCALING;
                                    }
                                }
                                $host_arr[$TRowResult->row] = array(
                                    $Monitored!=__UI_UNMONITORED ?$hst_stat_arr[$TRowResult->row] :__HOST_STATUS_UNKNOWN, // 状态 
                                    $TRowResult->columns['info:ip']->value, // IP 
                                    @date("Y-m-d H:i:s",$TRowResult->columns['info:last_upload']->value), // 上次上传时间 
                                    //$last_check_time, // 上次检查时间 
                                    $monitorNode,
                                    getDhms($TRowResult->columns['info:summary_uptime']->value) // 总计运行时间 
                                );
                                break;
                            }
                        }
                    }
                }
                $GLOBALS['mdb_client']->scannerClose($scanner); // 关闭scanner
            } catch (Exception $e) {
                $err = true;
            }
            break;
        default: // 有过滤，仅仅或者单台 
            try {
                $scanner = $GLOBALS['mdb_client']->scannerOpen($table_name, $start_row , $family);
                while (true) {
                    $get_arr = $GLOBALS['mdb_client']->scannerGet($scanner);
                    if (array_filter($get_arr) == null) break;
                    foreach ($get_arr as $TRowResult) {
                        !empty($TRowResult->row) && $total_host[$TRowResult->row] = 1;
                    }
                }
                $GLOBALS['mdb_client']->scannerClose( $scanner ); // 关闭scanner
                !in_array($GLOBALS['rowKey'], array_keys($total_host)) && $NotFound = true;
                if (!$err) {
                    $arr = $GLOBALS['mdb_client']->getRowWithColumns($table_name, $GLOBALS['rowKey'], array('info'));
                    $arr = $arr[0]->columns;
                    if ( $arr['info:deleted'] ) { //删除的不显示 
                        continue;
                    }

                    /*{{{ 获取监控状态
                     */
                    $Monitored = in_array($GLOBALS['rowKey'], explode(',', $_CONFIG['not_monitored']['not_monitored'])) ?__UI_UNMONITORED :$monitorNode; // 从配置文件中一次性取出增加性能 
                    /* }}} */

                    switch ($GLOBALS['selector']) {
                    case(__SELECTOR_MASSUP): // 全部在线的服务器 
                        $Monitored!=__UI_UNMONITORED && $arr['info:status']->value ==__HOST_STATUS_UP && $host_arr[$GLOBALS['rowKey']] = array(
                            $arr['info:status']->value, // 状态 
                            $arr['info:ip']->value, // IP 
                            @date("Y-m-d H:i:s",$arr['info:last_upload']->value), // 上次上传时间 
                            $monitorNode, 
                            getDhms($arr['info:summary_uptime']->value) // 总计运行时间 
                        );
                        break;
                    case(__SELECTOR_MASSDOWN): // 全部宕机的服务器 
                        $Monitored!=__UI_UNMONITORED && $arr['info:status']->value ==__HOST_STATUS_DOWN && $host_arr[$GLOBALS['rowKey']] = array(
                            $arr['info:status']->value, // 状态 
                            $arr['info:ip']->value, // IP 
                            @date("Y-m-d H:i:s",$arr['info:last_upload']->value), // 上次上传时间 
                            $monitorNode,
                            getDhms($arr['info:summary_uptime']->value) // 总计运行时间 
                        );
                        break;
                    case(__SELECTOR_MASSUNMON): // 全部未监控的服务器 
                                $Monitored==__UI_UNMONITORED && $host_arr[$GLOBALS['rowKey']] = array(
                                    __HOST_STATUS_UNKNOWN, // 状态 
                                    $arr['info:ip']->value,
                                    @date("Y-m-d H:i:s",$arr['info:last_upload']->value), // 上次上传时间 
                                    $monitorNode,
                                    getDhms($arr['info:summary_uptime']->value) // 总计运行时间 
                                );
                        break;
                    default: // 全部服务器 
                        $host_arr[$GLOBALS['rowKey']] = array(
                            $arr['info:status']->value, // 状态 
                            $arr['info:ip']->value, // IP 
                            @date("Y-m-d H:i:s",$arr['info:last_upload']->value), // 上次上传时间 
                            $monitorNode,
                            getDhms($arr['info:summary_uptime']->value) // 总计运行时间 
                        );
                        break;
                    }
                }
            } catch (Exception $e) {
                $err = true;
            }
            break;
        }
        if (!$err) {
            if (!empty($host_arr) && !$NotFound) {
                echo json_encode($host_arr);
                $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
            } elseif ($GLOBALS['selector']==__SELECTOR_MOBCLIENT_ALLUP) { // 智能手机客户端的特殊处理 
                echo $allOnlineHosts;
            } elseif ($GLOBALS['selector']==__SELECTOR_MOBCLIENT_ALLDOWN) {
                echo $allDownHosts;
            } elseif ($GLOBALS['selector']==__SELECTOR_MOBCLIENT_ALLUNSCALING) {
                echo $allUnscalingHosts;
            } else {
                //返回空
                $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
            }
        }
    }
    /* }}} */
    break;
case(__SELECTOR_SINGLE):
    /* {{{ 获取单台一般信息
     */
    if ($GLOBALS['operation'] == __OPERATION_READ) {
        if (!canAccess('read_serverSingle')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        list($table_name, $row_key) = array(__MDB_TAB_SERVER, $GLOBALS['rowKey']);
        try {
            // get memo
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'config:memo');
            $memo = empty($arr[0]->value)? "": $arr[0]->value;
        } catch (Exception $e) {
            $err = true;
        }
        $conf['alias'] = __NO_ALIAS;
        try {
            $arr = $GLOBALS['mdb_client']->getRowWithColumns($table_name, $row_key, array('config:'));
            foreach (array_keys((array)$arr[0]->columns) as $server_conf) {
                switch ($server_conf) {
                case('config:alias'):
                    $conf['alias'] = !empty($arr[0]->columns[$server_conf]->value)? $arr[0]->columns[$server_conf]->value: $conf['alias'];
                    break;
                case('config:auth_type'):
                    $conf['auth_type'] = $arr[0]->columns[$server_conf]->value;
                    break;
                case('config:upload_direction'):
                    $conf['upload_direction'] = $arr[0]->columns[$server_conf]->value;
                    break;
                }
            }
        } catch (Exception $e) {
            $err = true;
        }
        try {
            $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $GLOBALS['rowKey'], array('groupid:'));
            foreach (array_keys((array)$arr[0]->columns) as $tmp) {
                list(,$groupName) = explode(":", $tmp); 
                $memberGroupArr[] = $groupName;
            }
        } catch (Exception $e) {
            $err = true;
        }
        try {
            $unmonitored=explode(',',$_CONFIG['not_monitored']['not_monitored']);
            $st = $GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $row_key, 'info:status');
            $st = !in_array($row_key,$unmonitored) ?($st[0]->value==1 ?"1" :"0") :5;
            $autoScaleServers=getAutoScalingSrvs();
            if ($st==0 && in_array($row_key,$autoScaleServers)) {
                $st=__HOST_STATUS_UNSCALING;
            } 
            $ip = $GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $row_key, 'info:ip');
            $ip = $ip[0]->value;
            $last_check = $GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $row_key, 'info:last_check'); 
            $last_check = date("Y-m-d H:i:s", $last_check[0]->value);
            // get uptime day
            $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, $row_key, 'generic:summary_uptime_day');
            $uptime_day = $arr[0]->value;
            // get uptime his 
            $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, $row_key, 'generic:summary_uptime_his');
            $uptime_his = $arr[0]->value;
            list($uptime_h, $uptime_i, $uptime_s) = explode(':',$uptime_his);
        } catch (Exception $e) {
            $err = true;
        }
        $groupStr = join(',', array_filter($memberGroupArr));
        try {
            $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, $row_key, 'config:client');
            $clientVer = array_shift(explode('|',$arr[0]->value));
            $clientVer = !empty($clientVer) ?$clientVer : '版本过低,需更新';
        } catch (Exception $e) {
        }
        $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $row_key,'info:last_upload');
        $last_upload = @date("Y-m-d H:i:s", $arr[0]->value);
        if (!$err) {
            $post_info =$st!=5 ?($st ?"Server online." :"Server down.") :"Server unmonitored."; 
            $str = <<<EOT
{
   "host":"{$GLOBALS['rowKey']}",
   "desc":"{$conf['alias']}",
   "group":"{$groupStr}",
   "post_info":"{$post_info}",
   "addr":"{$ip}",
   "status":"{$st}",
   "summary_uptime":"{$uptime_day}d {$uptime_h}h {$uptime_i}m {$uptime_s}s",
   "last_upload":"{$last_upload}",
   "last_check":"{$last_check}",
   "client_ver":"{$clientVer}"
}
EOT;
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo $str;
        }
    }
    /* }}} */
    /* {{{ 删除一台服务器
     */
    if ($GLOBALS['operation'] == __OPERATION_DELETE) {
        if (!canAccess('delete_serverSingle')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        list($table_name, $row_key) = array(__MDB_TAB_SERVER, $GLOBALS['rowKey']);
        $belong_servgroup=getBelongServerGroup($row_key);
        $has_any_group=NULL;
        if ( !empty($belong_servgroup) ) {
            foreach ( $belong_servgroup as $grp => $grpInfo ) {
                list($is_member,$desc)=$grpInfo;
                if (1==$is_member) {
                    $has_any_group=true;
                    $GLOBALS['httpStatus']=__HTTPSTATUS_FORBIDDEN;
                    return;
                }
            }
        }
        try {
            // get memo
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'config:memo');
            $memo = empty($arr[0]->value)? "": $arr[0]->value;
        } catch (Exception $e) {
            $err = true;
        }
        if (!$err) {
            // 获取上次没有处理完的待删除列表
            $srvs = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, __KEY_TO_DELETE_SERVERS, __MDB_COL_CONFIG_INI);
            $srvs = (array)json_decode($srvs[0]->value);
            if ( !in_array($GLOBALS['rowKey'],$srvs) ) {
                $srvs[]=$GLOBALS['rowKey'];
                mdb_set(__MDB_TAB_HOST,__MDB_COL_DELETED,$GLOBALS['rowKey'],1);
            }
            $srvs=array_unique($srvs);
            if ( false != mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,__KEY_TO_DELETE_SERVERS, json_encode($srvs)) ) {
                DebugInfo("[$moduleName][delete server][host:{$GLOBALS['rowKey']}][ok]",3);
                // 保存到待删除列表
                $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            } else {
                DebugInfo("[$moduleName][delete server][host:{$GLOBALS['rowKey']}][failed]",3);
            }
        }
    }
    /* }}} */
    break;
case(__SELECTOR_SINGLE_DETAIL):
    /* {{{ 单台服务器的明细信息
     */
    if ($GLOBALS['operation'] == __OPERATION_READ) {
        if (!canAccess('read_serverSingle')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        //get load
        list($table_name, $row_key) = array(__MDB_TAB_SERVER, $GLOBALS['rowKey']);
        try {
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:summary_load');
            $summary_load = $arr[0]->value;
            $timeStamp = $arr[0]->timestamp; // 获取更新的时间戳 
            if (!empty($timeStamp)) {
                $timeStamp = substr(strval($timeStamp), 0, strlen($timeStamp)-3); 
                $timeStamp = @Date('Y-m-d H:i:s', $timeStamp);
            }
            // get tcp connections
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:summary_tcp_connections');
            $tcp_connections = $arr[0]->value;
            // get uptime day
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:summary_uptime_day');
            $uptime_day = $arr[0]->value;
            // get uptime his 
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:summary_uptime_his');
            $uptime_his = $arr[0]->value;
            list($uptime_h, $uptime_i, $uptime_s) = explode(':',$uptime_his);
            // get mem
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:mem_active');
            $mem_active = $arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:mem_inact');
            $mem_inact = $arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:mem_wired');
            $mem_wired = $arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:mem_cache');
            $mem_cache = $arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:mem_buf');
            $mem_buf = $arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:mem_free');
            $mem_free = $arr[0]->value;
            list($mem_active, $mem_inact, $mem_wired, $mem_cache, $mem_buf, $mem_free) =
                array_map('sizecount', array($mem_active, $mem_inact, $mem_wired, $mem_cache, $mem_buf, $mem_free));
            // get swap
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:swap_total');
            $swap_total = $arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:swap_used');
            $swap_used = $arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:swap_free');
            $swap_free = $arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:swap_inuse');
            $swap_inuse = $arr[0]->value;
            list($swap_total, $swap_used, $swap_free, $swap_inuse) =
                array_map('sizecount', array($swap_total, $swap_used, $swap_free, $swap_inuse));
            // get process
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:process_sum');
            $process_sum = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:process_starting');
            $process_starting = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:process_running');
            $process_running = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:process_sleeping');
            $process_sleeping = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:process_stopped');
            $process_stopped = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:process_zombie');
            $process_zombie = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:process_waiting');
            $process_waiting = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:process_lock');
            $process_lock = empty($arr[0]->value) ?0 :$arr[0]->value;
            // cpu
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:cpu_use');
            $cpu_use = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:cpu_nice');
            $cpu_nice = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:cpu_system');
            $cpu_system = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:cpu_interrupt');
            $cpu_interrupt = empty($arr[0]->value) ?0 :$arr[0]->value;
            $arr = $GLOBALS['mdb_client']->get($table_name, $row_key, 'generic:cpu_idle');
            $cpu_idle =  empty($arr[0]->value) ?0 :$arr[0]->value;
            $cpu_usage = sprintf('%01.2f', 100 *($cpu_use + $cpu_nice + $cpu_system)/($cpu_use + $cpu_nice + $cpu_system + $cpu_idle));
            $res = $GLOBALS['mdb_client']->getRowWithColumns($table_name, $row_key, array('generic:'));
            $arr = $res[0]->columns;
            foreach ($arr as $tmpKey => $tmpVal ) {
                list($item,$node,$something) = explode('-', $tmpKey);
                if ($item=='generic:disk' && !empty($node)) {
                    switch ($something) {
                    case('capacity'):
                        $disk[$node]['capacity'] = $tmpVal->value;
                        break;
                    case('iused'):
                        $disk[$node]['inode'] = $tmpVal->value;
                        break;
                    }
                }
                if ($item=='generic:network') {
                    switch ($something) {
                    case('in'):
                        $network_str.="interface:{$node} in site flow:{$tmpVal->value} ";
                        break;
                    case('out'):
                        $network_str.="interface:{$node} out site flow:{$tmpVal->value} ";
                        break;
                    }

                }
            }
            foreach ($disk as $node => $tmpArr) {
                $disk_str.="disk:{$node} {$disk[$node]['capacity']}% ";
                $inode_str.="inode:{$node} {$disk[$node]['inode']}% ";
            }

            // 在线状态
            // $st  = $GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $row_key, 'info:status');
            // $st = $st[0]->value==1?"在线":"宕机";
        } catch (Exception $e) {
            $err = true;
        }
        if (!$err) {
            $network_str=str_replace(array(PHP_EOL,"\t")," ",$network_str);
            $str = <<<EOT
{
    "Load Average": "{$summary_load}",
    "TCP连接数": "{$tcp_connections}",
    "cpu": "usage:{$cpu_usage}% use:{$cpu_use} nice:{$cpu_nice} system:{$cpu_system} interrupt:{$cpu_interrupt} idle:{$cpu_idle}",
    "内存": "active:{$mem_active} inactive:{$mem_inact} wired:{$mem_wired} cache:{$mem_cache} buf:{$mem_buf} free:{$mem_free}",
    "SWAP": "total:{$swap_total} used:{$swap_used} free:{$swap_free} inuse: {$swap_inuse}",
    "磁盘": "{$disk_str}",
    "文件系统Inode": "{$inode_str}",
    "进程": "sum:{$process_sum} starting:{$process_starting} running:{$process_running} sleeping:{$process_sleeping} stopped:{$process_stopped} zombie:{$process_zombie} waiting:{$process_waiting} lock:{$process_lock}",
    "网络接口": "{$network_str}"
}
EOT;
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
            echo $str;
        }
    }

    //"Mysql数据库": "Uptime:11883280  Threads_created:0  Slow_queries:0  Questions:3  Connections:3  cur_connections:1 status:master Traffic In：150 Out：1511 Statement:delete: insert: select: update: Replication:Master Db: ,Table_sum: ,maxsizeTableName: ,MaxsizeTableSize: TableName: ,DBname: ,Engine: ,Rows: ,Data_length: ,Index_length: ,Auto_increment: ,Update_time: ,Collation:",
    //"Serving": "equest:32.47times/s domainId,adposNum,adCampaignNum,bufNum,pack serialize code,publish role webserver status:ok Daemon status:ok Login:ok Adserv Status:ok Error Log:ok log process speed:12 lines/s 待处理log数:12"
    /* }}} */
    break;
case(__SELECTOR_SINGLE_SETTING):
    if ($GLOBALS['operation']==__OPERATION_READ) {
        /* {{{ 读取服务器配置(包括类型，隶属服务器组)
         */
        //提供默认值
        list($conf['alias'], $conf['monitored'], $conf['auth_type']) = array('', __SERVER_SETTING_MONITORED_YES, __SERVER_SETTING_AUTHTYPE_NONE);

        DebugInfo("[server][read server setting][row_key:{$GLOBALS['rowKey']}]", 3);
        try {
            $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $GLOBALS['rowKey'], array('config:'));
            foreach (array_keys((array)$arr[0]->columns) as $server_conf) {
                switch ($server_conf) {
                case('config:alias'):
                    $conf['alias'] = $arr[0]->columns[$server_conf]->value;
                    break;
                case('config:auth_type'):
                    $conf['auth_type'] = $arr[0]->columns[$server_conf]->value;
                    break;
                case('config:upload_direction'):
                    $conf['upload_direction'] = $arr[0]->columns[$server_conf]->value;
                    break;
                case('config:monitored'):
                    $conf['monitored'] = $arr[0]->columns[$server_conf]->value;
                    break;
                case('config:memo'):
                    $conf['memo'] = str_replace(array("\n","\r\n"),"\\r\\n",$arr[0]->columns[$server_conf]->value);
                    break;
                case('config:district'):
                    $conf['district'] = $arr[0]->columns[$server_conf]->value;
                    break;
                case('config:carrier'):
                    $conf['carrier'] = $arr[0]->columns[$server_conf]->value;
                    break;
                }
            }
            $tmpArr=$GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $GLOBALS['rowKey'], 'info:ip');
            $conf['ip']=$tmpArr[0]->value;
        } catch (Exception $e) {
        }
        if (empty($arr)) {
            $err =true;
        }

        $str = <<<EOT
{
    "server_name": "{$GLOBALS['rowKey']}",
    "alias": "{$conf['alias']}",
    "auth_type": {$conf['auth_type']},
    "ip": "{$conf['ip']}",
    "upload_direction": {
        "{$monitorNode}": 1
    },
    "monitored": {$conf['monitored']},
    "memo": "{$conf['memo']}",
    "district": "{$conf['district']}",
    "carrier":  "{$conf['carrier']}"
}
EOT;
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; 
        echo $str;
        /* }}} */
    } elseif ($GLOBALS['operation']==__OPERATION_UPDATE) {
        /* {{{ 修改服务器配置
         */
        // 合法的POST的key
        $valid_key = array('alias', 'auth_type', 'ip', 'upload_direction', 'monitored', 'memo', 'group', 'monitoritem', 'district', 'carrier');
        if ($GLOBALS['selector'] == __SELECTOR_SINGLE_SETTING && !empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST') { // 要求上传数据非空和请求类型 
            if (!canAccess('update_serverSingle')) {
                $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
                return;
            }
            // 检查是否符合数据格式
            foreach ($valid_key as $server_key) {
                if (!in_array($server_key, array_keys($_POST))) { // 对少传判断为非法 
                    //$err = true; 
                } else {
                    $server_setting[$server_key] = $_POST[$server_key];
                } 
            } 

            if (!$err) {
                // 确认auth_type
                $server_setting['auth_type'] = $server_setting['auth_type']==__SERVER_SETTING_AUTHTYPE_TOKEN ? __SERVER_SETTING_AUTHTYPE_TOKEN :__SERVER_SETTING_AUTHTYPE_NONE;
                // TODO 检查upload direction
                // 确认monitored
                $server_setting['monitored'] = $server_setting['monitored']==__SERVER_SETTING_MONITORED_YES ?__SERVER_SETTING_MONITORED_YES :__SERVER_SETTING_MONITORED_NO;
                // 检查上传的group是否存在
                if (!empty($server_setting['group'])) {
                    $upload_groups = explode('|', $server_setting['group']);
                }
                // 获取全部自定义组
                $cust_servgroups = getAllCustGroup(); // 得到已经定义的全部自定义组 

                // 比较得到自己不属于哪些服务器组
                $notBelongedGroup =  array_diff((array)$cust_servgroups, (array)$upload_groups);
            }

            if (!$err) {
                // 解析上传的监控明细项
                DebugInfo("[server][monitoritem]".serialize($server_setting['monitoritem']), 3);
                $arr=explode('#',$server_setting['monitoritem']);
                DebugInfo("[server][AllMonItems:".serialize($AllMonItems)."]", 4);
                foreach ($arr as $monItemString) {
                    $monItem=array_shift(explode('|', $monItemString));
                    if (in_array($monItem, $AllMonItems)) {
                        $ServerMonItem[$monItem]=str_replace($monItem."|", '', $monItemString); //得到监控项目的字符串
                    }
                }
                if (!updateHostMonDetailSetting($GLOBALS['rowKey'],$ServerMonItem)) { // 更新主机的明细设置 
                    DebugInfo("[server][updateHostMonDetailSetting failed!]", 3);
                    $err=true;
                }
            }

            if (!$err) {
                // 先删除自己不属于的服务器组的column
                try {
                    foreach ($notBelongedGroup as $not_belong_grp) {
                        $GLOBALS['mdb_client']->deleteAll(__MDB_TAB_SERVER, $GLOBALS['rowKey'], "groupid:{$not_belong_grp}" ); 
                    }
                } catch (Exception $e) { 
                    $err = true;
                }
            }
            try {
                $tmpArr = $GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $GLOBALS['rowKey'], 'info:ip'); 
                $prevIp=$tmpArr[0]->value;
            } catch (Exception $e) {
                DebugInfo("[server][get prev ip fail][".$e->getMessage()."]",3);
                $err=true;
            }
            if (!$err) {
                // 然后更新数据
                $mutations = array();
                $mutations[] = new Mutation( array(
                    'column' => "config:alias", 
                    'value'  => $server_setting['alias'] 
                ));
                $mutations[] = new Mutation( array(
                    'column' => "config:auth_type", 
                    'value'  => $server_setting['auth_type'] 
                ));
                $mutations[] = new Mutation( array(
                    'column' => "config:upload_direction", 
                    'value'  => $server_setting['upload_direction'] 
                ));
                foreach ($upload_groups as $group_name) {
                    $mutations[] = new Mutation( array(
                        'column' => "groupid:$group_name", 
                        'value'  => __SERVER_IS_MEMBER_OF_THIS_GROUP 
                    ));
                }
                $mutations[] = new Mutation( array(
                    'column' => "config:monitored", 
                    'value'  => $server_setting['monitored'] 
                ));
                $mutations[] = new Mutation( array(
                    'column' => "config:memo", 
                    'value'  => $server_setting['memo'] 
                ));
                $mutations[] = new Mutation( array(
                    'column' => "config:district", 
                    'value'  => $server_setting['district'] 
                ));
                $mutations[] = new Mutation( array(
                    'column' => "config:carrier", 
                    'value'  => $server_setting['carrier'] 
                ));
                try { // 修改信息
                    $GLOBALS['mdb_client']->mutateRow( __MDB_TAB_SERVER, $GLOBALS['rowKey'], $mutations );
                } catch (Exception $e) {
                    $err = true;
                }
                // save ip to info:ip
                mdb_set(__MDB_TAB_HOST, 'info:ip', $GLOBALS['rowKey'], $server_setting['ip']);
            }

            if (!$err) {
                $GLOBALS['httpStatus'] = __HTTPSTATUS_RESET_CONTENT; 
                mdbUpdateServListCustSetting(array($GLOBALS['rowKey']=>$upload_groups)); // 维护INI中自定义组的配置 
                if ($server_setting['monitored']===__SERVER_SETTING_MONITORED_YES) { // 维护未监控服务器的配置 
                    updateUnmonSetting($GLOBALS['rowKey'], __UNMONITORED_DELETE);
                } elseif ($server_setting['monitored']===__SERVER_SETTING_MONITORED_NO) {
                    updateUnmonSetting($GLOBALS['rowKey'], __UNMONITORED_ADD);
                }
                mdbUpdateIni(); // 更新MDB中的INI配置文本
                saveProviceIpChangeMessage($GLOBALS['rowKey'],$prevIp,$server_setting['ip'],$server_setting['district'],$server_setting['carrier']); // 保存修改provide后的IP到消息队列
            }
        }
        /* }}} */
    }
    break;
case(__SELECTOR_SINGLE_GROUP):
    $arrBelong = getBelongServerGroup();
    $err = false===$arrBelong ?true :false;
    if (!$err) {
        $str = json_encode($arrBelong);
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; 
        echo $str;
    }
    break;
}

/**
 *@brief 获取服务器隶属的服务器组
 *@return 全部自定义服务器组中的,是否为该组的和该组描述的数组
 */
function getBelongServerGroup($host_name) {
    $groupArr = getAllCustGroup();
    if (false===$groupArr) { // 没有任何创建的自定义组返回空数组 
        return array();
    }
    try {
        $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $GLOBALS['rowKey'], array('groupid:'));
        foreach (array_keys((array)$arr[0]->columns) as $tmp) {
            list(, $groupName) = explode(":", $tmp); 
            $memberGroupArr[] = $groupName;
        }
    } catch (Exception $e) {
        return array(); // 出错返回空数组 
    }
    foreach ($groupArr as $grp) {
        $status = in_array($grp, $memberGroupArr) ?__UI_IS_SERVGRP_MEMBER :__UI_NOT_SERVGRP_MEMBER;
        try {
        } catch (Exception $e) {
        }
        $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, __KEY_INI_GROUP_CUST, __MDB_COL_CONFIG_INI);
        $arr = json_decode($arr[0]->value);
        $grpDetail = (array)($arr->server_group);
        foreach ($grpDetail as $group => $tmpArr) {
            if ($grp==$group) {
                $desc = $tmpArr->desc;
            }
        }
        empty($desc) && $desc = "无描述"; 
        $lastArr[$grp] = array($status, $desc);
    }
    return $lastArr; // 返回最终数组 
}
?>
