<?php
/*
  +----------------------------------------------------------------------+
  | Name:event_settingFun.m
  +----------------------------------------------------------------------+
  | Comment:事件设置函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2014-06-09 16:33:43
  +----------------------------------------------------------------------+
 */

$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
$err = false;
header("Content-type: application/json; charset=utf-8");

//合法的json上传key
$valid_key = array(
    'keepAliveOvertimeSec',
    'disk_range',
    'disk_inode',
    'load_average',
    'memory_usage_percent',
    'running_process_num',
    'tcpip_connections',
    'network_flow',
    'mysql_db_connections',
    'mysql_db_threads',
    'mysql_seconds_behind_master',
    'serving_request',
    'serving_fillrate',
    'report_wait_process_log_num',
    'dfs_datanode_copyBlockOp_avg_time', //php自动把.转换成下划线 
    'dfs_datanode_heartBeats_avg_time',
    'bizlog_httplog_4xx',
    'bizlog_httplog_5xx'
); 
switch ($GLOBALS['operation']) {
case(__OPERATION_READ):
    if (!canAccess('read_eventSet')) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
        return;
    }
    if ($GLOBALS['selector'] == __SELECTOR_KEEPALIVE) {
        /* {{{ 读取检查心跳请求超时秒数设置
         */
        echo json_encode($_CONFIG['general']['down_over_time']);
        if (!$err) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; 
            echo $str;
        }
        /* }}} */
    } elseif ($GLOBALS['selector'] == __SELECTOR_SINGLE) {
        $_CONFIG['serving_fillrate']['caution_start']+=0;
        $_CONFIG['serving_fillrate']['warn_start']+=0;
        foreach ($_CONFIG as $item =>$cwInfo) {
            foreach (array_keys($cwInfo) as $cwKey) {
                if (in_array($item, $valid_key)) {
                    $_CONFIG[$item][$cwKey]+=0; // 对数据强制转换为数字 
                }
            }
        }

        /* {{{ 读取事件设置
         */
        $strArr=array(
            "disk_range" => array(
                $_CONFIG['disk_range']['caution_start'],
                $_CONFIG['disk_range']['warn_start'],
                "磁盘限额",
                "%"
            ),
            "disk_inode" => array(
                $_CONFIG['disk_inode']['caution_start'],
                $_CONFIG['disk_inode']['warn_start'],
                "磁盘INode限额",
                "%"
            ),
            "load_average" => array(
                $_CONFIG['load_average']['caution_start'],
                $_CONFIG['load_average']['warn_start'],
                "Load Average",
                ""
            ),
            "memory_usage_percent" => array(
                $_CONFIG['memory_usage_percent']['caution_start'],
                $_CONFIG['memory_usage_percent']['warn_start'],
                "内存占用率",
                "%"
            ),
            "running_process_num" => array(
                $_CONFIG['running_process_num']['caution_start'],
                $_CONFIG['running_process_num']['warn_start'],
                "运行进程数",
                "个"
            ),
            "tcpip_connections" => array(
                $_CONFIG['tcpip_connections']['caution_start'],
                $_CONFIG['tcpip_connections']['warn_start'],
                "TCPIP连接数",
                "个"
            ),
            "network_flow" => array(
                $_CONFIG['network_flow']['caution_start'],
                $_CONFIG['network_flow']['warn_start'],
                "网络接口流量",
                "Bytes"
            ),
            "mysql_db_connections" => array(
                $_CONFIG['mysql_db_connections']['caution_start'],
                $_CONFIG['mysql_db_connections']['warn_start'],
                "MySQL连接数",
                "个"
            ),
            "mysql_db_threads" => array(
                $_CONFIG['mysql_db_threads']['caution_start'],
                $_CONFIG['mysql_db_threads']['warn_start'],
                "MySQL线程数",
                "个"
            ),
            "mysql_seconds_behind_master" => array(
                $_CONFIG['mysql_seconds_behind_master']['caution_start'],
                $_CONFIG['mysql_seconds_behind_master']['warn_start'],
                "MySQL slave延迟时间",
                "秒"
            ),
            "serving_request" => array(
                $_CONFIG['serving_request']['caution_start'],
                $_CONFIG['serving_request']['warn_start'],
                "Serving Request",
                "个"
            ),
            "serving_fillrate" => array(
                $_CONFIG['serving_fillrate']['caution_start'],
                $_CONFIG['serving_fillrate']['warn_start'],
                "Serving 广告填充率",
                "%"
            ),
            "report_wait_process_log_num" => array(
                $_CONFIG['report_wait_process_log_num']['caution_start'],
                $_CONFIG['report_wait_process_log_num']['warn_start'],
                "Report 待处理日志数",
                "条"
            ),
            "dfs.datanode.copyBlockOp_avg_time" => array(
                $_CONFIG['dfs_datanode_copyBlockOp_avg_time']['caution_start'],
                (float)$_CONFIG['dfs_datanode_copyBlockOp_avg_time']['warn_start'],
                "Hadoop hdfs datanode块复制时间",
                "ms"
            ),
            "dfs.datanode.heartBeats_avg_time" => array(
                $_CONFIG['dfs_datanode_heartBeats_avg_time']['caution_start'],
                (float)$_CONFIG['dfs_datanode_heartBeats_avg_time']['warn_start'],
                "Hadoop hdfs datanode向namenode报告时间",
                "ms"
            ),
            "bizlog_httplog_4xx" => array(
                $_CONFIG['bizlog_httplog_4xx']['caution_start'],
                $_CONFIG['bizlog_httplog_4xx']['warn_start'],
                "Hive HTTP返回4XX代码的请求数",
                "个"
            ),
            "bizlog_httplog_5xx" => array(
                $_CONFIG['bizlog_httplog_5xx']['caution_start'],
                $_CONFIG['bizlog_httplog_5xx']['warn_start'],
                "Hive HTTP返回5XX代码的请求数",
                "个"
            )
        );
        if(!$err) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; 
            echo json_encode($strArr);
        }
        /* }}} */
    }
    break;
case(__OPERATION_UPDATE):
    /* {{{ 更新事件设置
     */
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE && !empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST') { // 要求上传数据非空和请求类型 
        if (!canAccess('update_eventSet')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        // 检查是否符合数据格式
        foreach ($valid_key as $event_key) {
            if (!in_array($event_key, array_keys($_POST))) { // 对少传判断为非法 
                $err = true;
            } else {
                switch ($event_key) {
                case('keepAliveOvertimeSec'): // 设置检查心跳请求超时秒数 
                    $event_setting['down_over_time'] = intval($_POST[$event_key]);
                    break;
                default: // 设置报警事件的临界值 
                    $arr = explode('|', $_POST[$event_key]);
                    count($arr)!=2 && $err = true; // 检查传递的数值格式 
                    if ($event_key!='serving_fillrate') {
                        $arr[0]>=$arr[1] && $err =true; // 黄色警报上限不能大于等于红色警报下限
                    }
                    if (!$err) {
                        $event_setting[$event_key."_caution_start"] = $arr[0];
                        $event_setting[$event_key."_warn_start"] = $arr[1];
                    }
                    break;
                }
            } 
        } 
        // 回调检查所有设置是否为正数
        $err = $err==false ?(in_array(false, array_map("is_numeric", $event_setting)) ?true :false) :true;
        if (!$err) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_RESET_CONTENT;
            mdbUpdateEventSetting($event_setting); // 更新MDB中相应的配置段落  
            mdbUpdateIni(); // 更新MDB中的INI配置文本
        }
    }
    /* }}} */
    break;
}
?>
