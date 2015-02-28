<?php
/*
  +----------------------------------------------------------------------+
  | Name:scan_setting.m
  +----------------------------------------------------------------------+
  | Comment:扫描的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2011年12月 5日 星期一 16时50分29秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2014-06-09 15:54:58
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

//合法的json上传key
$valid_key = array(
    'generic_disk_range',
    'generic_disk_inode',
    'generic_load_average',
    'generic_memory_usage_percent',
    'generic_running_process_num',
    'generic_tcpip_service',
    'generic_tcpip_connections',
    'generic_network_flow',
    'mysql_db_connections',
    'mysql_db_threads',
    'mysql_master_slave',
    'mysql_key_table',
    'mysql_seconds_behind_master',
    'serving_request',
    'serving_loginfo',
    'serving_deliver',
    'serving_fillrate',
    'daemon_webserver',
    'daemon_daemon',
    'daemon_login',
    'daemon_adserv',
    'daemon_errorlog',
    'report_wait_process_log_num',
    'madn_availability',
    'hadoop_dfs_datanode_copyBlockOp_avg_time',
    'hadoop_dfs_datanode_heartBeats_avg_time',
    'bizlog_httplog_4xx',
    'bizlog_httplog_5xx'
); 
switch ($GLOBALS['operation']) {
case(__OPERATION_READ):
    if (!canAccess('read_scanSet')) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
        return;
    }
    $disk_range=array_pad(explode('|',$_CONFIG['disk_range']['scan_opt']),4,0);
    $disk_inode=array_pad(explode('|',$_CONFIG['disk_inode']['scan_opt']),4,0);
    $load_average=array_pad(explode('|',$_CONFIG['load_average']['scan_opt']),4,0);
    $memory_usage_percent=array_pad(explode('|',$_CONFIG['memory_usage_percent']['scan_opt']),4,0);
    $running_process_num=array_pad(explode('|',$_CONFIG['running_process_num']['scan_opt']),4,0);
    $tcpip_service=array_pad(explode('|',$_CONFIG['tcpip_service']['scan_opt']),4,0);
    $tcpip_connections=array_pad(explode('|',$_CONFIG['tcpip_connections']['scan_opt']),4,0);
    $network_flow=array_pad(explode('|',$_CONFIG['network_flow']['scan_opt']),4,0);
    $mysql_db_connections=array_pad(explode('|',$_CONFIG['mysql_db_connections']['scan_opt']),4,0);
    $mysql_db_threads=array_pad(explode('|',$_CONFIG['mysql_db_threads']['scan_opt']),4,0);
    $mysql_master_slave=array_pad(explode('|',$_CONFIG['mysql_master_slave']['scan_opt']),4,0);
    $mysql_key_table=array_pad(explode('|',$_CONFIG['mysql_key_table']['scan_opt']),4,0);
    $mysql_seconds_behind_master=array_pad(explode('|',$_CONFIG['mysql_seconds_behind_master']['scan_opt']),4,0);
    $serving_request=array_pad(explode('|',$_CONFIG['serving_request']['scan_opt']),4,0);
    $serving_loginfo=array_pad(explode('|',$_CONFIG['serving_loginfo']['scan_opt']),4,0);
    $serving_deliver=array_pad(explode('|',$_CONFIG['serving_deliver']['scan_opt']),4,0);
    $serving_fillrate=array_pad(explode('|',$_CONFIG['serving_fillrate']['scan_opt']),4,0);
    $daemon_webserver=array_pad(explode('|',$_CONFIG['daemon_webserver']['scan_opt']),4,0);
    $daemon_daemon=array_pad(explode('|',$_CONFIG['daemon_daemon']['scan_opt']),4,0);
    $daemon_login=array_pad(explode('|',$_CONFIG['daemon_login']['scan_opt']),4,0);
    $daemon_adserv=array_pad(explode('|',$_CONFIG['daemon_adserv']['scan_opt']),4,0);
    $daemon_errorlog=array_pad(explode('|',$_CONFIG['daemon_errorlog']['scan_opt']),4,0);
    $report_wait_process_log_num=array_pad(explode('|',$_CONFIG['report_wait_process_log_num']['scan_opt']),4,0);
    $madn_availability=array_pad(explode('|',$_CONFIG['madn_availability']['scan_opt']),4,0);
    $dfs_datanode_copyBlockOp_avg_time=array_pad(explode('|',$_CONFIG['dfs_datanode_copyBlockOp_avg_time']['scan_opt']),4,0);
    $dfs_datanode_heartBeats_avg_time=array_pad(explode('|',$_CONFIG['dfs_datanode_heartBeats_avg_time']['scan_opt']),4,0);
    $bizlog_httplog_4xx=array_pad(explode('|',$_CONFIG['bizlog_httplog_4xx']['scan_opt']),4,0);
    $bizlog_httplog_5xx=array_pad(explode('|',$_CONFIG['bizlog_httplog_5xx']['scan_opt']),4,0);
    $str = <<<EOT
{
    "generic.disk_range": [
        "{$disk_range[0]}",
        "{$disk_range[1]}",
        "{$disk_range[2]}",
        "{$disk_range[3]}",
        "磁盘限额"
    ],
    "generic.disk_inode": [
        "{$disk_inode[0]}",
        "{$disk_inode[1]}",
        "{$disk_inode[2]}",
        "{$disk_inode[3]}",
        "磁盘INode限额"
    ],
    "generic.load_average": [
        "{$load_average[0]}",
        "{$load_average[1]}",
        "{$load_average[2]}",
        "{$load_average[3]}",
        "Load Average"
    ],
    "generic.memory_usage_percent": [
        "{$memory_usage_percent[0]}",
        "{$memory_usage_percent[1]}",
        "{$memory_usage_percent[2]}",
        "{$memory_usage_percent[3]}",
        "内存占用率"
    ],
    "generic.running_process_num": [
        "{$running_process_num[0]}",
        "{$running_process_num[1]}",
        "{$running_process_num[2]}",
        "{$running_process_num[3]}",
        "运行进程数"
    ],
    "generic.tcpip_service": [
        "{$tcpip_service[0]}",
        "{$tcpip_service[1]}",
        "{$tcpip_service[2]}",
        "{$tcpip_service[3]}",
        "TCP/IP服务"
    ],
    "generic.tcpip_connections": [
        "{$tcpip_connections[0]}",
        "{$tcpip_connections[1]}",
        "{$tcpip_connections[2]}",
        "{$tcpip_connections[3]}",
        "TCPIP连接数"
    ],
    "generic.network_flow": [
        "{$network_flow[0]}",
        "{$network_flow[1]}",
        "{$network_flow[2]}",
        "{$network_flow[3]}",
        "网络接口流量"
    ],
    "mysql.db_connections": [
        "{$mysql_db_connections[0]}",
        "{$mysql_db_connections[1]}",
        "{$mysql_db_connections[2]}",
        "{$mysql_db_connections[3]}",
        "MySQL连接数"
    ],
    "mysql.db_threads": [
        "{$mysql_db_threads[0]}",
        "{$mysql_db_threads[1]}",
        "{$mysql_db_threads[2]}",
        "{$mysql_db_threads[3]}",
        "MySQL运行线程数"
    ],
    "mysql.master_slave": [
        "{$mysql_master_slave[0]}",
        "{$mysql_master_slave[1]}",
        "{$mysql_master_slave[2]}",
        "{$mysql_master_slave[3]}",
        "MySQL的Master/Slave状态"
    ],
    "mysql.key_table": [
        "{$mysql_key_table[0]}",
        "{$mysql_key_table[1]}",
        "{$mysql_key_table[2]}",
        "{$mysql_key_table[3]}",
        "MySQL关键表状态"
    ],
    "mysql.seconds_behind_master": [
        "{$mysql_seconds_behind_master[0]}",
        "{$mysql_seconds_behind_master[1]}",
        "{$mysql_seconds_behind_master[2]}",
        "{$mysql_seconds_behind_master[3]}",
        "MySQL slave延迟时间"
    ],
    "serving.request": [
        "{$serving_request[0]}",
        "{$serving_request[1]}",
        "{$serving_request[2]}",
        "{$serving_request[3]}",
        "Serving请求数"
    ],
    "serving.loginfo": [
        "{$serving_loginfo[0]}",
        "{$serving_loginfo[1]}",
        "{$serving_loginfo[2]}",
        "{$serving_loginfo[3]}",
        "Serving日志生成状态"
    ],
    "serving.deliver": [
        "{$serving_deliver[0]}",
        "{$serving_deliver[1]}",
        "{$serving_deliver[2]}",
        "{$serving_deliver[3]}",
        "Serving广告投放引擎状态"
    ],
    "serving.fillrate": [
        "{$serving_fillrate[0]}",
        "{$serving_fillrate[1]}",
        "{$serving_fillrate[2]}",
        "{$serving_fillrate[3]}",
        "Serving广告填充率"
    ],
    "daemon.webserver": [
        "{$daemon_webserver[0]}",
        "{$daemon_webserver[1]}",
        "{$daemon_webserver[2]}",
        "{$daemon_webserver[3]}",
        "Daemon的Web服务器状态"
    ],
    "daemon.daemon": [
        "{$daemon_daemon[0]}",
        "{$daemon_daemon[1]}",
        "{$daemon_daemon[2]}",
        "{$daemon_daemon[3]}",
        "Daemon后守护进程状态"
    ],
    "daemon.login": [
        "{$daemon_login[0]}",
        "{$daemon_login[1]}",
        "{$daemon_login[2]}",
        "{$daemon_login[3]}",
        "Daemon的Login状态"
    ],
    "daemon.adserv": [
        "{$daemon_adserv[0]}",
        "{$daemon_adserv[1]}",
        "{$daemon_adserv[2]}",
        "{$daemon_adserv[3]}",
        "Daemon的广告投放状态"
    ],
    "daemon.errorlog": [
        "{$daemon_errorlog[0]}",
        "{$daemon_errorlog[1]}",
        "{$daemon_errorlog[2]}",
        "{$daemon_errorlog[3]}",
        "Daemon的error log状态"
    ],
    "report.wait_process_log_num": [
        "{$report_wait_process_log_num[0]}",
        "{$report_wait_process_log_num[1]}",
        "{$report_wait_process_log_num[2]}",
        "{$report_wait_process_log_num[3]}",
        "Report待处理日志数"
    ],
    "madn.availability": [
        "{$madn_availability[0]}",
        "{$madn_availability[1]}",
        "{$madn_availability[2]}",
        "{$madn_availability[3]}",
        "MADN可用性"
    ],
    "hadoop.dfs_datanode_copyBlockOp_avg_time": [
        "{$dfs_datanode_copyBlockOp_avg_time[0]}",
        "{$dfs_datanode_copyBlockOp_avg_time[1]}",
        "{$dfs_datanode_copyBlockOp_avg_time[2]}",
        "{$dfs_datanode_copyBlockOp_avg_time[3]}",
        "Hadoop datanode块复制时间"
    ],
    "hadoop.dfs_datanode_heartBeats_avg_time": [
        "{$dfs_datanode_heartBeats_avg_time[0]}",
        "{$dfs_datanode_heartBeats_avg_time[1]}",
        "{$dfs_datanode_heartBeats_avg_time[2]}",
        "{$dfs_datanode_heartBeats_avg_time[3]}",
        "Hadoop datanode向namenode汇报时间"
    ],
    "bizlog_httplog_4xx": [
        "{$bizlog_httplog_4xx[0]}",
        "{$bizlog_httplog_4xx[1]}",
        "{$bizlog_httplog_4xx[2]}",
        "{$bizlog_httplog_4xx[3]}",
        "HIVE日志HTTP 4xx请求数"
    ],
    "bizlog_httplog_5xx": [
        "{$bizlog_httplog_5xx[0]}",
        "{$bizlog_httplog_5xx[1]}",
        "{$bizlog_httplog_5xx[2]}",
        "{$bizlog_httplog_5xx[3]}",
        "HIVE日志HTTP 5xx请求数"
    ]
}
EOT;
    echo $str;
    $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
    break;
case(__OPERATION_UPDATE):
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE && !empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST') { // 要求上传数据非空和请求类型 
        if (!canAccess('update_scanSet')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        // 检查是否符合数据格式
        foreach ($valid_key as $event_key) {
            if (!in_array($event_key, array_keys($_POST))) { // 对少传判断为非法 
                $err = true;
            } else {
                list($scan_interval,$keepwatch_sec,$try, $flap_sec)=explode('|',$_POST[$event_key]);
                // 确保数据有效
                $scan_interval<0 && $scan_interval=0;
                $keepwatch_sec<0 && $keepwatch_sec=0;
                $try<0 && $try=0;
                $scan_setting[$event_key.'_scanopt']=intval($scan_interval).'|'.intval($keepwatch_sec).'|'.intval($try).'|'.intval($flap_sec);
            } 
        } 
    }
    if (!$err) {
        mdbUpdateScanSetting($scan_setting); // 更新MDB中相应的配置段落 
        mdbUpdateIni(); // 更新MDB中的INI配置文本
        $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
    }
    break;
}

?>
