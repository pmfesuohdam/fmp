<?php
/*
  +----------------------------------------------------------------------+
  | Name:detailSetting.php
  +----------------------------------------------------------------------+
  | Comment:监控向导明细数据模块
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-12-20 17:28:35
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; // 默认返回400 
header("Content-type: application/json; charset=utf-8");
$valid_type=array(
    'generic'=>array('disk_capacity','disk_inode_capacity','load_average','memory_usage','total_processes','cpu_usage','tcp_connection','network_flow','services'),
    'mysql'=>array('mysql_connections','mysql_created_threads','mysql_crucial_table','mysql_master_slave'),
    'serving',
    'daemon',
    'report',
    'mdn',
    'hdfs',
    'jail',
    'mdb',
    'gslb',
    'security'
);
$detailSetting=array(
    __SELECTOR_GENERIC=>array( //TODO 改成实际数据 
        'ping'=>array(
            'monitored'=>1,
            'caution'=>70,
            'warning'=>50
        ),
        'disk_capacity'=>array(
            'monitored'=>1,
            'caution'=>97,
            'warning'=>100
        ),
        'disk_inode_capacity'=>array(
            'monitored'=>1,
            'caution'=>98,
            'warning'=>100
        ),
        'load_average'=>array(
            'monitored'=>1,
            'caution'=>35,
            'warning'=>120
        ),
        'memory_usage'=>array(
            'monitored'=>1,
            'caution'=>98,
            'warning'=>100
        ),
        'total_processes'=>array(
            'monitored'=>1,
            'caution'=>250,
            'warning'=>500
        ),
        'cpu_usage'=>array(
            'monitored'=>1,
            'caution'=>98,
            'warning'=>100
        ),
        'tcp_connection'=>array(
            'monitored'=>1,
            'caution'=>7000,
            'warning'=>10000
        ),
        'network_flow'=>array(
            'monitored'=>0,
            'caution'=>70009,
            'warning'=>100000
        ),
        'services'=>array(
            'mysql'=>array(1,3306,'127.0.0.1',1),
            'www'=>array(1,80,'',0)
        ),
        'processes'=>array(
            'ssdm'=>array(1,'ssdaemon',0),
            'javaproc'=>array(1,'javaproc',1)
        )
    ),
    __SELECTOR_MYSQL=>array(
        'mysql_connections'=>array(
            'monitored'=>1,
            'caution'=>300,
            'warning'=>3000
        ),
        'mysql_created_threads'=>array(
            'monitored'=>1,
            'caution'=>400,
            'warning'=>3000
        ),
        'mysql_crucial_table'=>array(
            'tbl_finance'=>array(1,334454,5554545),
            'tbl_user'=>array(1,134534,4434334),
            'tbl_session'=>array(0,123321,4444411),
            'tbl_test'=>array(0,12323,44555455)
        ),
        'mysql_master_slave'=>1,
        'mysql_seconds_behind_master'=>array(
            'monitored'=>1,
            'caution'=>7600,
            'warning'=>20000
        )
    ),
    __SELECTOR_SERVING=>array(
        'serving_request_number'=>array(
            'monitored'=>0,
            'caution'=>80000,
            'warning'=>100000
        ),
        'serving_advt_publish'=>1,
        'serving_log_creation'=>1,
        'serving_fillrate'=>array(
            'monitored'=>1,
            'caution'=>10 //这里是百分比去掉单位的数值，如10%则为10 
        )
    ),
    __SELECTOR_DAEMON=>array(
        'daemon_web_server'=>1,
        'daemon_backend_daemon'=>1,
        'daemon_login'=>1,
        'daemon_advt_deliver'=>1,
        'daemon_error_log'=>1
    ),
    __SELECTOR_REPORT=>array(
        'report_wait_process_log_number'=>array(
            'monitored'=>1,
            'caution'=>500,
            'warning'=>1000
        )
    ),
    __SELECTOR_MDN=>array(
        'mdn_domain'=>array(
            'sm2.mdn2.net'=>array(1,'202.96.209.6',10,3),
            'sm2.ifree.cn'=>array(1,'202.96.209.6',10,3),
            'smartmad.com'=>array(1,'',5,3)
        )
    )
);
switch ($GLOBALS['operation']) {
case(__OPERATION_READ):
    if (!$err) {
        $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        echo json_encode($detailSetting[$GLOBALS['selector']]);
    }
    break;
case(__OPERATION_UPDATE):
    if (!empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST') { // 要求上传数据非空和请求类型 
        //检查上传类型
        $postType=str_replace('@','',$GLOBALS['selector']);
        !in_array($postType,array_keys($valid_type)) && $err=true;
        if (!$err) {
            $err=checkDetailPost($postType);
        }
        if (!$err) {
            DebugInfo("[detailSetting][update][type:{$postType}]", 3);
            switch ($postType) {
            case('generic'):
                /* {{{ 获取和检查上传的磁盘占用率设置
                 */
                list($disk_capacity_m,$disk_capacity_c,$disk_capacity_w)=array_pad(explode('|',$_POST['disk_capacity']),3,0);
                $disk_capacity_m=in_array($disk_capacity_m, array(__EV_MONITORED, __EV_UNMONITORED))?$disk_capacity_m:__EV_MONITORED;
                $disk_capacity_c+=0;
                $disk_capacity_w+=0;
                if ($disk_capacity_c<0 || $disk_capacity_c>100) {
                    $err=true;
                }
                if (!$err && ($disk_capacity_w<$disk_capacity_c || $disk_capacity_w>100)) {
                    $err=true;
                }
                /* }}} */
                /* {{{ 获取和检查上传的磁盘INODE占用率设置
                 */
                list($disk_inode_capacity_m,$disk_inode_capacity_c,$disk_inode_capacity_w)=array_pad(explode('|',$_POST['disk_inode_capacity']),3,0);
                $disk_inode_capacity_m=in_array($disk_inode_capacity_m, array(__EV_MONITORED, __EV_UNMONITORED))?$disk_inode_capacity_m:__EV_MONITORED;
                $disk_inode_capacity_c+=0;
                $disk_inode_capacity_w+=0;
                if ($disk_inode_capacity_c<0 || $disk_inode_capacity_c>100) {
                    $err=true;
                }
                if (!$err && ($disk_inode_capacity_w<$disk_inode_capacity_c || $disk_inode_capacity_w>100)) {
                    $err=true;
                }
                /* }}} */
                /* {{{ 获取和检查上传的平均LOAD设置
                 */
                list($load_average_m,$load_average_c,$load_average_w)=array_pad(explode('|',$_POST['load_average']),3,0);
                $load_average_m=in_array($load_average_m, array(__EV_MONITORED, __EV_UNMONITORED))?$load_average_m:__EV_MONITORED;
                $load_average_c+=0;
                $load_average_w+=0;
                /* }}} */
                /* {{{ 获取和检查上传的内存设置
                 */
                list($memory_usage_m,$memory_usage_c,$memory_usage_w)=array_pad(explode('|',$_POST['memory_usage']),3,0);
                $memory_usage_m=in_array($memory_usage_m, array(__EV_MONITORED, __EV_UNMONITORED))?$memory_usage_m:__EV_MONITORED;
                $memory_usage_c+=0;
                $memory_usage_w+=0;
                if ($memory_usage_c<0 || $memory_usage_c>100) {
                    $err=true;
                }
                if (!$err && ($memory_usage_w<$memory_usage_c || $memory_usage_w>100)) {
                    $err=true;
                }
                /* }}} */
                /* {{{ 获取和检查上传的进程设置
                 */
                list($total_processes_m,$total_processes_c,$total_processes_w)=array_pad(explode('|',$_POST['total_processes']),3,0);
                $total_processes_m=in_array($total_processes_m, array(__EV_MONITORED, __EV_UNMONITORED))?$total_processes_m:__EV_MONITORED;
                $total_processes_c+=0;
                $total_processes_w+=0;
                /* }}} */
                /* {{{ 获取和检查上传的CPU设置
                 */
                list($cpu_usage_m,$cpu_usage_c,$cpu_usage_w)=array_pad(explode('|',$_POST['cpu_usage'],3,0));
                $cpu_usage_m=in_array($cpu_usage_m, array(__EV_MONITORED, __EV_UNMONITORED))?$cpu_usage_m:__EV_MONITORED;
                $cpu_usage_c+=0;
                $cpu_usage_w+=0;
                if ($cpu_usage_c<0 || $cpu_usage_c>100) {
                    $err=true;
                }
                if (!$err && ($cpu_usage_w<$cpu_usage_c || $cpu_usage_w>100)) {
                    $err=true;
                }
                /* }}} */
                /* {{{ 获取和检查上传的TCP连接数设置
                 */
                list($tcp_connection_m,$tcp_connection_c,$tcp_connection_w)=array_pad(explode('|',$_POST['tcp_connection']),3,0);
                $tcp_connection_m=in_array($tcp_connection_m, array(__EV_MONITORED, __EV_UNMONITORED))?$tcp_connection_m:__EV_MONITORED;
                $tcp_connection_c+=0;
                $tcp_connection_w+=0;
                if (!$err && $tcp_connection_c<0) {
                    $err=true;
                }
                if (!$err && $tcp_connection_w<$tcp_connection_c) {
                    $err=true;
                }
                /* }}} */
                /* {{{ 获取和设置上传的网卡流量设置
                 */
                list($network_flow_m,$network_flow_c,$network_flow_w)=array_pad(explode('|',$_POST['network_flow']),3,0);
                $network_flow_m=in_array($network_flow_m, array(__EV_MONITORED, __EV_UNMONITORED))?$network_flow_m:__EV_MONITORED;
                if (!$err && $network_flow_c<0) {
                    $err=true;
                }
                if (!$err && $network_flow_w<$network_flow_c) {
                    $err=true;
                }
                /* }}} */
                /* {{{ 获取和设置上传的TCP服务设置
                 */
                $arr=explode('#',$_POST['services']);
                foreach ($arr as $service_str) {
                    list($service_m,$service_name,$service_port)=explode('|',$service_str);
                    $service_m=in_array($service_m, array(__EV_MONITORED,__EV_UNMONITORED))?$service_m:__EV_MONITORED;
                    if (!$err && empty($service_name) && strlen($service_name)>20) {
                        $err=true;
                    }
                    if (!empty($service_name)) {
                        if (empty($serviceStr)) {
                            $serviceStr=$service_name.','.$service_m.','.$service_port;
                        } else {
                            $serviceStr.=';'.$service_name.','.$service_m.','.$service_port;
                        }
                    }
                }
                /* }}} */
                if (!$err) {
                    $monStr=__EVN_DISK_CAPACITY."#{$disk_capacity_m},{$disk_capacity_c},{$disk_capacity_w}|".
                        __EVN_DISK_INODE_CAPACITY."#{$disk_inode_capacity_m},{$disk_inode_capacity_c},{$disk_capacity_w}|".
                        __EVN_LOAD_AVERAGE."#{$load_average_m},{$load_average_c},{$load_average_w}|".
                        __EVN_MEMORY_USAGE."#{$memory_usage_m},{$memory_usage_c},{$memory_usage_w}|".
                        __EVN_TOTAL_PROCESS."#{$total_processes_m},{$total_processes_c},{$total_processes_w}|".
                        __EVN_CPU_USAGE."#{$cpu_usage_m},{$cpu_usage_c},{$cpu_usage_w}|".
                        __EVN_NETWORK_FLOW."#{$network_flow_m},{$network_flow_c},{$network_flow_w}|".
                        __EVN_TCP_PORT."#{$serviceStr}";
                }
                break;
            case('mysql'):
                /* {{{ 获取和检查上传的MYSQL连接数设置
                 */
                list($mysql_connections_m,$mysql_connections_c,$mysql_connections_w)=array_pad(explode('|',$_POST['mysql_connections']),3,0);
                $mysql_connections_m=in_array($mysql_connections_m, array(__EV_MONITORED, __EV_UNMONITORED))?$mysql_connections_m:__EV_MONITORED;
                $mysql_connections_c+=0;
                $mysql_connections_w+=0;
                /* }}} */
                /* {{{ 获取和检查上传的MYSQL创建线程设置
                 */
                list($mysql_created_threads_m,$mysql_created_threads_c,$mysql_created_threads_w)=explode('|',$POST['mysql_created_threads'],3,0);
                $mysql_created_threads_m=in_array($mysql_created_threads_m, array(__EV_MONITORED, __EV_UNMONITORED))?$mysql_created_threads_m:__EV_MONITORED;
                $mysql_created_threads_c+=0;
                $mysql_created_threads_w+=0;
                /* }}} */
                /* {{{ 获取和检查上传的MYSQL的MASTER和SLAVE设置
                 */
                $mysql_master_slave_m=$_POST['mysql_master_slave'];
                $mysql_master_slave_m=in_array($mysql_master_slave_m, array(__EV_MONITORED, __EV_UNMONITORED))?$mysql_master_slave_m:__EV_MONITORED;
                /* }}} */
                /* {{{ 获取和检查上传的MYSQL关键表设置
                 */
                $arr=explode('#',$_POST['mysql_crucial_table']);
                foreach ($arr as $mysql_table_str) {
                    list($table_m,$table_name,$table_size_c,$table_size_w)=explode('|',$mysql_table_str);
                    $table_m=in_array($table_m, array(__EV_MONITORED,__EV_UNMONITORED))?$table_m:__EV_MONITORED;
                    if (!$err && empty($table_name) && strlen($table_name)>30) {
                        $err=true;
                    }
                    if (!empty($table_name)) {
                        if (empty($tableStr)) {
                            $tableStr=$table_name.','.$table_m.','.$table_size_c.','.$table_size_w;
                        } else {
                            $tableStr.=';'.$table_name.','.$table_m.','.$table_size_c.','.$table_size_w;
                        }
                    }
                }
                /* }}} */
                if (!$err) {
                    $monStr=__EVN_MYSQL_CONNECTION."#{$mysql_connections_m},{$mysql_connections_c},{$mysql_connections_w}|".
                        __EVN_MYSQL_THREADS."#{$mysql_created_threads_m},{$mysql_created_threads_c},{$mysql_created_threads_w}|".
                        __EVN_MYSQL_MSTSLV."#{$mysql_master_slave_m}|".
                        __EVN_MYSQL_CRUCIAL_TABLE."#{$tableStr}";
                }
                break;
            case('serving'):
                /* {{{ 获取和检查上传的SERVING的请求数量设置
                 */
                list($serving_request_number_m,$serving_request_number_c,$serving_request_number_w)=array_pad(explode('|',$_POST['serving_request_number'],3,0));
                $serving_request_number_m=in_array($serving_request_number_m, array(__EV_MONITORED, __EV_UNMONITORED))?$serving_request_number_m:__EV_MONITORED;
                $serving_request_number_c+=0;
                $serving_request_number_w+=0;
                /* }}} */
                /* {{{ 获取和检查上传的SERVING的广告发布设置
                 */
                $serving_advt_publish_m=$_POST['serving_advt_publish'];
                $serving_advt_publish_m=in_array($serving_advt_publish_m, array(__EV_MONITORED, __EV_UNMONITORED))?$serving_advt_publish_m:__EV_MONITORED;
                /* }}} */
                /* {{{ 获取和检查上传的SERVING的日志生成设置
                 */
                $serving_log_creation_m=$_POST['serving_log_creation'];
                $serving_log_creation_m=in_array($serving_log_creation_m, array(__EV_MONITORED, __EV_UNMONITORED))?$serving_log_creation_m:__EV_MONITORED;
                /* }}} */
                /* {{{ 获取和检查上传的SERVING的广告填充率设置
                 */
                list($serving_fillrate_m,$serving_fillrate_c)=explode('|',$_POST['serving_fillrate']);
                $serving_fillrate_m=in_array($serving_fillrate_m, array(__EV_MONITORED,__EV_UNMONITORED ))?$serving_fillrate_m:__EV_MONITORED;
                $serving_fillrate_c+=0;
                if ($serving_fillrate_c<0 || $serving_fillrate_c>100) {
                    $err=true;
                }
                /* }}} */
                if (!$err) {
                    $monStr=__EVN_SERVING_REQUEST_NUM."#{$serving_request_number_m},{$serving_request_number_c},{$serving_request_number_w}|".
                        __EVN_SERVING_ADVT_PUBLISH."#{$serving_advt_publish_m}|".
                        __EVN_SERVING_LOG_CREATION."#{$serving_log_creation_m}|".
                        __EVN_SERVING_ADVT_FILLRATE."#{$serving_fillrate_m},{$serving_fillrate_c}";
                }
                break;
            case('daemon'):
                /* {{{ 获取和检查上传的DAEMON的web服务器设置
                 */
                $daemon_web_server_m=$_POST['daemon_web_server'];
                $daemon_web_server_m=in_array($daemon_web_server_m, array(__EV_MONITORED, __EV_UNMONITORED))?$daemon_web_server_m:__EV_MONITORED;
                /* }}} */
                /* {{{ 获取和检查上传的DAEMON的后台守护进程设置
                 */
                $daemon_backend_daemon_m=$_POST['daemon_backend_daemon'];
                $daemon_backend_daemon_m=in_array($daemon_backend_daemon_m, array(__EV_MONITORED, __EV_UNMONITORED))?$daemon_backend_daemon_m:__EV_MONITORED;
                /* }}} */
                /* {{{ 获取和检查上传的DAEMON的daemon_login设置
                 */
                $daemon_login_m=$_POST['daemon_login'];
                $daemon_login_m=in_array($daemon_login_m, array(__EV_MONITORED, __EV_UNMONITORED))?$daemon_login_m:__EV_MONITORED;
                /* }}} */
                /* {{{ 获取和检查上传的DAEMON的广告投放设置
                 */
                $daemon_advt_deliver_m=$_POST['daemon_advt_deliver'];
                $daemon_advt_deliver_m=in_array($daemon_advt_deliver_m, array(__EV_MONITORED, __EV_UNMONITORED))?$daemon_advt_deliver_m:__EV_MONITORED;
                /* }}} */
                /* {{{ 获取和检查上传的DAEMON的错误日志设置
                 */
                $daemon_error_log_m=$_POST['daemon_error_log'];
                $daemon_error_log_m=in_array($daemon_error_log_m, array(__EV_MONITORED, __EV_UNMONITORED))?$daemon_error_log_m:__EV_MONITORED;
                /* }}} */
                if (!$err) {
                    $monStr=__EVN_DAEMON_WEB_SERVER."#{$daemon_web_server_m}|".
                        __EVN_DAEMON_BACKEND_DAEMON."#{$daemon_backend_daemon_m}|".
                        __EVN_DAEMON_LOGIN."#{$daemon_login_m}|".
                        __EVN_DAEMON_ADVT_DELIVER."#{$daemon_advt_deliver_m}|".
                        __EVN_DAEMON_ERRORLOG."#{$daemon_error_log_m}|";
                }
                break;
            case('report'):
                /* {{{ 获取和检查上传的REPORT的待处理日志设置
                 */
                $report_wait_process_log_number_m=$_POST['report_wait_process_log_number'];
                $report_wait_process_log_number_m=in_array($report_wait_process_log_number_m, array(__EV_MONITORED, __EV_UNMONITORED))
                    ?$report_wait_process_log_number_m:__EV_MONITORED;
                /* }}} */
                if (!$err) {
                    $monStr=__EVN_REPORT_WAIT_PROCESS_LOG."#{$report_wait_process_log_number_m}";
                }
                break;
            case('mdn'):
                /* {{{ 获取和检查上传的DNS的A记录设置
                 */
                #1|sm2.mdn2.net|10|3#1|sm2.ifree.cn|10|3#1|smartmad.com|5|3
                $tempArr=explode('#',$_POST['dns']);
                foreach ($tempArr as $dmnStr) {
                    list($domain_m,$domain_name,$dns_srv_ip,$monitor_fequecy,$monitor_retry)=array_pad(explode('|',$dmnStr),5,0);
                    $domain_m=in_array($domain_m, array(__EV_MONITORED,__EV_UNMONITORED))?$domain_m:__EV_MONITORED;
                    if (!$err && empty($domain_name) && strlen($domain_name)>30) {
                        $err=true;
                    }
                    if (!empty($domain_name)) {
                    
                    }
                    if (!empty($domain_name)) {
                        if (empty($domainStr)) {
                            $domainStr=$domain_name.','.$domain_m.','.$dns_srv_ip.','.$monitor_fequecy.','.$monitor_retry;
                        } else {
                            $domainStr.=';'.$domain_name.','.$domain_m.','.$dns_srv_ip.','.$monitor_fequecy.','.$monitor_retry;
                        }
                    }
                }
                /* }}} */
                if (!$err) {
                    $monStr= __EVN_MDN_DNS_ARECORD."#{$domainStr}";
                }
                break;
            case('hdfs'):
                break;
            case('jail'):
                break;
            case('mdb'):
                break;
            case('gslb'):
                break;
            case('security'):
                break;
            }
        }
    }
    if (!$err && updateDetailItemSetting($monStr,$GLOBALS['rowKey'])) {
        $GLOBALS['httpStatus']=__HTTPSTATUS_RESET_CONTENT;
    }
    break;
}

/**
 *@brief 检查上传信息是否足够
 */
function checkDetailPost($type) {
    foreach ($valid_type[$type] as $valid_key) {
        if (!in_array($valid_key,array_keys($_POST))) {
            $err=true;
        }
    }
    return $err;
}

/**
 *@brief 更新服务器明细设置(各项的具体报警设置)
 *@param $setContent 设置的明细字符串
 *@param $hst 主机名
 */
function updateDetailItemSetting($setContent,$hst) {
    DebugInfo("[fun.updateDetailItemSetting][type:{$type}][val:{$setContent}]", 3);
    if (empty($setContent)) {
        return false;
    }
    // 取出已保存的
    try {
        $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, sprintf(__KEY_HOST_DETAIL_ITEM_SETTING,$hst), __MDB_COL_CONFIG_INI);
        $settedStr = empty($arr[0]->value)? "": $arr[0]->value;
    } catch (Exception $e) {
        return false;
    }
    DebugInfo("[fun.updateDetailItemSetting][type:{$type}][host:$hst][settedStr:{$settedStr}]", 3);
    $settedArr=explode('|',$settedStr);
    foreach($settedArr as $settingItem) {
        list($item,$setting)=explode('#',$settingItem);
        !empty($item) && $settings[$item]=$setting;
    }
    $currentArr=explode('|',$setContent); //新的设置覆盖旧的 
    foreach($currentArr as $settingItem) {
        list($item,$setting)=explode('#',$settingItem);
        !empty($item) && $settings[$item]=$setting;
    }
    ksort($settings);
    foreach($settings as $eventNum=>$set) {
        if (empty($saveStr)) {
            $saveStr=$eventNum."#".$set;
        } else {
            $saveStr.='|'.$eventNum."#".$set;
        }
    }
    if (mdb_set(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, sprintf(__KEY_HOST_DETAIL_ITEM_SETTING,$hst), $saveStr)) {
        DebugInfo("[fun.updateDetailItemSetting][type:{$type}][host:$hst][host_detail_item set ok.]", 3);
    } else {
        DebugInfo("[fun.updateDetailItemSetting][type:{$type}][host:$hst][host_detail_item set fail.]", 3);
        $err=true;
    }
    if (!$err) {
        return true;
    }
}
?>
