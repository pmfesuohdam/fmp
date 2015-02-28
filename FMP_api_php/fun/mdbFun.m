<?php
/*
  +----------------------------------------------------------------------+
  | Name:fun/mdbFun.m    
  +----------------------------------------------------------------------+
  | Comment:mdb操作函数 
  +----------------------------------------------------------------------+
  | Author: Evoup evoex@126.com 
  +----------------------------------------------------------------------+
  | Created:2011-03-07 10:50:26    
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-03-21 13:51:19
  +----------------------------------------------------------------------+
 */

include_once(__THRIFT_ROOT.'/Thrift.php' );
include_once(__THRIFT_ROOT.'/transport/TSocketPool.php');
include_once(__THRIFT_ROOT.'/transport/TBufferedTransport.php' );
include_once(__THRIFT_ROOT.'/protocol/TBinaryProtocol.php' );

# According to the thrift documentation, compiled PHP thrift libraries should
# reside under the THRIFT_ROOT/packages directory.  If these compiled libraries
# are not present in this directory, move them there from gen-php/.
include_once(__THRIFT_ROOT.'/packages/Hbase/Hbase.php' );

/*
 *function openMdb() {
 *    $socket = new TSocket(__MDB_HOST, __MDB_PORT);
 *    $socket->setSendTimeout(__MDB_SENDTIMEOUT); // 2 seconds
 *    $socket->setRecvTimeout(__MDB_RECVTIMEOUT); // 2 seconds
 *    $GLOBALS['mdb_transport'] = new TBufferedTransport($socket);
 *    $protocol = new TBinaryProtocol($GLOBALS['mdb_transport']);
 *    $GLOBALS['mdb_client'] = new HbaseClient($protocol);
 *
 *    $GLOBALS['mdb_transport']->open();
 *}
 */

/**
 *@brief 打开Mdb连接 
 *@param $hosts 服务器IP:PORT数组
 *@param $sendtimeout 发送超时 
 *@param $recvtimeout 接收超时
 *@return 
 */
function openMdb($hosts, $sendtimeout=__MDB_SENDTIMEOUT, $recvtimeout=__MDB_RECVTIMEOUT) {
    global $module_name;
    try {
        if (empty($hosts) || !@is_array($hosts)) {
            throw new Exception("no db servers!");
        }
        foreach ($hosts as $serverInfo) {
            list($masterHost,$masterPort)=explode(':',$serverInfo);
            $dbHosts[]=$masterHost;
            $dbPorts[]=$masterPort;
        }
        $socket = new TSocketPool($dbHosts, $dbPorts);
        $socket->setSendTimeout($sendtimeout); // 2 seconds
        $socket->setRecvTimeout($recvtimeout); // 2 seconds
        $GLOBALS['mdb_transport'] = new TBufferedTransport($socket);
        $protocol = new TBinaryProtocol($GLOBALS['mdb_transport']);
        $GLOBALS['mdb_client'] = new HbaseClient($protocol);
        $GLOBALS['mdb_transport']->open();
        // 当前连接的host
        $connectedHost=$socket->getHost();
        $connectedPort=$socket->getPort();
        DebugInfo("[$module_name][mdb connected:{$connectedHost}({$connectedPort})]",2);
    } catch (Exception $e) {
        DebugInfo("[$module_name][open mdb error,check mdb server addr and whether mdb table integrity!]",2);
    }
}

function closeMdb() {
    if (isset($GLOBALS['mdb_transport'])) {
        $GLOBALS['mdb_transport']->close();
    }
}

/**
 *@brief 设置mdb中指定表指定列的rowkey对应的value
 *@param $table 表名
 *@param $column_name 列名（格式列族:名字）
 *@param $rowkey 行键
 *@param $value 值
 */
function mdb_set($table, $column_name, $rowkey,$value) {
    $mutations=array(
        new Mutation( array(
            'column' => $column_name,
            'value'  => $value 
        ) )
    );

    try { //thrift出错直接抛出异常需要捕获 
        $GLOBALS['mdb_client']->mutateRow( $table, $rowkey, $mutations );
        $ret = true;
    }
    catch (Exception $e) { //抛出异常返回false 
        return false;
    }
    return ($ret);
}
/**
 *@brief 获取INI模版 
 *return ini模版字符串
 */
function get_ini_template() {
    global $conf;
    $type_cust = __TEMPLATE_VAR_CUSTGROUPS;
    $iniStr = <<<EOT
[general]
version="['--\$version--']"             ;版本 
work_mode=1                             ;本配置文件的工作方式,0为本地模式(仅供调试),1为分布式模式(仅仅读取mdb_host,mdb_sendtimeout,mdb_recvtimeout)
debug_level=5                           ;调试等级,数字越大记录越详细，1~5个等级
down_over_time=['--\$down_over_time--']                       ;keepalive,超过秒数没有收到客户端上传的消息，视为down机
watchdog_url="['--\$watchdog_url--']"     ;watchdog的url，watchdog是部署在监控服务端机房外的，检查监控服务可靠性的一个CGI
client_sleep_time=['--\$client_sleep_time--']                     ;客户端的请求间隔秒数
send_daily_mail=['--\$send_daily_mail--']                       ;是否每天发送服务器工作状态邮件
send_daily_mail_time="['--\$send_daily_mail_time--']"         ;每天几点几分几秒发送
save_upload_log=1                       ;是否记录客户机上传log信息,1记录，0不记录
upload_log_facility="LOG_LOCAL3"        ;客户端上传syslog syslog_facility
upload_log_level="LOG_DEBUG"            ;客户端上传syslog syslog_level
scan_log_facility="LOG_LOCAL3"          ;服务端扫描syslog syslog_facility
scan_log_level="LOG_ALERT"              ;服务端扫描syslog syslog_level
save_update_log=1                       ;是否记录客户端更新log信息,1记录，0不记录
update_log_facility="LOG_LOCAL3"        ;客户端更新syslog syslog_facility
update_log_level="LOG_INFO"             ;客户端更新syslog syslog_level
mdb_host="{$conf['mdb_host']}" ;hbase服务器IP:PORT数组
mdb_sendtimeout=1500                    ;hbase服务器发送超时:默认1.5秒
mdb_recvtimeout=5000                   ;hbase服务器接收超时:默认5秒
send_mail_type=['--\$send_mail_type--']     ;邮件发送方式,0为sendmail（php的默认mail函数），1为使用smtp
smtp_server="['--\$smtp_server--']"     ;smtp服务器地址
smtp_port=['--\$smtp_port--']     ;smtp服务器端口
smtp_domain="['--\$smtp_domain--']"     ;smtp的域名
smtp_username="['--\$smtp_username--']"     ;smtp用户名
smtp_password="['--\$smtp_password--']"     ;smtp密码
smtp_auth=['--\$smtp_auth--']     ;smtp认证(0不需要，1需要)
smtp_timeout=40                         ;smtp超时秒数

[server_list]
type_1="['--\$type_1--']"
type_2="['--\$type_2--']"
type_3="['--\$type_3--']"
type_4="['--\$type_4--']"
type_5="['--\$type_5--']"
type_6="['--\$type_6--']"
type_7="['--\$type_7--']"
type_8="['--\$type_8--']"
type_9="['--\$type_9--']"
type_10="['--\$type_10--']"
type_11="['--\$type_11--']"
['--\${$type_cust}--']

[not_monitored]
not_monitored="['--\$not_monitored--']"

[server_group]
['--\$server_group--']

[host_monitor_detail] ;服务器的监控明细项列表(哪些项目监控)
['--\$host_monitor_detail--']

[host_monitor_item_detail] ;服务器的监控明细项列表(各项监控指标)
['--\$host_monitor_item_detail--']

[group_monitor_detail] ;服务器组的监控明细项列表
['--\$group_monitor_detail--']

[user_group] ;键为用户组名，值为用|连接的多个用户 (如: it="andson|steven")
monitoradmin="monitoradmin"
['--\$user_group--'] 

[user] ;键为用户，值分#连接的2段，报警类型和邮箱，报警类型1~5,分别为不接收，普通，严重，所有，按用户组所在服务器设置报警
['--\$user--']

[mail]
mail_from="['--\$mail_from--']"     ;发信人 
sender_name="['--\$sender_name--']" ;发件人称谓
mail_to_caution[]=""
mail_to_warning[]=""

[alarm_interval]
current_engine="['--\$current_engine--']"     ;当前执行扫描报警任务的监控服务端引擎
all_default_gp_down=['--\$all_default_gp_down--']     ;所有默认组的服务器宕机的报警间隔秒数
all_cust_gp_down=['--\$all_cust_gp_down--']     ;所有自定义组的服务器宕机的报警间隔秒数
one_default_gp_down=['--\$one_default_gp_down--']     ;单个默认组全部服务器都宕机的报警间隔秒数
one_cust_gp_down=['--\$one_cust_gp_down--']     ;单个自定义组全部服务器都宕机的报警间隔秒数
one_default_server_down=['--\$one_default_server_down--']     ;单台默认组中的服务器宕机的报警间隔秒数
one_cust_server_down=['--\$one_cust_server_down--']     ;单台自定义组中的服务器宕机的报警间隔秒数
general_server_event=['--\$general_server_event--']     ;通常的服务器事件（非down）
recover_notifiction=['--\$recover_notifiction--']     ;是否需要发送恢复通知（0为不需要，1为需要）

[disk_range]
normal_start=0                               ;normal磁盘容量下限
normal_end=['--\$disk_range_caution_start--']                                ;normal磁盘容量上限
caution_start=['--\$disk_range_caution_start--']                             ;caution磁盘容量下限
caution_end=['--\$disk_range_warn_start--']                               ;caution磁盘容量上限
warn_start=['--\$disk_range_warn_start--']                                ;warn磁盘容量下限
normal_word=""                               ;normal邮件告知文字
caution_word="%s: Disk %s usage is %d%%"     ;caution邮件告知文字
warn_word="%s: Disk %s usage is %d%%"        ;warn邮件告知文字
scan_opt = "['--\$generic_disk_range_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[disk_inode]
normal_start=0                               ;normal磁盘INode容量下限
normal_end=['--\$disk_inode_caution_start--']                                ;normal磁盘INode容量上限
caution_start=['--\$disk_inode_caution_start--']                             ;caution磁盘INode容量下限
caution_end=['--\$disk_inode_warn_start--']                               ;caution磁盘INode容量上限
warn_start=['--\$disk_inode_warn_start--']                                ;warn磁盘INode容量下限
normal_word=""                               ;normal邮件告知文字
caution_word="%s: Disk %s INode usage is %d%%"     ;caution邮件告知文字
warn_word="%s: Disk %s INode usage is %d%%"        ;warn邮件告知文字
scan_opt = "['--\$generic_disk_inode_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[load_average]
normal_start=0                                ;normal Load Average (1min)下限
normal_end=['--\$load_average_caution_start--']                                 ;normal Load Average (1min)上限
caution_start=['--\$load_average_caution_start--']                              ;caution Load Average (1min)下限
caution_end=['--\$load_average_warn_start--']                               ;caution Load Average (1min)上限
warn_start=['--\$load_average_warn_start--']                                ;warn Load Average (1min)下限
normal_word=""                                ;normal Load Average (1min)告知文字
caution_word="%s: load (%s) is larger than ['--\$load_average_caution_start--'],server performance may be reduced"  ;caution Load Average (1min)告知文字
warn_word="%s: load (%s) is larger than ['--\$load_average_warn_start--'],server performance may be reduced" ;warn Load Average (1min)告知文字
scan_opt = "['--\$generic_load_average_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[memory_usage_percent]
normal_start=0                                ;normal内存使用率下限
normal_end=['--\$memory_usage_percent_caution_start--']                                 ;normal内存使用率上限
caution_start=['--\$memory_usage_percent_caution_start--']                              ;caution内存使用率下限
warn_start=['--\$memory_usage_percent_warn_start--']                                    ;warn内存使用率下限
normal_word=""                                ;normal内存使用率告知文字
caution_word="%s: Memory usage is %01.2f%%"   ;caution内存使用率告知文字
scan_opt = "['--\$generic_memory_usage_percent_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[running_process_num]
normal_start=0                                ;normal进程数下限
normak_end=['--\$running_process_num_caution_start--']                                ;normal进程数上限
caution_start=['--\$running_process_num_caution_start--']                             ;caution进程数上限
caution_end=['--\$running_process_num_warn_start--']                               ;caution进程数上限
warn_start=['--\$running_process_num_warn_start--']                                ;warn进程数上限
normal_word=""                                ;normal进程数告知文字
caution_word="%s: The total number of processes is %d" ;caution进程数告知文字
warn_word="%s: The total number of processes is %d" ;warn进程数告知文字
scan_opt = "['--\$generic_running_process_num_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[tcpip_service]
normal_status=1                              ;normal TCP/IP服务端口状态正常
caution_status=0                             ;caution TCP/IP服务端口状态异常
normal_word=""                               ;normal TCP/Ip服务端口告知文字
caution_word="%s: TCP/IP service %s port %d CORRUPTED" ;caution TCP/IP服务端口端口告知文字
scan_opt = "['--\$generic_tcpip_service_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[tcpip_connections]
normal_start=0                               ;normal TCP/IP连接数下限
normal_end=['--\$tcpip_connections_caution_start--']                              ;normal TCP/IP连接数上限
caution_start=['--\$tcpip_connections_caution_start--']                           ;caution TCP/IP连接数下限
caution_end=['--\$tcpip_connections_warn_start--']                             ;caution TCP/IP连接数上限
warn_start=['--\$tcpip_connections_warn_start--']                              ;warn TCP/IP连接数
normal_word=""                               ;normal TCP/IP连接数告知文字
caution_word="%s: Total number of TCP/IP connections is %s , New connections may have trouble being created" ;caution TCP/IP连接数告知文字
warn_word="%s: Total number of TCP/IP connections is %s , New connections may have trouble being created" ;warn TCP/IP连接数告知文字
scan_opt = "['--\$generic_tcpip_connections_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[network_flow]
normal_start=0                               ;normal 网卡流量下限(单位byte)
normal_end=['--\$network_flow_caution_start--']                          ;normal 网卡流量上限(单位byte)
caution_start=['--\$network_flow_caution_start--']                       ;caution 网卡流量下限(单位byte)
warn_start=['--\$network_flow_warn_start--']                       ;warn 网卡流量下限(单位byte)
normal_word=""                               ;normal 网卡流量告知文字
caution_word="%s: %s network interface flow is %sbyte/s ,in is %sbyte/s,out is %sbyte/s" ;caution 网卡流量告知文字
scan_opt = "['--\$generic_network_flow_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[serving_request]
normal_start=0                               ;normal 单台负荷每秒request数下限
normal_end=['--\$serving_request_caution_start--']                               ;normal 单台负荷每秒request数上限
caution_start=['--\$serving_request_caution_start--']                            ;caution 单台负荷每秒request数下限
warn_start=['--\$serving_request_warn_start--']                              ;warn 单台负荷每秒request数下限
normal_word=""                               ;normal 单台负荷每秒request告知文字
caution_word="%s: request num is more than ['--\$serving_request_caution_start--'] reqs/s,current request number is %s reqs/s" ;caution 单台负荷每秒request告知文字
scan_opt = "['--\$serving_request_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[serving_loginfo]
caution_word   = "%s: loginfo creation failed! May be not any request incoming." ;caution 日志生成状态告知文字
scan_opt = "['--\$serving_loginfo_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[serving_deliver]
normal_status=1                              ;normal 广告发布状态正常
caution_status=0                             ;caution 广告发布状态异常(单台)
warn_status=2                                ;warning 广告发布状态异常（多台）
normal_word=""                               ;normal 广告发布告知文字
caution_word="%s: ad deliver CORRUPTED,engine status is %s" ;caution 广告发布告知文字
warn_word="more than one server deliver CORRUPTED" ;warning 广告发布告知文字
scan_opt = "['--\$serving_deliver_scanopt--']"                         ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[serving_fillrate]
caution_word = "%s: fillrate is %01.2f%%, less than %s%%" ;caution 填充率异常告知文字
caution_start=['--\$serving_fillrate_caution_start--']                    ;caution 广告填充率下限 
warn_start=['--\$serving_fillrate_warn_start--']                          ;warn 广告填充率下限 
scan_opt = "['--\$serving_fillrate_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[daemon_webserver]
normal_status=1                              ;normal webserver状态正常
warn_status=0                                ;warning webserver状态异常
warn_word="%s: webserver status CORRUPTED" ;warning webserver状态异常告知文字
scan_opt = "['--\$daemon_webserver_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[daemon_daemon]
normal_status=1                              ;normal daemon状态正常
warn_status=0                                ;warning daemon状态异常
warn_word="%s: daemon status CORRUPTED"       ;warning daemon状态异常告知文字
scan_opt = "['--\$daemon_daemon_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[daemon_login]
normal_status=1                              ;normal login状态正常
warn_status=0                                ;warning login状态异常
warn_word="%s: login status CORRUPTED"        ;warning login状态异常告知文字
scan_opt = "['--\$daemon_login_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[daemon_adserv]
normal_status=1                              ;normal adserv状态正常
warn_status=0                                ;warning adserv状态异常
warn_word="%s: adserv status CORRUPTED"       ;warning adserv状态异常告知文字
scan_opt = "['--\$daemon_adserv_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[daemon_errorlog]
normal_status=1                              ;normal errorlog状态正常
warn_status=0                                ;warning errorlog状态异常
warn_word="%s: error log status CORRUPTED"    ;warning errorlog状态异常告知文字
scan_opt = "['--\$daemon_errorlog_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[mysql_db_connections]
normal_start=0
normal_end=['--\$mysql_db_connections_caution_start--']
caution_start=['--\$mysql_db_connections_caution_start--']
caution_end=['--\$mysql_db_connections_warn_start--']
warn_start=['--\$mysql_db_connections_warn_start--']
normal_word=""
caution_word="%s:db connections is more than ['--\$mysql_db_connections_caution_start--'],%s connections now"  ;caution 数据库连接数量告知文字
warn_word="%s:db connections is more than ['--\$mysql_db_connections_warn_start--'],%s connections now" ;warning 数据库连接数量告知文字
scan_opt = "['--\$mysql_db_connections_scanopt--']"                      ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[mysql_db_threads]
normal_start=0
normal_end=['--\$mysql_db_threads_caution_start--']
caution_start=['--\$mysql_db_threads_caution_start--']
caution_end=['--\$mysql_db_threads_warn_start--']
warn_start=['--\$mysql_db_threads_warn_start--']
normal_word=""
caution_word="%s:db threads is more than ['--\$mysql_db_threads_caution_start--'],%s threads were created"  ;caution mysql数据库线程数量告知文字
warn_word="%s:db threads is more than ['--\$mysql_db_threads_warn_start--'],%s threads were created" ;warning mysql数据库线程数量告知文字
scan_opt = "['--\$mysql_db_threads_scanopt--']"                          ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[mysql_master_slave]
warn_status=0
warn_word="%s:The Master/Slave function is non-operational: Platform secondary functions are non-operational"  ;warning mysql MASTER SLAVE告知文字
scan_opt = "['--\$mysql_master_slave_scanopt--']"

[mysql_seconds_behind_master]
normal_start=0
normal_end=['--\$mysql_seconds_behind_master_caution_start--']
caution_start=['--\$mysql_seconds_behind_master_caution_start--']
caution_end=['--\$mysql_seconds_behind_master_warn_start--']
warn_start=['--\$mysql_seconds_behind_master_warn_start--']
normal_word=""
caution_word="%s:db threads is more than ['--\$mysql_db_threads_caution_start--'],%s threads were created"  ;caution mysql数据库线程数量告知文字
caution_word="%s:db slave seconds behind master is more than ['--\$mysql_seconds_behind_master_caution_start--'],%s now"  ;caution 数据库slave延迟告知文字
warn_word="%s:db slave seconds behind master is more than ['--\$mysql_seconds_behind_master_warn_start--'],%s now"  ;caution 数据库slave延迟告知文字
scan_opt = "['--\$mysql_seconds_behind_master_scanopt--']"                          ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[mysql_key_table]
caution_word="%s:table %s size too large!"       ;warning mysql key table告知文字
scan_opt = "['--\$mysql_key_table_scanopt--']"

[report_wait_process_log_num]
normal_start=0                               ;normal 待处理log下限
normal_end=['--\$report_wait_process_log_num_caution_start--']                               ;normal 待处理log上限
caution_start=['--\$report_wait_process_log_num_caution_start--']                            ;caution 待处理log下限
warn_start=['--\$report_wait_process_log_num_warn_start--']                            ;warn 待处理log下限
normal_word=""                               ;normal 待处理log告知文字
caution_word="%s:Too many logs need to processed,there are %s logs,platform stability may be reduced and reporting functions may not function correctly"
scan_opt = "['--\$report_wait_process_log_num_scanopt--']"               ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[madn_availability]
normal_status = "2XX|3XX"        ;normal返回的状态码
warn_word     = "%s: madn to %s %s"       ;warning madn告知文字
scan_opt = "['--\$madn_availability_scanopt--']"               ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

;hadoop事件
[dfs_datanode_copyBlockOp_avg_time]
caution_start = "['--\$dfs_datanode_copyBlockOp_avg_time_caution_start--']"                              ;caution 复制快平均时间
warn_start    = "['--\$dfs_datanode_copyBlockOp_avg_time_warn_start--']"
caution_word  = "%s:datanode copyBlockOp average time too long,current:%sms" ;caution copyBlockOp告知文字
scan_opt = "['--\$hadoop_dfs_datanode_copyBlockOp_avg_time_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[dfs_datanode_heartBeats_avg_time]
caution_start = "['--\$dfs_datanode_heartBeats_avg_time_caution_start--']"                                 ;caution 向namenode汇报平均时间 
warn_start    = "['--\$dfs_datanode_heartBeats_avg_time_warn_start--']"
caution_word  = "%s:datanode heartBeats average time too long,current:%sms" ;caution heartBeats告知文字 
scan_opt = "['--\$hadoop_dfs_datanode_heartBeats_avg_time_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[bizlog_httplog_4xx]
caution_start = "['--\$bizlog_httplog_4xx_caution_start--']"  ;caution hive中保存http访问日志4xx数
warn_start = "['--\$bizlog_httplog_4xx_warn_start--']"
caution_word="Too many HTTP requests statuscode of 4XX, there are %s requests"  ;在几点几分有多少个4xx请求过多
scan_opt = "['--\$bizlog_httplog_4xx_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数

[bizlog_httplog_5xx]
caution_start = "['--\$bizlog_httplog_5xx_caution_start--']"  ;caution hive中保存http访问日志5xx数
warn_start = "['--\$bizlog_httplog_5xx_warn_start--']"
caution_word="Too many HTTP requests statuscode of 5XX, there are %s requests"  ;在几点几分有多少个5xx请求过多
scan_opt = "['--\$bizlog_httplog_5xx_scanopt--']"                           ;扫描间隔秒数|守望问题事件秒数|重试次数|波动次数
EOT;
    return $iniStr; 
}

/**
 *@brief 从MDB中的各项配置生成完整的ini
 *@retrun 生成得到ini配置文件字符串 
 */
function mdbGenerateIni() {
    global $moduleName;
    $ini_tpl = get_ini_template(); //获取ini模板 
    /* {{{ 取出各项设置解析模板后得到最后的配置文件
     */
    //所有设置项组,一个json作为1个设置项组 
    $arr_row_keys = array(__KEY_INI_GENERALSETTING,__KEY_INI_MAILSETTING, __KEY_INI_ALARMSETTING, __KEY_INI_EVENTSETTING, __KEY_INI_SERVLIST, __KEY_INI_SERVLIST_CUST, __KEY_INI_GROUP_CUST, __KEY_INI_USERSETTING,__KEY_INI_USERGROUPSETTING,__KEY_INI_UNMONITORED,__KEY_INI_SCANSETTING); 
    foreach ($arr_row_keys as $row_key) {
        try { 
            $res = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER,$row_key,array(__MDB_COL_CONFIG_INI)); //取出设置项组的值 
            $res = $res[0]->columns;
            $res = $res[__MDB_COL_CONFIG_INI]->value; //获取value
            $setting = (array)json_decode($res);
            foreach ($setting as $ms_k => $ms_v) { //遍历每个设置项 
                /* {{{ 对INI模板进行设置项关键字替换
                 */
                if ($row_key == __KEY_INI_SERVLIST_CUST) { //自定义组下服务器段的特殊处理 
                    DebugInfo("[$moduleName][mdbGenerateIni][process customize group servers][ms_v:".serialize((array)$ms_v)."]", 3);
                    foreach ($ms_v as $cust_group_name => $member_servers) {
                        $cust_val .= __PREFIX_INI_SERVGROUP."$cust_group_name=\"".join(',',$member_servers)."\"\n";  //对自定义组的模板变量type_cust的解析替换值 
                    } 
                    if (!empty($cust_val)) {
                        DebugInfo("[$moduleName][mdbGenerateIni][process customize group servers][cust_val:$cust_val]", 3);
                    }
                    $ini_tpl = str_replace("['--\${$ms_k}--']", $cust_val,$ini_tpl);
                    unset($cust_val);
                } elseif ($row_key == __KEY_INI_GROUP_CUST) { //自定义组信息段的特殊处理 
                    DebugInfo("[$moduleName][mdbGenerateIni][process customize group info ][key:$ms_k]".serialize($ms_v), 3);
                    $ms_v = (array)$ms_v;
                    ksort($ms_v);
                    foreach ($ms_v as $group_name => $set_values) {
                        $cust_val .= "$group_name=\"{$set_values->mailtype}#{$set_values->membergroup}#{$set_values->monitoritem}#{$set_values->override_set}\"\n";
                    }
                    //$ms_v = $ms_k.'='.$ms_v->mailtype."#".$ms_v->membergroup.'#'.$ms_v->monitoritem;
                    DebugInfo("[$moduleName][mdbGenerateIni][process customize group info ][key:$ms_k]".serialize($ms_v), 3);
                    $ini_tpl = str_replace("['--\$server_group--']", $cust_val,$ini_tpl);
                    unset($cust_val);
                } elseif ($row_key == __KEY_INI_USERSETTING) { //用户信息段的特殊处理 
                    DebugInfo("[$moduleName][mdbGenerateIni][process user info ][key:$ms_k]".serialize($ms_v), 3);
                    $ms_v = (array)$ms_v;
                    ksort($ms_v);
                    foreach ($ms_v as $user_name => $set_values) {
                        $cust_val .= "$user_name=\"{$set_values->mail_type}#{$set_values->email}\"\n";
                    }
                    $ini_tpl = str_replace("['--\$user--']", $cust_val,$ini_tpl);
                    unset($cust_val);
                } elseif ($row_key == __KEY_INI_USERGROUPSETTING) { //用户组信息段的特殊处理 
                    DebugInfo("[$moduleName][mdbGenerateIni][process user_group info ][key:$ms_k]".serialize($ms_v), 3);
                    $ms_v = (array)$ms_v;
                    ksort($ms_v);
                    foreach ((array)array_keys($ms_v) as $usergroup_name) {
                        $cust_val .= $usergroup_name.'="'.join('#',$ms_v[$usergroup_name])."\"\n";
                    }
                    $ini_tpl = str_replace("['--\$user_group--']", $cust_val,$ini_tpl);
                } elseif ($row_key == __KEY_INI_UNMONITORED) { // 未监控名单的特殊处理 
                    $ms_v = (array)$ms_v;
                    ksort($ms_v);
                    $ms_v = join(',', $ms_v);
                    $ini_tpl = str_replace("['--\$not_monitored--']", $ms_v, $ini_tpl);
                } else {
                    $ini_tpl = str_replace("['--\${$ms_k}--']", $ms_v,$ini_tpl);
                }
                /* }}} */
            }
        } catch (Exception $e) {
        }
    }
    /* }}} */
    /* {{{ 更新所有服务器明细监控设置段 */
    // TODO 这里比较耗时待改进，不过设置一次性问题也不大
    try {
        $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, __KEY_INI_SERVLIST, __MDB_COL_CONFIG_INI);
        $allSrvArr=json_decode($arr[0]->value);
        DebugInfo("[$moduleName][mdbGenerateIni][all servers][".serialize($allSrvArr)."]", 3);
        foreach ((array)$allSrvArr as $servTypeNum => $serverListString) {
            $srvArr=explode(',', $serverListString);
            foreach ($srvArr as $srv) {
                unset($srvMonDetailStr);
                if (!empty($srv) && !in_array($srv, (array)array_keys((array)$allServersMonDetail))) {
                    // 取出服务器的明细设置
                    $arr1 = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, sprintf(__KEY_HOST_DETAIL_SETTING, $srv), __MDB_COL_CONFIG_INI);
                    $allServersMonDetail[$srv]=$arr1[0]->value;
                    $arr2 = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, sprintf(__KEY_HOST_DETAIL_ITEM_SETTING, $srv), __MDB_COL_CONFIG_INI);
                    $allServersMonItemDetail[$srv]=$arr2[0]->value;
                }
            }
        }
    } catch (Exception $e) {
    }
    //DebugInfo("[$moduleName][mdbGenerateIni][all servers:".serialize($allServersMonDetail)."]", 3);
    foreach ((array)$allServersMonDetail as $hst => $monOption) {
        $content.="$hst=\"$monOption\"\n";
    }
    $ini_tpl = str_replace("['--\$host_monitor_detail--']", $content, $ini_tpl);
    unset($content);
    foreach ((array)$allServersMonItemDetail as $hst => $monOption) {
        $content.="$hst=\"$monOption\"\n";
    }
    $ini_tpl = str_replace("['--\$host_monitor_item_detail--']", $content, $ini_tpl);
    /* }}} */
    return $ini_tpl;
}

/**
 *@brief 将完整的INI配置文本存入MDB
 *@return 如果设置成功返回true，失败为false
 */
function mdbUpdateIni() {
    mdbUpdateServListSetting(); //每次更新ini时候都刷新一次服务器默认组列表，因为自配置会加入进来，需要及时触发 
    //TODO 先将自定义组列表的在此触发
    mdbUpdateServListCustSetting();
    $ini_str=mdbGenerateIni();
    global $moduleName;
    $row_key=__KEY_INIDATA;
    if (false!=mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, $ini_str)) {
        DebugInfo("[$moduleName][mdbUpdateIni ok]",3);
        return true;
    } else {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST;
        return false;
    }
}

/**
 *@brief 将完整的INI配置文本存入MDB(删除待删除的服务器)
 *@return 如果设置成功返回true，失败为false
 */
function mdbDelSrvUpdateIni() {
    global $moduleName;
    try {
        //获取待删除的服务器
        $arr=$GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, __KEY_TODELETE_SERVERS, __MDB_COL_CONFIG_INI);
        $toDeleteServers=(array)(json_decode($arr[0]->value));
        DebugInfo("[$moduleName][mdbDelSrvUpdateIni][will delete servers:".join(',',$toDeleteServers)."]",1);
        mdbDelAliveServers($toDeleteServers); //删除服务器组存活列表中的服务器
        mdbDelSrvUpdateServListSetting($toDeleteServers); //删除待删除服务器，更新默认组服务器列表
        mdbDelSrvUpdateServListCustSetting($toDeleteServers); //自定义组列表服务器调整，去掉要删除的
        mdbDelSrvFromUnmonitored($toDeleteServers); //未监控服务器调整，去掉要删除的
        mdbDelSrvUpdateHostList($toDeleteServers); //更新monitor_host表，对于删除的加上info:deleted=1标记
        $ini_str=mdbGenerateIni();
        $row_key=__KEY_INIDATA; //写入INI 
        if (false!=mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, $ini_str)) {
            DebugInfo("[$moduleName][mdbDelSrvUpdateIni][mdbUpdateIni ok]",1);
        } else {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST;
            return false;
        }
    } catch (Exception $e) {
        DebugInfo("[$moduleName][mdbDelSrvUpdateIni][got err:".$e->getMessage()."]",1);
        return false;
    }
    //获取自动配置表中相关项目
    $scanner = $GLOBALS['mdb_client']->scannerOpen( __MDB_TAB_SERVERNAME, '', array('servername') );
    try {
    } catch ( Exception $e ) {
        DebugInfo("[$moduleName][mdbDelSrvUpdateIni][got err:".$e->getMessage()."]",1);
        $GLOBALS['mdb_client']->scannerClose( $scanner );
        return false;
    }
    $matchedRowKeys[]="all"; //自动配置有关的行 
    for($i=1;$i<=__MAX_MONITOR_TYPES;$i++) {
        $matchedRowKeys[]="servgroup{$i}";
    }
    DebugInfo("[$moduleName][mdbDelSrvUpdateIni][matchedRowKeys:".json_encode($matchedRowKeys)."]",1);
    while (true) {
        $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
        if (array_filter($get_arr) == null) break;
        foreach ( $get_arr as $TRowResult ) {
            if (in_array($TRowResult->row,$matchedRowKeys)) {
                //得到该行下所有自动配置的服务器
                $tempRows[$TRowResult->row]=(array)explode('|',
                    $TRowResult->columns[__MDB_COL_SERVERNAME_ALL]->value);
            }
        }
    }
    $GLOBALS['mdb_client']->scannerClose( $scanner );
    DebugInfo("[$moduleName][mdbDelSrvUpdateIni][tempRows:".json_encode($tempRows)."]",1);
    //删除自动配置表中的这些服务器
    foreach ($tempRows as $tempRow=>$srvs) {
        //去掉删除的服务器并重建服务器组
        $remainSrvs=(array)array_diff($srvs,$toDeleteServers);
        mdb_set(__MDB_TAB_SERVERNAME, __MDB_COL_SERVERNAME_ALL, $tempRow, join('|',$remainSrvs));
    }
    //删除monitor_host表中的对应服务器(界面相关)
    $scanner = $GLOBALS['mdb_client']->scannerOpen( __MDB_TAB_HOST, '', array('info') );
    try {
    } catch ( Exception $e ) {
        DebugInfo("[$moduleName][mdbDelSrvUpdateIni][got err:".$e->getMessage()."]",1);
        $GLOBALS['mdb_client']->scannerClose( $scanner );
        return false;
    }
    while (true) {
        $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
        if (array_filter($get_arr) == null) break;
        foreach ( $get_arr as $TRowResult ) {
            if ($TRowResult->columns['info:deleted']) {
                try {
                    //干掉界面表和即时表的全部行
                    $GLOBALS['mdb_client']->deleteAllRow(__MDB_TAB_HOST, $TRowResult->row);
                    $GLOBALS['mdb_client']->deleteAllRow(__MDB_TAB_SERVER, $TRowResult->row);
                } catch ( Exception $e ) {
                    DebugInfo("[$moduleName][mdbDelSrvUpdateIni][got err:".$e->getMessage()."]",1);
                    $GLOBALS['mdb_client']->scannerClose( $scanner );
                    return false;
                }
            }
        }
    }
    $GLOBALS['mdb_client']->scannerClose( $scanner );
    return true;
}

/**
 *@brief 更新Mdb配置表中用户组设置的部分
 *@param $a 用户组设置arr(和报警有关的) 
 *@return 设置成功返回true，失败返回false
 */
function mdbUpdateUserGroupSetting($a) {
    global $moduleName;
    $row_key=__KEY_INI_USERGROUPSETTING;
    $a=array(__JSONKEY_USER_GROUP=>$a);
    if (false!=mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($a))) {
        DebugInfo("[$moduleName][mdbUpdateUserGroupSetting][ok]",3);
        return true;
    }
    return false;
}

/**
 *@brief 更新Mdb配置表中用户设置的部分
 *@param $a 用户设置arr(和报警有关的)
 *@return 设置成功返回true，失败返回false
 */
function mdbUpdateUserSetting($a) {
    global $moduleName;
    foreach ($a as $user => $tmpArr) {
        $user_setting[$user] = $tmpArr['mail_type']."#".$tmpArr['email'];
    }
    $row_key=__KEY_INI_USERSETTING;
    $a=array(__JSONKEY_USER=>$a); //JSON的key为user，这样设计为了生成ini时循环的方便 
    if (false!=mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($a))) {
        DebugInfo("[$moduleName][mdbUpdateUserSetting][ok]",3);
        return true;
    }
    return false;
}

/**
 *@brief 更新Mdb配置表中常规设置的部分
 *@param $a 引擎设置arr
 *@return 设置成功返回true，失败返回false
 */
function mdbUpdateGenerialSetting($a) {
    global $moduleName;
    if (empty($a)) { //内容为空返回失败 
        DebugInfo("[$moduleName][mdbUpdateGenerialSetting][content empty!]",3);
        return false;
    }
    $row_key=__KEY_INI_GENERALSETTING;
    if (false!=mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($a))) {
        DebugInfo("[$moduleName][mdbUpdateGenerialSetting][ok]",3);
        return true;
    }
}

/**
 *@brief 更新Mdb配置表中邮件设置的部分
 *@param $a 邮件设置arr
 *@return 设置成功返回true，失败返回false
 */
function mdbUpdateMailSetting($a) {
    global $moduleName;
    if (empty($a)) { //内容为空返回失败 
        DebugInfo("[$moduleName][mdbUpdateMailSetting][content empty!]",3);
        return false;
    }
    $row_key=__KEY_INI_MAILSETTING;
    if (false!=mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($a))) {
        DebugInfo("[$moduleName][mdbUpdateMailSetting][ok]",3);
        return true;
    }
}

/**
 *@brief 更新Mdb配置表中扫描设置的部分
 *@param $a 扫描设置arr
 *@return 设置成功返回true，失败返回false
 */
function mdbUpdateScanSetting($a) {
    global $moduleName;
    if (empty($a)) { //内容为空返回失败
        DebugInfo("[$moduleName][mdbUpdateScanSetting][content empty!]",3);
        return false;
    }
    $row_key=__KEY_INI_SCANSETTING;
    if (false!=mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($a))) {
        DebugInfo("[$moduleName][mdbUpdateScanSetting][ok]",3);
        return true;
    }
}


/**
 *@brief 更新Mdb配置表中报警设置的部分
 *@param $a 报警设置arr
 *@return 设置成功返回true，失败返回false
 */
function mdbUpdateAlarmSetting($a) {
    global $moduleName;
    if (empty($a)) { //内容为空返回失败 
        DebugInfo("[$moduleName][mdbUpdateAlarmSetting][content empty!]",3);
        return false;
    }
    $row_key = __KEY_INI_ALARMSETTING;
    if (false != mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($a))) {
        DebugInfo("[$moduleName][mdbUpdateAlarmSetting][ok]", 3);
        return true;
    }
}

/**
 *@brief 更新Mdb配置表中事件（边界）设置的部分
 *@param $a 报警设置arr
 *@return 设置成功返回true，失败返回false
 */
function mdbUpdateEventSetting($a) {
    global $moduleName;
    if (empty($a)) { //内容为空返回失败 
        DebugInfo("[$moduleName][mdbUpdateEventSetting][content empty!]",3);
        return false;
    }
    $row_key = __KEY_INI_EVENTSETTING;
    if (false != mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($a))) {
        DebugInfo("[$moduleName][mdbUpdateEventSetting][ok]", 3);
        return true;
    }
}

/**
 *@brief 更新Mdb配置表中默认服务器组列表(servlist_setting)的设置的部分
 */
function mdbUpdateServListSetting() {
    global $moduleName;
    /* {{{ 取出各个默认组(自动配置)下的服务器名单
     */
    $srv_key=array('type_1', 'type_2', 'type_3', 'type_4', 'type_5','type_6','type_7','type_8','type_9','type_10','type_11');
    $srv_value=array();
    $col = __MDB_COL_SERVERNAME_ALL; 
    for ($i=1; $i<=__MAX_DEFAULT_GROUP_NUM; $i++) { //遍历取得各组下的服务器 
        $row_key = sprintf(__KEY_SERVGROUP, $i);
        try { 
            $res = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVERNAME,$row_key,array(__MDB_COL_SERVERNAME_ALL)); //取出设置项组的值 
            $res = $res[0]->columns;
            $res = $res[__MDB_COL_SERVERNAME_ALL]->value; //获取value
            $res=implode(',', array_filter(explode('|', $res))); //转换｜为英文逗号
            $srv_value[] = $res;
        } catch (Exception $e) {
            return false;
        }
    }
    /* }}} */
    //格式$srvs = array('type_1'=>'server01,server02', 'type_2'=>'db01', 'type_3'=>'serving01','type_4'=>'management01', 'type_5'=>'report01');
    $srvs = array_combine($srv_key, $srv_value);
    $row_key = __KEY_INI_SERVLIST; 
    if (false != mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($srvs))) {
        DebugInfo("[$moduleName][mdbUpdateServListSetting][ok]", 3);
        return true;
    }
}

/**
 *@brief 从服务器组存活列表中删除服务器 
 *@return 删除成功返回true,失败返回false
 */
function mdbDelAliveServers($toDeleteServers) {
    global $moduleName;
    try {
        $ini_arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, __KEY_INIDATA, __MDB_COL_CONFIG_INI);
        $get_string = $ini_arr[0]->value;
        $server_group_string = parse_ini_string($get_string, true);
        foreach ( array_keys($server_group_string['server_list']) as $servtype ) {
            $type = str_replace('servtype_', '', $servtype);
            if ( !empty($type) ) {
                $res = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, 'servtype'.$type, __MDB_COL_EVENT);
                $servers = (array)explode('|', $res[0]->value);
                if ( !empty($servers) ) {
                    $servers = (array)array_diff($servers, $toDeleteServers);
                    mdb_set(__MDB_TAB_SERVER, __MDB_COL_EVENT, 'servtype'.$type, join('|',$servers));
                }
            }
        }
    } catch (Exception $e) {
        return false;
    }
    return true;
}

/**
 *@brief 更新Mdb配置表中默认服务器组列表(servlist_setting)的设置的部分
 */
function mdbDelSrvUpdateServListSetting($toDeleteServers) {
    global $moduleName;
    /* {{{ 取出各个默认组(自动配置)下的服务器名单
     */
    $srv_key=array('type_1', 'type_2', 'type_3', 'type_4', 'type_5','type_6','type_7','type_8','type_9','type_10','type_11');
    $srv_value=array();
    $col = __MDB_COL_SERVERNAME_ALL; 
    for ($i=1; $i<=__MAX_DEFAULT_GROUP_NUM; $i++) { //遍历取得各组下的服务器 
        $row_key = sprintf(__KEY_SERVGROUP, $i);
        try { 
            $res = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVERNAME,$row_key,array(__MDB_COL_SERVERNAME_ALL)); //取出设置项组的值 
            $res = $res[0]->columns;
            $res = $res[__MDB_COL_SERVERNAME_ALL]->value; //获取value
            $arr = array_filter(explode('|', $res));
            foreach ($arr as $srv) {
                if ( !in_array($srv, $toDeleteServers) ) {
                    $srvExist[] = $srv;
                }
            }
            $srv_value[]=implode(',', $srvExist); //转换｜为英文逗号
            unset($srvExist);
        } catch (Exception $e) {
            return false;
        }
    }
    /* }}} */
    //格式$srvs = array('type_1'=>'server01,server02', 'type_2'=>'db01', 'type_3'=>'serving01','type_4'=>'management01', 'type_5'=>'report01');
    $srvs = array_combine($srv_key, $srv_value);
    $row_key = __KEY_INI_SERVLIST; 
    if (false != mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($srvs))) {
        DebugInfo("[$moduleName][mdbDelSrvUpdateServListSetting][ok]", 3);
        return true;
    }
}

/**
 *@brief 更新Mdb配置表中自定义服务器组列表(servlist_cust_setting)的设置的部分
 *@param $a 修改服务器时指定的一个服务器属于哪些组的数组（'server'=>array('group1','group2')）,仅仅在修改服务器时候传递
 *@return 更新成功返回true,失败返回false //XXX 本函数基于未创建monitor_group的而直接通过维护INI上下文编写，需要重写基于该表的逻辑加强可读性 
 */
function mdbUpdateServListCustSetting($a=NULL) {
    $IsChangeHostGroup = is_array($a) && !empty($a) ?true :false;
    global $moduleName;
    /* {{{ 取出INI中各个自定义组的服务器名单到res_orig数组
     */
    try {
        $res = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, __KEY_INI_SERVLIST_CUST, array(__MDB_COL_CONFIG_INI)); //取出设置项--现有自定义组的值 
        $res = $res[0]->columns;
        $res = $res[__MDB_COL_CONFIG_INI]->value; // 获取value
        $res_orig = (array)json_decode($res); 
        $res_orig = (array)$res_orig[__TEMPLATE_VAR_CUSTGROUPS]; // 得到全部原有组包括组内服务器(生成配置文件之前的)
        DebugInfo("[$moduleName][mdbUpdateServListCustSetting][find!][customize group servers:".serialize($res_orig)."]", 3);
    } catch (Exception $e) {
        DebugInfo("[$moduleName][mdbUpdateServListCustSetting][error]", 3);
        return false;
    }
    /* }}} */
    /* {{{ 如果是修改服务器，则修改该数组达到维护自定义组的目的
     */
    if ($IsChangeHostGroup) {
        foreach ($a as $key=>$val) {
            $input_host = $key;
            $input_belongGroup = $val;
        }
        DebugInfo("[$moduleName][mdbUpdateServListCustSetting][input_host:$input_host][input_belongGroup:".join(",", $input_belongGroup)."]", 3);

        $tmp_res_orig = $res_orig;
        /* 服务器中存在，界面上删除了，要去掉 */ 
        foreach ($tmp_res_orig as $orig_grp => $tmpArr) {
            if (!in_array($orig_grp, $input_belongGroup) || empty($input_belongGroup)) {
                $idx = array_search($input_host, $res_orig[$orig_grp]);
                if ($idx===NULL || $idx===false) {
                } else {
                    DebugInfo("[$moduleName][mdbUpdateServListCustSetting][remove host from group][host:$input_host][orig_grp:$orig_grp][idx:$idx][unset val:".$res_orig[$orig_grp][$idx]."]", 3);
                    unset($res_orig[$orig_grp][$idx]);
                    sort($res_orig[$orig_grp]); // 删除要重排否则json_encode出问题 
                }
            }
        }
        
        DebugInfo("[$moduleName][mdbUpdateServListCustSetting][res_orig:".json_encode($res_orig)."]", 3);

        $tmp_res_orig = $res_orig;
        /* 遍历服务器组
         * 服务器组中不存在，界面上添加了，要新加
         */
        foreach ($tmp_res_orig as $orig_group => $orig_host_arr) {
            if (in_array($orig_group, $input_belongGroup)) {
                if (!in_array($input_host, $orig_host_arr)) {
                    $res_orig[$orig_group][] = $input_host;
                    DebugInfo("[$moduleName][mdbUpdateServListCustSetting][add host:$input_host to group:$orig_group][".json_encode($res_orig)."]", 3);
                } 
            }
            else { // 不属于组的要去掉了，可能摘除了 
                $idx = array_search($input_host, $res_orig[$orig_group]);
                if ($idx===NULL || $idx===false) {
                } else {
                    DebugInfo("[$moduleName][mdbUpdateServListCustSetting][cause not in current group remove host:$input_host from group:$orig_group][".json_encode($res_orig)."]", 3);
                    unset($res_orig[$orig_group][$idx]);
                    sort($res_orig[$orig_group]); // 删除要重排否则json_encode出问题 
                }
            }
        } 
    }
    DebugInfo("[$moduleName][mdbUpdateServListCustSetting][after deal res_orig:".json_encode($res_orig)."]", 3);
    /* }}} */
    try {
        $res = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, __KEY_INI_GROUP_CUST, array(__MDB_COL_CONFIG_INI)); // 取出设置项--组名和描述 
        $res = $res[0]->columns;
        $res = $res[__MDB_COL_CONFIG_INI]->value; // 获取value
        $res_groupname_info = (array)json_decode($res); // 得到组信息(生成配置文件之前的)
        $res_groupname_info = (array)$res_groupname_info[__JSONKEY_SERVER_GROUP]; // 得到值
        DebugInfo("[$moduleName][mdbUpdateServListCustSetting][group_info:".serialize($res_groupname_info)."]", 3);
        foreach (array_keys($res_orig) as $groupname) { // 遍历各个自定义组名,只要组名,描述这里用不着 
            $real_groupname = str_replace(__PREFIX_INI_SERVGROUP, '', $groupname); // 去掉配置文件的type_前缀 
            if (!in_array($real_groupname, array_keys($res_groupname_info))) { // 如果在原先的自定义组里找不到当前维护的自定组名描述的key(即组名) 
                unset($res_orig[$groupname]); // 则说明该组已经被通过管理界面被删除(此时此刻该自定义组内全部服务器的所在自定义组属性没有了) 
            }
        }
        // 接下来只要维护一个res_orig(含原有自定义组和组内服务器)和res_groupname_info(目前全部自
        // 定义组,包括新建)组成的新数组,这个last数组就是更新之后的自定义服务器组(包含组内服务器)了
        ksort($res_groupname_info); // 按照组名排序 
        $current_cust_group = array_keys($res_groupname_info); // 只要组名 
        $last = array();
        foreach ($current_cust_group as $groupname) {
            if (in_array($groupname, array_keys($res_orig))) {
                $last[$groupname] = $res_orig[__PREFIX_INI_SERVGROUP.$groupname]=array_filter($res_orig[$groupname]);  
            } else {
                $last[$groupname] = "";
            }
        }
        DebugInfo("[$moduleName][mdbUpdateServListCustSetting][current customize group are:".serialize($last)."]", 3);
    } catch (Exception $e) {
        DebugInfo("[$moduleName][mdbUpdateServListCustSetting][error!]", 3);
        return false;
    }
    /* {{{ 最后只要更新设置项即可
     */
    $servlist_cust_setting = json_encode(array('type_cust' => $last)); // 序列化后存Mdb
    if (false != mdb_set(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, __KEY_INI_SERVLIST_CUST, $servlist_cust_setting)) {
        DebugInfo("[$moduleName][mdbUpdateServListCustSetting][ok!]", 3);
        return true;
    } else {
        return false;
    }
    /* }}} */
    return true;
}

/**
 *@brief 更新Mdb配置表中自定义服务器组列表(servlist_cust_setting)的设置的部分
 *@return 更新成功返回true,失败返回false
 */
function mdbDelSrvUpdateServListCustSetting($toDeleteServers) {
    global $moduleName;
    //取出INI中各个自定义组的服务器名单到res_orig数组
    try {
        $res = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, __KEY_INI_SERVLIST_CUST, 
            array(__MDB_COL_CONFIG_INI)); //取出设置项--现有自定义组的值
        $res = $res[0]->columns;
        $res = $res[__MDB_COL_CONFIG_INI]->value; //获取value
        $res_orig = (array)json_decode($res);
        $res_orig = (array)$res_orig[__TEMPLATE_VAR_CUSTGROUPS]; //得到全部原有组包括组内服务器
        DebugInfo("[$moduleName][mdbDelSrvUpdateServListCustSetting][find!][customize group servers:"
            .json_encode($res_orig)."]", 3);
    } catch (Exception $e) {
        DebugInfo("[$moduleName][mdbDelSrvUpdateServListCustSetting][error]", 3);
        return false;
    }

    $servListCust['type_cust']=NULL;
    //排除待删除的服务器，重新组织自定义组设置配置
    foreach ( $res_orig as $groupName=>$memberServers ) {
        $servListCust['type_cust'][$groupName]=NULL;
        foreach ( $memberServers as $member ) {
            if ( !in_array($member,$toDeleteServers) ) {
                $servListCust['type_cust'][$groupName][]=$member;
            }
        }
    }

    //最后只要更新设置项即可
    $servlist_cust_setting = json_encode($servListCust); //序列化后存Mdb
    if ( false != mdb_set(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, __KEY_INI_SERVLIST_CUST,
        $servlist_cust_setting) ) {
        DebugInfo("[$moduleName][mdbDelSrvUpdateServListCustSetting][ok!]", 3);
        return true;
    } else {
        return false;
    }
}

/**
 *@brief 从未监控服务器中排除要删除的服务器
 *@param $toDeleteServers arr 要删除的服务器
 */
function mdbDelSrvFromUnmonitored($toDeleteServers) {
    global $moduleName,$_CONFIG;
    $arr=(array)explode(',',$_CONFIG['not_monitored']['not_monitored']);
    foreach ($arr as $unmonitor_server) {
        if ( !in_array($unmonitor_server, $toDeleteServers) ) {
            $newUnmonitorServers[]=$unmonitor_server;
        }
    }
    DebugInfo("[$moduleName][mdbDelSrvFromUnmonitored][current unmon:".
        json_encode($newUnmonitorServers)."]", 3);
    // 将调整后的不监控的服务器名单入库
    if ( false!=mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,__KEY_INI_UNMONITORED,
        json_encode($newUnmonitorServers)) ) {
            DebugInfo("[$moduleName][mdbDelSrvFromUnmonitored][ok!]", 3);
        } else {
            DebugInfo("[$moduleName][mdbDelSrvFromUnmonitored][fail!]", 3);
        }
}

/**
 *@brief 从monitor_host表中标记已经删除的服务器
 *@param $toDeleteServers arr 删除的服务器
 */
function mdbDelSrvUpdateHostList($toDeleteServers) {
    global $moduleName;
    try {
        $scanner = $GLOBALS['mdb_client']->scannerOpen( __MDB_TAB_HOST, '', array('info') );
        while (true) {
            $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
            if (array_filter($get_arr) == null) break;
            foreach ( $get_arr as $TRowResult ) {
                if ( !empty($TRowResult->row) ) {
                    if ( in_array($TRowResult->row,$toDeleteServers) ) {
                        if ( false!=mdb_set(__MDB_TAB_HOST,__MDB_COL_DELETED,$TRowResult->row,1) ) {
                            DebugInfo("[$moduleName][set delete flag][ok.]", 3);
                        } else {
                            DebugInfo("[$moduleName][set delete flag][fail!]", 3);
                        }
                    }
                }
            }
        }
        $GLOBALS['mdb_client']->scannerClose($scanner); // 关闭scanner
    } catch (Exception $e) {
        DebugInfo("[$moduleName][set delete flag][err:".$e->getMessage()."]", 3);
    }
}

/**
 *@brief 创建服务器组(for 自定义)
 *@param arr name=>name,desc=>desc,membergroup,monitoritem组成的数组
 *@return 创建成功返回true,失败返回false
 */
function mdbCreateServGroup($arr) {
    global $moduleName;
    list($name, $desc, $mailtype, $membergroup, $monitoritem, $override_set) = array_values($arr);
    DebugInfo("[$moduleName][mdbCreateServGroup][get create param][name:$name][desc:$desc][mailtype:$mailtype][membergroup:$membergroup][monitoritem:$monitoritem]", 3);
    $row_key = __KEY_INI_GROUP_CUST;
    /* {{{ 取出全部自定义组信息
     */
    try {  //TODO 这里不要使用getRowWithColumns,可以直接使用get减少代码量 
        $res = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $row_key, array(__MDB_COL_CONFIG_INI)); //取出设置项组的值 
        $res = $res[0]->columns;
        $res = $res[__MDB_COL_CONFIG_INI]->value; //获取value
        $res = (array)json_decode($res);
        $res = (array)$res[__JSONKEY_SERVER_GROUP]; 
        DebugInfo("[$moduleName][mdbCreateServGroup][group_cust:".serialize($res)."]", 3);

        /* 不存在则新建 */
        if (!in_array($name, array_keys($res))) {
            $srv_value = $res; //该组原有的 
            $srv_value[$name]['desc'] = $desc;
            $srv_value[$name]['mailtype'] = $mailtype;
            $srv_value[$name]['membergroup'] = $membergroup;
            $srv_value[$name]['monitoritem'] = $monitoritem;
            $srv_value[$name]['override_set'] = $override_set; 
            $srv_value = array(__JSONKEY_SERVER_GROUP => $srv_value); //JSON的key为server_group，这样设计为了生成ini时循环的方便 
            if (false != mdb_set(__MDB_TAB_SERVER,__MDB_COL_CONFIG_INI,$row_key, json_encode($srv_value))) {
                DebugInfo("[$moduleName][mdbCreateServGroup][ok]", 3);
                return true;
            } else {
                return false;
            }
        }
        $GLOBALS['httpStatus'] = __HTTPSTATUS_METHOD_CONFILICT;
        return false; //已经有该组创建失败 
    } catch (Exception $e) {
        return false;
    }
    /* }}} */
}

/**
 *@brief 更新未监控名单的设置
 *@param $hst 主机,$mtd方式，1为加入未监控名单，2为从未监控名单中移除
 */
function updateUnmonSetting($hst, $mtd = __UNMONITORED_ADD) {
    try {
        $res = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, __KEY_INI_UNMONITORED, array(__MDB_COL_CONFIG_INI));
        $res = $res[0]->columns;
        $res = $res[__MDB_COL_CONFIG_INI]->value; // 获取value
        $res = json_decode($res);
        $res = $res->not_monitored;
    } catch (Exception $e) { // 获取失败 
        return false;
    }
    if ($mtd===__UNMONITORED_ADD) { // 该服为不监控，加入 
        !in_array($hst, $res) && $res[] = $hst;
    } elseif ($mtd===__UNMONITORED_DELETE) { //该服为监控 ，移除
        in_array($hst, $res) && $res = array_diff((array)$res, (array)$hst);
    }
    $res = array_filter($res);
    sort($res); // 重排以防序列化问题 
    $res = array('not_monitored'=>$res);
    $res = json_encode($res);
    mdb_set(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, __KEY_INI_UNMONITORED, $res);
}

/**
 *@brief 更新服务器监控明细项的设置
 $@param $hst   主机名
 *@param $monArr 监控明细项数组
 */
function updateHostMonDetailSetting($hst, $monArr) {
    global $moduleName,$AllSubMonItems;
    DebugInfo("[$moduleName][updateHostMonDetailSetting][host:$hst]",3);
    //DebugInfo("[$moduleName][updateHostMonDetailSetting][monArr:".serialize($monArr)."]",4);
    // TODO 这里出个函数直接对大类进行调整
    foreach ($monArr as $monBigClass => $monItemsStr) {
        $itemArr=explode('|', $monItemsStr);  // 对每个大类下的监控项读取监控开关
        foreach ($itemArr as $itemSettingStr) {
            list($whichItem, $itemBeMonitored)=explode(':', $itemSettingStr);
            if (!empty($whichItem)) {
                $eventNum=$AllSubMonItems[$whichItem];
                DebugInfo("[$moduleName][whichItem:$whichItem][eventNum:$eventNum][itemBeMonitored:$itemBeMonitored]",3);
                if ($itemBeMonitored && !in_array("$eventNum", (array)$BeMonEventArr)) { // 如果监控则存其事件号 
                    $BeMonEventArr[]="$eventNum";
                }
            }
        }
    }
    sort($BeMonEventArr);
    $SaveMonString=join('|',$BeMonEventArr); // 连接字符串存到一个服务器的设置中去 
    // 更新该服务器的监控标记
    DebugInfo("[$moduleName][SaveMonString:{$SaveMonString}]",3);
    if (mdb_set(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, sprintf(__KEY_HOST_DETAIL_SETTING,$hst), $SaveMonString)) {
        return true;
    }
    return false;
}

/**
 *@brief 获取全部自动伸缩的服务器(包括服务的和不服务的)
 */
function getAutoScalingSrvs() {
    $arr=$GLOBALS['mdb_client']->get(__MDB_TAB_SERVER,'awsscale','config:awsscale');
    $val=json_decode($arr[0]->value);
    $val=(array)$val->data;
    return array_keys($val);
}
?>
