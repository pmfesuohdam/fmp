<?php
/*
  +----------------------------------------------------------------------+
  | Name:modules/initApi.m
  +----------------------------------------------------------------------+
  | Comment:初始化api,确定配置
  +----------------------------------------------------------------------+
  | Author: Yinjia
  +----------------------------------------------------------------------+
  | Created:2011-02-23 10:44:39
  +----------------------------------------------------------------------+
  | Last-Modified: 2014-06-12 10:17:02
  +----------------------------------------------------------------------+
 */
$moduleName=basename(__FILE__);

//默认配置
$_uriHasVersion=true;  //uri中是否包含version信息
$_uriHasOperation=true;//uri中是否包含

//debug级别默认为1,可在各自模块单独修改
$_debugLevel=3;
$GLOBALS['debugLevel']=empty($_REQUEST['debug'])?3:(int)$_REQUEST['debug'];  //支持参数指定debug级别
$GLOBALS['debugOutput']=(isset($_REQUEST['debug_output']) && $_REQUEST['debug_output']==='1')?true:false;

//输出内容,是个数组
$GLOBALS['outputContent']=array();

/* {{{ 权限项的init
 */
$privilege_item_arr = array(
    //'read_summary'         => array('info'=>'查看一览','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE, __MONITOR_PRIVILEGE_R)),
    'read_enginestatus'    => array('info'=>'查看监控引擎','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE, __MONITOR_PRIVILEGE_R)),
    'read_cloudview'       => array('info'=>'查看监控状态云','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_healthstatus'    => array('info'=>'查看全局health','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_serverList'      => array('info'=>'查看服务器列表','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_serverSingle'    => array('info'=>'查看单台服务器','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_serverSingle'  => array('info'=>'修改单台服务器','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'delete_serverSingle'  => array('info'=>'删除单台服务器','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_serverGroupList' => array('info'=>'查看服务器组列表','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'create_serverGroup'   => array('info'=>'创建服务器组','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_serverGroup'   => array('info'=>'修改服务器组','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'delete_serverGroup'   => array('info'=>'删除服务器组','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_monitorEvent'    => array('info'=>'查看监控事件','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_eventLog'        => array('info'=>'查看事件日志','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'create_site'          => array('info'=>'创建测速站点','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_siteList'        => array('info'=>'查看站点列表','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_site'          => array('info'=>'更新测速站点','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'delete_site'          => array('info'=>'删除测速站点','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_sitespeedList'   => array('info'=>'查看站点访问速度列表','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_sitespeedSingle' => array('info'=>'查看单个站点访问速度','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_generalSet'      => array('info'=>'查看常规设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_generalSet'    => array('info'=>'修改常规设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_emailSet'        => array('info'=>'查看邮件设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_emailSet'      => array('info'=>'修改邮件设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_alarmSet'        => array('info'=>'查看报警设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_alarmSet'      => array('info'=>'修改报警设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_scanSet'         => array('info'=>'查看扫描设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_scanSet'       => array('info'=>'修改扫描设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_eventSet'        => array('info'=>'查看事件设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_eventSet'      => array('info'=>'修改事件设置','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_userList'        => array('info'=>'查看用户列表','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'create_user'          => array('info'=>'创建用户','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_user'          => array('info'=>'更新用户','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'delete_user'          => array('info'=>'删除用户','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_usergroupList'   => array('info'=>'查看用户组列表','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'create_usergroup'     => array('info'=>'创建用户组','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_usergroup'     => array('info'=>'更新用户组','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'delete_usergroup'     => array('info'=>'删除用户组','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_monitorWizard'   => array('info'=>'查看监控向导','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_ipManagement'    => array('info'=>'查看IP管理','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'read_madnManagement'  => array('info'=>'查看MADN管理','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R)),
    'update_madnManagement'=> array('info'=>'更新MADN管理','avail_pri'=>array(__MONITOR_PRIVILEGE_NONE,__MONITOR_PRIVILEGE_R))
);
/* }}} */
/* {{{ 监控项的init
 */
$monitor_item_arr = array( //全部监控项数组 
    'generic' => array(
        'Disk Capacity'=> '1',          // 000 
        'Inode Capacity'=> '1',         // 001 
        'Load Average'=> '1',           // 002 
        'Memory Usuage'=>'1',           // 003 
        'Process Number'=>'1',          // 004 
        'Cpu Usuage' => '1',            // 005 
        'TCP/IP Service' => '1',        // 006 
        'TCP/IP Connections' => '1',    // 007 
        'Network Flow'=>'1',            // 008
    ),
    'mysql' => array(
        'Mysql Connections' => '1',     // 017 
        'Mysql Single Table Size' => '1', // 018
        'Mysql Created Threads' => '1',  // 019 
        'Mysql Master/Slave' => '1',     // 020
        'Mysql Crucial Table' => '1',     // 021
        'Mysql Slave Latency' => '1'      // 029 
    ),
    'serving' => array(
        'Request Number'=>'1',          // 009 
        'Advt Publish'=> '1',           // 011 
        'Log Creation'=> '1',           // 023
        'Advt Fillrate'=> '1'           // 024 
    ),
    'daemon' => array(
        'Web Server' => '1',            // 012 
        'Backend Daemon' => '1',        // 013 
        'Login' => '1',                 // 014 
        'Advt Deliver' => '1',          // 015
        'Error Log' => '1'              // 016
    ),
    'report' => array(
        'Wait Process Log Num' => '1'   // 022
    ),
    'mdn' => array(
        'Madn Availability' => '1'      // 025
    ),
    'hadoop' => array(
        'dfs.datanode.copyBlockOp_avg_time' => '1', // 026
        'dfs.datanode.heartBeats_avg_time'  => '1'  // 027
    ),
    'bizlog' => array(
        'Http 4xx Requests' => '1',    // 030
        'Http 5xx Requests' => '1'     // 031
    ),
    'jail' => array(
    ),
    'mdb' => array(
    ),
    'gslb' => array(
    ),
    'security' => array(
    ),
    'monitor' => array(
    )
);

$event_map_table = array( //事件代码文字对照表(N为正常，C为注意，W为严重) 
    '000n' => 'Disk %s usage is %d%%',
    '000c' => 'Disk %s usage is %d%%',
    '000w' => 'Disk %s usage is %d%%',
    '001n' => 'Inode Disk %s usage is %d%%',
    '001c' => 'Inode Disk %s usage is %d%%',
    '001w' => 'Inode Disk %s usage is %d%%',
    '002n' => 'load (%s)',
    '002c' => 'load (%s) is larger than 10,server performance may be reduced ',
    '002w' => 'load (%s) is larger than 10,server performance may be reduced ',
    '003n' => 'Memory usage is %01.2f%%',
    '003c' => 'Memory usage is %01.2f%%',
    '003w' => 'Memory usage is %01.2f%%',
    '004n' => 'The total number of processes is %d',
    '004c' => 'The total number of processes is %d',
    '004w' => 'The total number of processes is %d',
    '005n' => 'CPU usuage is %d',
    '005c' => 'CPU usuage is %d',
    '005w' => 'CPU usuage is %d',
    '006n' => 'TCP/IP service %s port %d status ok',
    '006c' => 'TCP/IP service %s port %d status CORRUPTED',
    '006w' => 'TCP/IP service %s port %d status CORRUPTED',
    '007n' => 'Total number of TCP/IP connections is %s',
    '007c' => 'Total number of TCP/IP connections is %s , New connections may have trouble being created',
    '007w' => 'Total number of TCP/IP connections is %s , New connections may have trouble being created',
    '008n' => '%s network interface flow is %sbyte/s ,in is %sbyte/s,out is %sbyte/s',
    '008c' => '%s network interface flow is %sbyte/s ,in is %sbyte/s,out is %sbyte/s',
    '008w' => '%s network interface flow is %sbyte/s ,in is %sbyte/s,out is %sbyte/s',
    '009n' => 'request num ok,current request number is %s reqs/s',
    '009c' => 'request num is more than 500 reqs/s,current request number is %s reqs/s',
    '009w' => 'request num is more than 500 reqs/s,current request number is %s reqs/s',
    '010n' => '', //投放节点数(unused)
    '010c' => '', //投放节点数(unused)
    '010w' => '', //投放节点数(unused)
    '011n' => 'ad publish status is ok',
    '011c' => 'ad publish status status is CORRUPTED',
    '011w' => 'ad publish status  status is CORRUPTED',
    '012n' => 'webserver status is ok',
    '012c' => 'webserver status is CORRUPTED',
    '012w' => 'webserver status is CORRUPTED',
    '013n' => 'backend daemon status is ok',
    '013c' => 'backend daemon status is CORRUPTED',
    '013w' => 'backend daemon status is CORRUPTED',
    '014n' => 'daemon login status is ok',
    '014c' => 'daemon login status is CORRUPTED',
    '014w' => 'daemon login status is CORRUPTED',
    '015n' => 'daemon deliver status', //daemon广告投放(unused)
    '015c' => 'daemon deliver status', //daemon广告投放(unused)
    '015w' => 'daemon deliver status', //daemon广告投放(unused)
    '016n' => 'daemon error log status is ok',
    '016c' => 'daemon error log status is CORRUPTED',
    '016w' => 'daemon error log status is CORRUPTED',
    '017n' => 'db connections is  %s now',
    '017c' => 'db connections is more than 500,%s connections now',
    '017w' => 'db connections is more than 1000,%s connections now',
    '018n' => 'mysql single table %s maxsize %s', //mysql 单表最大尺寸(unused)
    '018c' => 'mysql single table %s maxsize %s', //mysql 单表最大尺寸(unused)
    '018w' => 'mysql single table %s maxsize %s', //mysql 单表最大尺寸(unused)
    '019n' => 'mysql threads: %s threads were created',
    '019c' => 'mysql threads is more than 500,%s threads were created',
    '019w' => 'mysql threads is more than 1000,%s threads were created',
    '020n' => 'mysql Database Server Master/Slave status is ok', //Mysql Database Server Master/Slave状态 
    '020c' => 'mysql Database Server Master/Slave status is CORRUPTED', //Mysql Database Server Master/Slave状态 
    '020w' => 'mysql Database Server Master/Slave status is CORRUPTED', //Mysql Database Server Master/Slave状态 
    '021n' => 'mysql crucial table %s status is ok',
    '021c' => 'mysql crucial table %s status is CORRUPTED',
    '021w' => 'mysql crucial table %s status is CORRUPTED',
    '022n' => 'need to processed logs number is:%s',
    '022c' => 'Too many logs need to processed,there are %s logs,platform stability may be reduced and reporting functions may not function correctly',
    '022w' => 'Too many logs need to processed,there are %s logs,platform stability may be reduced and reporting functions may not function correctly',
    '023n' => 'log creation is ok',
    '023c' => 'Loginfo creation failed! May be not any request incoming.',
    '023w' => 'Loginfo creation failed! May be not any request incoming.',
    '024n' => 'Fillrate is ok',
    '024c' => 'Fillrate is low, current %s',
    '024w' => 'Fillrate is low, current %s',
    '025n' => 'Madn availability is ok',
    '025c' => 'Madn availability is low',
    '025w' => 'Madn availability is very low',
    '026n' => 'datanode copyBlockOp average ok,current:%s',
    '026c' => 'datanode copyBlockOp average time too long,current:%s',
    '026w' => 'datanode copyBlockOp average time too long,current:%s',
    '027n' => 'datanode heartBeats average time ok,current:%s',
    '027c' => 'datanode heartBeats average time too long,current:%s',
    '027w' => 'datanode heartBeats average time too long,current:%s',
    '028n' => '',
    '028c' => '',
    '028w' => '',
    '029n' => 'mysql Database Server slave latency ok,current:%s',
    '029c' => 'mysql Database Server slave latency too long,current:%s',
    '029w' => 'mysql Database Server slave latency too long,current:%s',
    '030n' => 'http 4xx requests ok,current:%s',
    '030c' => 'http 4xx requests too many,current:%s',
    '030w' => 'http 4xx requests too many,current:%s',
    '031n' => 'http 5xx requests ok,current:%s',
    '031c' => 'http 5xx requests too many,current:%s',
    '031w' => 'http 5xx requests too many,current:%s'
);
/* }}} */

$event_item_map_table = array(
    '000' => array('磁盘可用空间',              'Disk Capacity'),
    '001' => array('iNode可用空间',             'iNode Capacity'),
    '002' => array('Load Average',              'Load Average'),
    '003' => array('内存使用率',                'Memory Usuage'),
    '004' => array('进程数',                    'Process Numbers'),
    '005' => array('CPU占用率',                 'CPU Usuage'),
    '006' => array('TCP/IP端口',                'TCP/IP Ports'),
    '007' => array('TCP/IP连接数',              'TCP/IP Connections'),
    '008' => array('网络接口流量',              'Network Interface Flows'),
    '009' => array('(Serving)单台负荷',         '(Serving) Single Load'),
    '010' => array('(Serving)投放节点数',       '(Serving) Delivering Node Numbers'),
    '011' => array('(Serving)广告发布',         '(Serving) Advt Publish Status'),
    '012' => array('(Daemon) web服务器',        '(Daemon) Web Server Status'),
    '013' => array('(Daemon) 后台daemon',       '(Daemon) Daemon Status'),
    '014' => array('(Daemon) daemon login',     '(Daemon) Daemon Login Status'),
    '015' => array('(Daemon) 广告投放',         '(Daemon) Advt Deliver'),
    '016' => array('(Daemon) error log',        '(Daemon) Error Log Status'),
    '017' => array('(Mysql) 数据库连接数量',    '(Mysql) Database Connections'),
    '018' => array('(Mysql) 单表最大尺寸',      '(Mysql) Single Table Max Size'),
    '019' => array('(Mysql) threads 线程数量',  '(Mysql) Threads'),
    '020' => array('(Mysql) Master/Slave 状态', '(Mysql) Master/Slave Status'),
    '021' => array('(Mysql) 关键表控制',        '(Mysql) Critical Table'),
    '022' => array('(Report) 待处理log数',      '(Report) Wait Process Logs'),
    '023' => array('(Serving) 日志生成',        '(Serving) Log Creation Status'),
    '024' => array('(Serving) 广告填充率',      '(Serving) Fillrate Status'),
    '025' => array('(Madn) 可用性',             '(Madn) Availability'),
    '026' => array('(Hadoop) datanode块复制时间', '(Hadoop) dfs.datanode.copyBlockOp_avg_time'),
    '027' => array('(Hadoop) datanode向namenode汇报时间', '(Hadoop) dfs.datanode.heartBeats_avg_time'),
    '028' => array(), // 待定 
    '029' => array('(Mysql) slave延迟时间',     '(Mysql) Slave latency'),
    '030' => array('(Business Log) http4xx请求数', '(Business Log) Http4xx Request Numbers'),
    '031' => array('(Business Log) http5xx请求数', '(Business Log) Http5xx Request Numbers'),
);
// 全部监控大类别
$AllMonItems=array(
    'generic',
    'mysql',
    'serving',
    'daemon',
    'report',
    'mdn',
    'hadoop',
    'bizlog',
    'jail',
    'mdb',
    'gslb',
    'security',
    'monitor'
);

// 全部明细的监控项文字和事件代码对照
// TODO 几个数组合并一下
$AllSubMonItems=array(
    'Disk Capacity'=>'000',
    'Inode Capacity'=>'001',
    'Load Average'=>'002',
    'Memory Usuage'=>'003',
    'Process Number'=>'004',
    'Cpu Usuage'=>'005',
    'TCP/IP Service'=>'006',
    'TCP/IP Connections'=>'007',
    'Network Flow'=>'008',
    'Request Number'=>'009',
    'Advt Publish'=>'011',
    'Web Server'=>'012',
    'Backend Daemon'=>'013',
    'Login'=>'014',
    'Advt Deliver'=>'015',
    'Error Log'=>'016',
    'Mysql Connections'=>'017',
    'Mysql Single Table Size'=>'018',
    'Mysql Created Threads'=>'019',
    'Mysql Master/Slave'=>'020',
    'Mysql Crucial Table'=>'021',
    'Mysql Slave Latency'=>'029',
    'Wait Process Log Num'=>'022',
    'Log Creation'=>'023',
    'Advt Fillrate'=>'024',
    'Madn Availability'=>'025',
    'dfs.datanode.copyBlockOp_avg_time'=>'026',
    'dfs.datanode.heartBeats_avg_time'=>'027',
    'Http 4xx Requests'=>'030',
    'Http 5xx Requests'=>'031'
);
?>
