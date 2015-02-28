<?php
/*
  +----------------------------------------------------------------------+
  | Name: common.m
  +----------------------------------------------------------------------+
  | Comment: 常用函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2014-06-12 14:26:16
  +----------------------------------------------------------------------+
 */


/**
 *@brief 自定义排序，将默认组或者默认用户排到最前
 */
function default_admin_cmp($keya, $keyb) {
    if($keya == 'monitoradmin') {
        return -1;
    }
    if($keyb == 'monitoradmin') {
        return 1;
    }
    $a = substr($keya,0,1);
    $b = substr($keyb,0,1);
    if ($a == $b) {
        return 0;
    }
    return ($a < $b) ? -1 : 1;
}

/**
 *@brief 获取以天小时分秒为单位的累计秒数
 *@param $secs 秒数 
 *@return 分解为天小时分秒组成的字符串 
 */
function getDhms($secs) {
    $d = floor($secs/86400); 
    $tmp = $secs % 86400; 
    $h = floor($tmp / 3600); 
    $tmp %= 3600; 
    $m = floor($tmp / 60); 
    $s = $tmp % 60; 
    return $d. "d ".str_pad($h,2,' ', STR_PAD_LEFT). "h ".str_pad($m,2,'0',STR_PAD_LEFT). "m ".str_pad($s,2,'0',STR_PAD_LEFT). "s"; 
} 

/**
 *@brief 更根据容量大小智能转换到Gb,Mb,Kb,Bytes的函数
 *@param 参数为kb单位的整数
 */
function sizecount($filesize) {
    $filesize*=1024;
    if($filesize >= 1073741824) {
        $filesize = round($filesize / 1073741824 * 100) / 100 . 'Gb';
    } elseif($filesize >= 1048576) {
        $filesize = round($filesize / 1048576 * 100) / 100 . 'Mb';
    } elseif($filesize >= 1024) {
        $filesize = round($filesize / 1024 * 100) / 100 . 'Kb';
    } else {
        $filesize = $filesize . 'Bytes';
    }
    return $filesize;
}

/**
 *@brief 获取事件for描述
 *@param $event_arr 事件数组 数组格式 键: info:监控类型_监控项$ts 值: tCell object->value
 */
function getEventUIDesc($host_name,$event_arr,$needTs=true) {
    $ts = NULL;
    $needTs && $ts = date('ymd', time()); 
    foreach($event_arr as $eventItemWithTs => $tCellObj) {
        switch($eventItemWithTs) { //为UI提供数据 
        case("info:generic_summary_load{$ts}"): //系统load 
            $host['generic']['summary_load']=$tCellObj->value;
            break;
        case("info:generic_summary_uptime_day{$ts}"): //运行天数 
            $host['generic']['summary_uptime_day']=$tCellObj->value;
            break;
        case("info:generic_summary_uptime_his{$ts}"): //运行小时:分:秒数 
            $host['generic']['summary_uptime_his']=$tCellObj->value;
            break;
        case("info:generic_summary_tcp_connections{$ts}"): //TCP连接数 
            $host['generic']['summary_tcp_connections']=$tCellObj->value;
            break;
        case("info:generic_cpu_use{$ts}"): //cpu use 
            $host['generic']['cpu_use']=$tCellObj->value;
            break;
        case("info:generic_cpu_nice{$ts}"): //cpu nice 
            $host['generic']['cpu_nice']=$tCellObj->value;
            break;
        case("info:generic_cpu_system{$ts}"): //cpu system 
            $host['generic']['cpu_system']=$tCellObj->value;
            break;
        case("info:generic_cpu_interrupt{$ts}"): //cpu interrupt 
            $host['generic']['cpu_interrupt']=$tCellObj->value;
            break;
        case("info:generic_cpu_idle{$ts}"): //cpu idle 
            $host['generic']['cpu_idle']=$tCellObj->value;
            break;
        case("info:generic_mem_active{$ts}"): //mem_active
            $host['generic']['mem_active']=$tCellObj->value;
            break;
        case("info:generic_mem_inact{$ts}"): //mem_inact
            $host['generic']['mem_inact']=$tCellObj->value;
            break;
        case("info:generic_mem_wired{$ts}"): //mem_wired
            $host['generic']['mem_wired']=$tCellObj->value;
            break;
        case("info:generic_mem_cache{$ts}"): //mem_cache
            $host['generic']['mem_cache']=$tCellObj->value;
            break;
        case("info:generic_mem_buf{$ts}"): //mem_buf
            $host['generic']['mem_buf']=$tCellObj->value;
            break;
        case("info:generic_mem_free{$ts}"): //mem_free
            $host['generic']['mem_free']=$tCellObj->value;
            break;
        case("info:generic_swap_total{$ts}"): //swap_total
            $host['generic']['swap_total']=$tCellObj->value;
            break;
        case("info:generic_swap_used{$ts}"): //swap_used
            $host['generic']['swap_used']=$tCellObj->value;
            break;
        case("info:generic_swap_free{$ts}"): //swap_free
            $host['generic']['swap_free']=$tCellObj->value;
            break;
        case("info:generic_swap_inuse{$ts}"): //swap_inuse
            $host['generic']['swap_inuse']=$tCellObj->value;
            break;
        case("info:generic_process_sum{$ts}"): //process_sum
            $host['generic']['process_sum']=$tCellObj->value;
            break;
        case("info:generic_process_starting{$ts}"): //process_starting
            $host['generic']['process_starting']=$tCellObj->value;
            break;
        case("info:generic_process_running{$ts}"): //process_running
            $host['generic']['process_running']=$tCellObj->value;
            break;
        case("info:generic_process_sleeping{$ts}"): //process_sleeping
            $host['generic']['process_sleeping']=$tCellObj->value;
            break;
        case("info:generic_process_stopped{$ts}"): //process_stopped
            $host['generic']['process_stopped']=$tCellObj->value;
            break;
        case("info:generic_process_zombie{$ts}"): //process_zombie
            $host['generic']['process_zombie']=$tCellObj->value;
            break;
        case("info:generic_process_waiting{$ts}"): //process_waiting
            $host['generic']['process_waiting']=$tCellObj->value;
            break;
        case("info:generic_process_lock{$ts}"): //process_lock
            $host['generic']['process_lock']=$tCellObj->value;
            break;
        case("info:mysql_summary_uptime{$ts}"): //mysql summary_uptime
            $host['mysql']['summary_uptime']=$tCellObj->value;
            break;
        case("info:mysql_summary_threads_created{$ts}"): //mysql summary_threads_created 
            $host['mysql']['summary_threads_created']=$tCellObj->value;
            break;
        case("info:mysql_summary_questions{$ts}"): //mysql summary_questions 
            $host['mysql']['summary_questions']=$tCellObj->value;
            break;
        case("info:mysql_summary_connections{$ts}"): //mysql summary_connections 
            $host['mysql']['summary_connections']=$tCellObj->value;
            break;
        case("info:mysql_traffic_in{$ts}"): //mysql traffic_in 
            $host['mysql']['traffic_in']=$tCellObj->value;
            break;
        case("info:mysql_traffic_out{$ts}"): //mysql traffic_out 
            $host['mysql']['traffic_out']=$tCellObj->value;
            break;
        case("info:mysql_statement_delete{$ts}"): //mysql statement_delete 
            $host['mysql']['statement_delete']=$tCellObj->value;
            break;
        case("info:mysql_statement_insert{$ts}"): //mysql statement_insert 
            $host['mysql']['statement_insert']=$tCellObj->value;
            break;
        case("info:mysql_statement_select{$ts}"): //mysql statement_select 
            $host['mysql']['statement_select']=$tCellObj->value;
            break;
        case("info:mysql_statement_update{$ts}"): //mysql statement_update 
            $host['mysql']['statement_update']=$tCellObj->value;
            break;
        case("info:mysql_replication{$ts}"): //mysql replication 
            $host['mysql']['replication']=$tCellObj->value;
            break;
        case("info:mysql_seconds_behind_master{$ts}"): //mysql seconds behind master 
            $host['mysql']['seconds_behind_master']=$tCellObj->value;
            break;
        case("info:serving_request{$ts}"): //serving request 
            $host['serving']['request']=$tCellObj->value;
            break;
        case("info:serving_traffic{$ts}"): //serving traffic 
            $host['serving']['traffic']=$tCellObj->value;
            break;
        case("info:serving_engine_status{$ts}"): //serving engine_status 
            $host['serving']['engine_status']=$tCellObj->value;
            break;
        case("info:serving_total_log_num{$ts}"): //serving total_log_num 
            $host['serving']['total_log_num']=$tCellObj->value;
            break;
        case("info:serving_upload_log_num{$ts}"): //serving upload_log_num 
            $host['serving']['upload_log_num']=$tCellObj->value;
            break;
        case("info:serving_file_name{$ts}"): //serving file_name 
            $host['serving']['file_name']=$tCellObj->value;
            break;
        case("info:serving_file_md5{$ts}"): //serving file_md5 
            $host['serving']['file_md5']=$tCellObj->value;
            break;
        case("info:daemon_webserver_status{$ts}"): //daemon webserver_status 
            $host['daemon']['webserver_status']=$tCellObj->value;
            break;
        case("info:daemon_daemon_status{$ts}"): //daemon daemon_status 
            $host['daemon']['daemon_status']=$tCellObj->value;
            break;
        case("info:daemon_login_status{$ts}"): //daemon login_status 
            $host['daemon']['login_status']=$tCellObj->value;
            break;
        case("info:daemon_adserv_status{$ts}"): //daemon adserv_status 
            $host['daemon']['adserv_status']=$tCellObj->value;
            break;
        case("info:daemon_errorlog_status{$ts}"): //daemon errorlog_status 
            $host['daemon']['errorlog_status']=$tCellObj->value;
            break;
        case("info:report_process_speed{$ts}"): //report process_speed 
            $host['report']['process_speed']=$tCellObj->value;
            break;
        case("info:report_wait_process_log_num{$ts}"): //report wait_process_log_num 
            $host['report']['wait_process_log_num']=$tCellObj->value;
            break;
        case("info:madn_availability{$ts}"): //madn availability 
            $host['madn']['availability']=$tCellObj->value;
            break;
        case("info:hadoop_dfs.datanode.copyBlockOp_avg_time{$ts}"): //hadoop 
            $host['hadoop']['dfs.datanode.copyBlockOp_avg_time']=$tCellObj->value;
            break;
        case("info:hadoop_dfs.datanode.heartBeats_avg_time{$ts}"): //hadoop 
            $host['hadoop']['dfs.datanode.heartBeats_avg_time']=$tCellObj->value;
            break;
        case("info:bizlop_4xx_num{$ts}"): //bizlog
            $host['bizlog']['http_4xx_num']=$tCellObj->value;
            break;
        case("info:bizlop_5xx_num{$ts}"): //bizlog
            $host['bizlog']['http_5xx_num']=$tCellObj->value;
            break;
        } 
        //匹配特地的column
        preg_match_all('/info:generic_|info:mysql_|info:serving_|info:daemon_|info:report_|info:madn_|info:hadoop/',$eventItemWithTs,$match);
        switch ($match[0][0]) {
        case('info:generic_'):
            /*{{{info:generic*/
            if(!empty($ts)) { //column是否有ts后缀 
                $real_monitem=substr($eventItemWithTs,strlen('info:generic_'),strlen($eventItemWithTs)-strlen('info:generic_')-6); //获取实际的去掉info:generic_前缀和110901这样的时间戳后缀的监控项字段
            } else {
                $real_monitem=substr($eventItemWithTs,strlen('info:generic_'),strlen($eventItemWithTs)-strlen('info:generic_')); //获取实际的去掉info:generic_前缀的监控项字段
            }
            list($item1,$item2,$item3,$item4) = array_pad(explode('-', $real_monitem), 4, ""); //试探最多4个以-分隔 
            if($item1=='disk') { //generic的disk部分 
                if($item3=='capacity') {
                    $host['generic']['disk_capacity'][$item2]=$tCellObj->value;
                } elseif($item3=='iused') {
                    $host['generic']['disk_iused'][$item2]=$tCellObj->value;
                }
            }
            if($item1=='network') { //generic的网络接口部分 
                if($item3=='in') {
                    $host['generic']['network_in'][$item2]=$tCellObj->value;
                } elseif ($item3=='out') {
                    $host['generic']['network_out'][$item2]=$tCellObj->value;
                }
            }
            if($item1=='service') { //generic的服务部分 
                if($item3=='port') {
                    $host['generic']['service_port'][$item2]=$tCellObj->value;
                } elseif ($item3=='status') {
                    $host['generic']['service_status'][$item2]=$tCellObj->value;
                }
            }
            /*}}}*/
            break;
        case('info:mysql_'):
            if(!empty($ts)) { //column是否有ts后缀 
                $real_monitem=substr($eventItemWithTs,strlen('info:mysql_'),strlen($eventItemWithTs)-strlen('info:mysql_')-6); //获取实际的去掉info:generic_前缀和110901这样的时间戳后缀的监控项字段
            } else {
                $real_monitem=substr($eventItemWithTs,strlen('info:mysql_'),strlen($eventItemWithTs)-strlen('info:mysql_')); //获取实际的去掉info:generic_前缀的监控项字段
            }
            list($item1,$item2,$item3,$item4) = array_pad(explode('-', $real_monitem), 4, ""); //试探最多4个以-分隔 
            if($item1=='dbinfo') { //mysql的dbinfo 
                if($item3=='table_sum') {
                    $host['mysql']['dbinfo_table_sum'][$item2]=$tCellObj->value;
                } elseif($item3=='maxsize_table_name') {
                    $host['mysql']['dbinfo_maxsize_table_name'][$item2]=$tCellObj->value;
                } elseif($item3=='maxsize_table_size') {
                    $host['mysql']['dbinfo_maxsize_table_size'][$item2]=$tCellObj->value;
                }
            }
            if($item1=='tableinfo') { //mysql的tableinfo 
                if($item3=='db_name') {
                    $host['mysql']['tableinfo_db_name'][$item2]=$tCellObj->value;
                } elseif($item3=='engine') {
                    $host['mysql']['tableinfo_engine'][$item2]=$tCellObj->value;
                } elseif($item3=='rows') {
                    $host['mysql']['tableinfo_rows'][$item2]=$tCellObj->value;
                } elseif($item3=='data_length') {
                    $host['mysql']['tableinfo_data_length'][$item2]=$tCellObj->value;
                } elseif($item3=='index_length') {
                    $host['mysql']['tableinfo_index_length'][$item2]=$tCellObj->value;
                } elseif($item3=='auto_increment') {
                    $host['mysql']['tableinfo_auto_increment'][$item2]=$tCellObj->value;
                } elseif($item3=='update_time') {
                    $host['mysql']['tableinfo_update_time'][$item2]=$tCellObj->value;
                } elseif($item3=='collation') {
                    $host['mysql']['tableinfo_collation'][$item2]=$tCellObj->value;
                } 
            }
            break;
        case('info:serving_'):
            if(!empty($ts)) { //column是否有ts后缀 
                $real_monitem=substr($eventItemWithTs,strlen('info:serving_'),strlen($eventItemWithTs)-strlen('info:serving_')-6); //获取实际的去掉info:generic_前缀和110901这样的时间戳后缀的监控项字段
            } else {
                $real_monitem=substr($eventItemWithTs,strlen('info:serving_'),strlen($eventItemWithTs)-strlen('info:serving_')); //获取实际的去掉info:generic_前缀的监控项字段
            }
            list($item1,$item2,$item3,$item4) = array_pad(explode('-', $real_monitem), 4, ""); //试探最多4个以-分隔 
            if($item1=='adimage') {
                if($item3=='ad_pos_num') {
                    $host['serving']['ad_pos_num'][$item2]=$tCellObj->value;
                } elseif($item3=='ad_campaign_num') {
                    $host['serving']['ad_campaign_num'][$item2]=$tCellObj->value;
                } elseif($item3=='delivering_cache_num') {
                    $host['serving']['delivering_cache_num'][$item2]=$tCellObj->value;
                } elseif($item3=='pack_serialnum') {
                    $host['serving']['pack_serialnum'][$item2]=$tCellObj->value;
                } elseif($item3=='publish_role') {
                    $host['serving']['publish_role'][$item2]=$tCellObj->value;
                }
            }
            break;
        case('info:daemon_'):
            break;
        case('info:report_'):
            break;
        case('info:madn_'):
            if(!empty($ts)) { //column是否有ts后缀 
                $real_monitem=substr($eventItemWithTs,strlen('info:madn_'),strlen($eventItemWithTs)-strlen('info:madn_')-6); //获取实际的去掉info:madn_前缀和110901这样的时间戳后缀的监控项字段
            } else {
                $real_monitem=substr($eventItemWithTs,strlen('info:madn_'),strlen($eventItemWithTs)-strlen('info:madn_')); //获取实际的去掉info:madn_前缀的监控项字段
            }
            list($item1,$item2,$item3,$item4) = array_pad(explode('-', $real_monitem), 4, ""); //试探最多4个以-分隔 
            if ($item3=='statuscode') {
            }
            $host['madn']['availability'][]=$tCellObj->value;
            break;
        case('info:hadoop_'):
            break;
        }
    }
    $res[$host_name] = $host; //得到全部监控项
    $word_arr[$host_name] = makeUIWord($res); //获取所有事件的UI描述
    return $word_arr; //返回格式host=>eventNum=>statusInfo 
}

/**
 *@brief 根据数组返回监控项目的状态信息的文字
 *@param $info_arr 数组
 */
function makeUIWord($info_arr) {
    $temp_arr = array();
    foreach($info_arr as $host => $monitor_info) {
        /*{{{监控事件000(disk capacity)*/
        if(is_array($monitor_info['generic']['disk_capacity'])) {
            foreach($monitor_info['generic']['disk_capacity'] as $disk => $cap) {
                if ( !empty($disk) )
                    $temp_arr[] = "Disk {$disk} capacity is $cap%";
            } 
        }
        $ev_word['000'] = join(',', $temp_arr);
        $ev_word['000n'] = join(',', $temp_arr);
        $temp_arr = array();
        /*}}}*/
        /*{{{监控事件001(disk iused)*/
        if(is_array($monitor_info['generic']['disk_iused'])) {
            foreach($monitor_info['generic']['disk_iused'] as $disk => $cap) {
                if ( !empty($disk) )
                    $temp_arr[] = "Disk {$disk} inode used is $cap%";
            } 
        }
        $ev_word['001'] = join(',', $temp_arr);
        $ev_word['001n'] = join(',', $temp_arr);
        $temp_arr = array();
        /*}}}*/
        /*{{{监控事件002(load average)*/
        if(isset($monitor_info['generic']['summary_load'])) {
            $temp_str = "System load average is {$monitor_info['generic']['summary_load']}";
            $ev_word['002'] = $temp_str;
            $ev_word['002n'] = $temp_str;
        }
        /*}}}*/
        /*{{{监控事件003(内存使用率)*/
        if(isset($monitor_info['generic']['mem_active']) && isset($monitor_info['generic']['mem_inact']) && 
            isset($monitor_info['generic']['mem_free'])) {
                $denominator = $monitor_info['generic']['mem_inact']+$monitor_info['generic']['mem_free']+$monitor_info['generic']['mem_active'];
                $mem_pct = $denominator!=0? sprintf('%01.2f',$monitor_info['generic']['mem_active']*100/$denominator): 0;
                $temp_str = "Memory useage is {$mem_pct}% active:{$monitor_info['generic']['mem_active']} inact:{$monitor_info['generic']['mem_inact']}
                wired:{$monitor_info['generic']['mem_wired']} cache:{$monitor_info['generic']['mem_cache']} free:{$monitor_info['generic']['mem_free']} "; //TODO 其他内存指标也要显示 
                $ev_word['003'] = $temp_str;
                $ev_word['003n'] = $temp_str;
            }
        /*}}}*/
        /*{{{监控事件004(进程数)*/
        if(isset($monitor_info['generic']['process_running'])) {
            $temp_str = "Process: lock:{$monitor_info['generic']['process_lock']} running:{$monitor_info['generic']['process_running']} 
                sleeping:{$monitor_info['generic']['process_sleeping']} starting:{$monitor_info['generic']['process_starting']} stopped:
        {$monitor_info['generic']['process_stopped']} sum:{$monitor_info['generic']['process_sum']} 
        waiting:{$monitor_info['generic']['process_waiting']} zombie:{$monitor_info['generic']['process_zombie']}";
            $ev_word['004'] = $temp_str;
            $ev_word['004n'] = $temp_str;
        }
        /*}}}*/
        /*{{{监控事件005(CPU占用率)*/
        if(isset($monitor_info['generic']['cpu_idle']) && isset($monitor_info['generic']['cpu_interrupt']) && 
            isset($monitor_info['generic']['cpu_nice']) && isset($monitor_info['generic']['cpu_system']) && 
            isset($monitor_info['generic']['cpu_use'])) {
                $temp_str = "CPU: use:{$monitor_info['generic']['cpu_use']}% nice:{$monitor_info['generic']['cpu_nice']}% 
                    system:{$monitor_info['generic']['cpu_system']}% interrupt:{$monitor_info['generic']['cpu_interrupt']}% 
                    idle:{$monitor_info['generic']['cpu_idle']}%";
                $ev_word['005'] = $temp_str;
                $ev_word['005n'] = $temp_str;
            }
        /*}}}*/
        /*{{{监控事件006(TCP/IP端口)*/
        if(isset($monitor_info['generic']['service_status'])) {
            foreach($monitor_info['generic']['service_status']as $service_name => $status) {
                $temp_arr[] = $status? "service {$service_name} status is ok": "service {$service_name} status is CORRUPTED";
            }
        }
        $ev_word['006'] = join(',', $temp_arr); 
        $ev_word['006n'] = join(',', $temp_arr); 
        $temp_arr = array();
        /*}}}*/
        /*{{{监控事件007(TCP/IP连接数)*/
        if(isset($monitor_info['generic']['summary_tcp_connections'])) {
            $temp_str = "TCP/IP connections:{$monitor_info['generic']['summary_tcp_connections']}";
            $ev_word['007'] = $temp_str;
            $ev_word['007n'] = $temp_str;
        }
        /*}}}*/
        /*{{{监控事件008(网络接口流量)*/
        if(isset($monitor_info['generic']['network_in']) && isset($monitor_info['generic']['network_out'])) {
            foreach($monitor_info['generic']['network_in'] as $interface => $flow) {
                $temp_arr[] = "interface:{$interface} flow:{$flow}";
            }
        }
        $ev_word['008'] = join(',', $temp_arr);
        $ev_word['008n'] = join(',', $temp_arr);
        $temp_arr = array();
        /*}}}*/
        /*{{{监控事件009(serving单台负荷)*/
        if(isset($monitor_info['serving']['request'])) {
            $temp_str = "Request num is {$monitor_info['serving']['request']} reqs/s";
            $ev_word['009'] = $temp_str;
            $ev_word['009n'] = $temp_str;
        }
        /*}}}*/
        /*{{{监控事件010(serving工作节点数量)*/
        //TODO 
        $ev_word['010'] = "";
        /*}}}*/
        /*{{{监控事件011(serving广告发布)*/
        if(isset($monitor_info['serving']['engine_status'])) {
            $temp_str = $monitor_info['serving'] ['engine_status']? "Advt deliver status is ok": "Advt deliver status is CORRUPTED";
            $ev_word['011'] = $temp_str;
            $ev_word['011n'] = "Advt deliver status is ok";
        }
        /*}}}*/
        /*{{{监控事件012(daemon webserver状态)*/
        if(isset($monitor_info['daemon']['webserver_status'])) {
            $temp_str = 1!=$monitor_info['daemon']['webserver_status']?"CORRUPTED":"ok";
            $temp_str = "Webserver status is ".$temp_str;
            $ev_word['012'] = $temp_str;
            $ev_word['012n'] = "Webserver status is ok";
        }
        /*}}}*/
        /*{{{监控事件013(后台daemon状态)*/
        if(isset($monitor_info['daemon']['daemon_status'])) {
            $temp_str = 1!=$monitor_info['daemon']['daemon_status']?"CORRUPTED":"ok";
            $temp_str = "Backend daemon status is ".$temp_str;
            $ev_word['013'] = $temp_str;
            $ev_word['013n'] = "Backend daemon status is ok";
        }
        /*}}}*/
        /*{{{监控事件014(daemon login状态)*/
        if(isset($monitor_info['daemon']['login_status'])) {
            $temp_str = 1!=$monitor_info['daemon']['login_status']?"CORRUPTED":"ok";
            $temp_str = "Login status is ".$temp_str;
            $ev_word['014'] = $temp_str;
            $ev_word['014n'] = "Login status is ok";
        }
        /*}}}*/
        /*{{{监控事件015(daemon广告投放状态)*/
        if(isset($monitor_info['daemon']['adserv_status'])) {
            $temp_str = 1!=$monitor_info['daemon']['adserv_status']?"CORRUPTED":"ok";
            $temp_str = "Adserv status is ".$temp_str;
            $ev_word['015'] = $temp_str;
            $ev_word['015n'] = "Adserv status is ok";
        }
        /*}}}*/
        /*{{{监控事件016(daemon error log状态)*/
        if(isset($monitor_info['daemon']['errorlog_status'])) {
            $temp_str = "Error log status is ok";
            $ev_word['016'] = $temp_str;
            $ev_word['016n'] = $temp_str;
        }
        /*}}}*/
        /*{{{监控事件017(mysql数据库连接数量)*/
        if(isset($monitor_info['mysql']['summary_connections'])) {
            $monitor_info['mysql']['summary_connections'] += 0; //为空则是0 
            $temp_str = "Mysql connections:{$monitor_info['mysql']['summary_connections']}";
            $ev_word['017'] = $temp_str;
            $ev_word['017n'] = $temp_str;
        }
        /*}}}*/
        /*{{{监控事件018(mysql单表最大尺寸)*/
        //TODO
        /*}}}*/
        /*{{{监控事件019(mysql创建线程数量)*/
        if(isset($monitor_info['mysql']['summary_threads_created'])) {
            $monitor_info['mysql']['summary_threads_created'] += 0; //为空则是0 
            $temp_str = "Mysql threads created:{$monitor_info['mysql']['summary_threads_created']}";
            $ev_word['019'] = $temp_str;
            $ev_word['019n'] = $temp_str;
        }
        /*}}}*/
        /*{{{监控事件020(Mysql Master/Slave状态)*/
        $ev_word['020'] = 'Master/Slave function is non-operational: Platform secondary functions are non-operational';
        $ev_word['020n'] = 'Master/Slave function is operational';
        /*}}}*/
        /*{{{监控事件021(关键表控制)*/
        //TODO
        /*}}}*/
        /*{{{监控事件022(report 待处理log数)*/
        if(isset($monitor_info['report']['wait_process_log_num'])) {
            $monitor_info['mysql']['wait_process_log_num'] += 0; //为空则是0 
            $temp_str = "wait process logs:{$monitor_info['report']['wait_process_log_num']}";
            $ev_word['022'] = $temp_str;
            $ev_word['022n'] = $temp_str;
        }
        /*}}}*/
        /*{{{监控事件023(serving日志生成)*/
        $ev_word['023'] = "Loginfo creation failed! May be not any request incoming.";
        $ev_word['023n'] = "Loginfo creation ok.";
        /*}}}*/
        /*{{{监控事件024(serving填充率)*/
        $ev_word['024'] = 'Fillrate to low!';
        $ev_word['024n'] = 'Fillrate ok';
        /*}}}*/
        /*{{{监控事件025(madn可用性)*/
        foreach ($monitor_info['madn']['availability'] as $urlInfo) {
            list($statusCode, $url) = explode('|', $urlInfo);
            if (empty($statusCode)) {
                $arr[]="To $url access timeout.";
            } else {
                $arr[]="To $url got statuscode:$statusCode";
            }
        }
        if (!empty($arr)) {
            $ev_word['025'] = 'Madn availability ERROR:<br />'.join('<br />',$arr);
            $ev_word['025n'] = 'Madn availability ok:<br />'.join('<br />',$arr);
        }
        /*}}}*/
        /*{{{监控事件026(datanode块复制时间)*/
        if (isset($monitor_info['hadoop']['dfs.datanode.copyBlockOp_avg_time'])) {
            $ev_word['026'] = 'datanode copyBlockOp average time too long,current:'.
                $monitor_info['hadoop']['dfs.datanode.copyBlockOp_avg_time']."ms";
            $ev_word['026n'] = 'datanode copyBlockOp average time ok,current:'.
                $monitor_info['hadoop']['dfs.datanode.copyBlockOp_avg_time']."ms";
        }
        /*}}}*/
        /*{{{监控事件027(datanode向namenode汇报平均时间)*/
        if (isset($monitor_info['hadoop']['dfs.datanode.heartBeats_avg_time'])) {
            $ev_word['027'] = 'datanode heartBeats average time too long,current:'.
                $monitor_info['hadoop']['dfs.datanode.heartBeats_avg_time']."ms";
            $ev_word['027n'] = 'datanode heartBeats average time ok,current:'.
                $monitor_info['hadoop']['dfs.datanode.heartBeats_avg_time']."ms";
        }
        /*}}}*/
        /*{{{监控事件029(mysql slave延迟时间)*/
        if (isset($monitor_info['mysql']['seconds_behind_master'])) {
            $ev_word['029'] = 'slave latency time too long,current:'.
                $monitor_info['mysql']['seconds_behind_master']."s";
            $ev_word['029n'] = 'slave latency time ok,current:'.
                $monitor_info['mysql']['seconds_behind_master']."s";
        }
        /*}}}*/
        /*{{{监控事件030(bizlog HTTP4xx请求数)*/
        if ( isset($monitor_info['bizlog']['http_4xx_num']) ) {
            $ev_word['030'] = 'HTTP 4XX status code:'.
                $monitor_info['bizlog']['http_4xx_num']." reqs";
            $ev_word['030n'] = 'HTTP 4XX status code:'.
                $monitor_info['bizlog']['http_4xx_num']." reqs";
        }
        /*}}}*/
        /*{{{监控事件030(bizlog HTTP5xx请求数)*/
        if ( isset($monitor_info['bizlog']['http_5xx_num']) ) {
            $ev_word['031'] = 'HTTP 5XX status code:'.
                $monitor_info['bizlog']['http_5xx_num']." reqs";
            $ev_word['031n'] = 'HTTP 5XX status code:'.
                $monitor_info['bizlog']['http_5xx_num']." reqs";
        }
        /*}}}*/
    }
    return $ev_word;
}

/**
 *@brief 取出全部自定义组
 *@return 成功返回全部自定义组组成的数组，失败返回FALSE
 */
function getAllCustGroup() {
    list($table, $col, $row_key) = array(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, __KEY_INI_GROUP_CUST);
    try {
        $arr = $GLOBALS['mdb_client']->get($table, $row_key , $col);
        $res = (array)json_decode($arr[0]->value); 
        $cust_servgroups = $res['server_group'];
        $cust_servgroups = empty($cust_servgroups)? array(): array_keys((array)$cust_servgroups); //得到自定义组 
        DebugInfo("[serverGroup][read cust_servgroups][res:".join(',',(array)$cust_servgroups)."]", 3);
    } catch(Exception $e) {
        DebugInfo("[serverGroup][read cust_servgroups][error]", 3);
        return false;
    }
    return $cust_servgroups;
}
/**
 *@brief 把宕机(下标为0)的前面的排序
 */
function sortDown($a, $b) {
    if ($a == $b) {
        return 0;
    }
    if ($a == 0) {
        return -1;
    } elseif ($b == 0) {
        return 1;
    }
    return ($a < $b) ? 1 : -1;
}

function getNeedfixArr() {
    /* {{{ 查询needfix事件(以防止恢复事件没有set到事件表造成的事件仍然没有解决的问题)
     */
    $needfixList=$GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, "needfix", "event:item");
    $needfixList=$needfixList[0]->value;
    $tmpNeedfixArr=explode('|',$needfixList);
    foreach ($tmpNeedfixArr as $problemEvent) {
        $needfixArr[]=substr($problemEvent,0,3);
    }
    /* }}} */
    return $needfixArr;
}

function getHostOnlineDownStatus() {
    list($table_name,$start_row,$family) = array(__MDB_TAB_HOST, '', array('info')); //从row的起点开始 
    try {
        $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
        while (true) {
            $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
            if (array_filter($get_arr) == null) break;
            foreach ( $get_arr as $TRowResult ) {
                if (!empty($TRowResult->row)) {
                    $host_arr[$TRowResult->row]=$TRowResult->columns['info:status']->value; //状态 
                }
            }
        }
        $GLOBALS['mdb_client']->scannerClose($scanner); //关闭scanner 
    } catch (Exception $e) {
        return false;
    }
    return $host_arr;
}

/**
 *@brief  获取每台服务器的在即时表所有存在的事件,if any
 */
function getActiveEvents($hst_arr) {
    foreach ((array)array_keys($hst_arr) as $row_key) {
        try {
            $res=$GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $row_key, array("event:"));
            $res=array_filter((array)($res[0]->columns));
            if (!empty($res)) {
                foreach ($res as $event => $TCellobj) {
                    $event=str_replace("event:","",$event); //得到事件代码(如:011c)
                    if ($event!=__EVENTCODE_DOWN) { //暂时不管宕机事件 TODO 
                        if ($TCellobj->value==__EVENT_ACTIVE) {
                            $act_event[$row_key][]=$event;
                        }
                    }
                } 
            }
        } catch (Exception $e) {
            return false;
        }
    }
    return $act_event; 
}

/**
 *brief 从即时信息表里获取全部未解决的事件,如果存在多种类型，按照严重的等级组成数组
 */
function getHostFinalStatus() {
    $needfixArr=getNeedfixArr();
    $host_arr=getHostOnlineDownStatus();
    $active_event=getActiveEvents($host_arr);
    foreach ($active_event as $srv => $eventArr) {
        foreach ($eventArr as $event) {
            try {
                $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, $srv, "event:{$event}");
                //这里value是以|连接的2段，前一段为__EVENT_ACTIVE,后一段是事件的描述内容
                $res = array_filter((array)explode('|',$arr[0]->value));
                if (!empty($res) && count($res)==__NUM_EVENT_VALUE) {
                    list($event_status, $event_desc) = $res;
                    DebugInfo("[event:$event][server:$srv][event_status:$event_status][event_desc:$event_desc]", 3);
                    if (in_array(substr($event,0,3),$needfixArr) && $event_status == __EVENT_ACTIVE) {
                        $event_lev = substr($event,-1);
                        if (isset($res_unfixed[$srv])) { //既有注意事件又有严重事件则归到4
                            if ($res_unfixed[$srv]==__EVENT_LEV_CAUTION) {
                                $res_unfixed[$srv] = $event_lev==__EVENT_LEV_CAUTION? __EVENT_LEV_CAUTION_NUM: __EVENT_LEV_CAUTION_WARNING_NUM;

                            } elseif ($res_unfixed[$srv]==__EVENT_LEV_WARNING) {
                                $res_unfixed[$srv] = $event_lev==__EVENT_LEV_CAUTION? __EVENT_LEV_CAUTION_WARNING_NUM: __EVENT_LEV_WARNING_NUM;
                            }
                        } else {
                            $res_unfixed[$srv]=$event_lev==__EVENT_LEV_CAUTION? __EVENT_LEV_CAUTION_NUM: __EVENT_LEV_WARNING_NUM; //得到未解决事件数组 
                        }
                    }
                } else {
                    return false;
                }
            } catch (Exception $e) {
                return false;
            }
        }
    }
    foreach ((array)array_keys($host_arr) as $host) { //遍历服务器数组，设置有事件的元素后存到host_arr2 
        if (in_array($host, array_keys($res_unfixed))) {
            $host_arr2[$host]=$res_unfixed[$host];
        }
    }
    $last_host_arr=array_merge((array)$host_arr,(array)$host_arr2); //有事件host_arr数组和只有在线状态的host_arr2数组合并起立，组成last_host_arr 
    foreach ($host_arr as $host=>$status) {
        if ($status==__EVENT_LEV_DOWN_NUM) { //TODO 这里改成常量 
            $last_host_arr[$host] = __EVENT_LEV_DOWN_NUM;
        }
    }
    return $last_host_arr;
}

/**
 *@brief HTTP POST
 *@param $url 要post的url
 *@param $port 端口
 *@param $postArr post的参数和数值
 */
function sockPost($url,$postArr) {
    while ( list($k,$v) = each($postArr) ) {
        $paramVal=rawurlencode($k)."=".rawurlencode($v);
        $post[]=$paramVal;
    }
    $post=join('&',$post);
    $len = strlen($post);
    $urlInfo=parse_url($url);
    $port=isset($urlInfo['port']) ? $urlInfo['port'] : 80;
    $fp = @fsockopen( $urlInfo['host'] , $port, $errno, $errstr, 30);
    if (!$fp) {
        return false;
    } else {
        $receive = '';
        $out = "POST {$urlInfo['path']} HTTP/1.1\r\n";
        $out .= "Host: {$urlInfo['host']}\r\n";
        $out .= "Content-type: application/x-www-form-urlencoded\r\n";
        $out .= "Connection: Close\r\n";
        $out .= "Content-Length: $len\r\n";
        $out .="\r\n";
        $out .= $post."\r\n";
        fwrite($fp, $out);
        while (!feof($fp)) {
            $receive .= fgets($fp, 128);
        }
        fclose($fp);
    }
    return $receive;
}

/**
 *@brief HTTP GET
 *@param $url 要get的url
 */
function sockGet($url) {
    $urlInfo=parse_url($url);
    $fp = fsockopen($urlInfo['host'], 80, $errno, $errstr, 30);
    if (!$fp) {
        return false;
    } else {
        $out = "GET {$urlInfo['path']} HTTP/1.1\r\n";
        $out .= "Host: {$urlInfo['host']}\r\n";
        $out .= "Connection: Close\r\n\r\n";
        fwrite($fp, $out);
        while (!feof($fp)) {
            $receive.=fgets($fp, 128);
        }
        fclose($fp);
    }
    return $receive;
}

/**
 *@brief 获取权限
 *@param 权限字符串,在inc/initApi.m中的privilege_item_arr
 */
function canAccess($str_pri) {
    $user=$_COOKIE[__CO_MMSUNAME];
    if ($user==='monitoradmin') {
        return true;
    }
    //用户可能属于多个组，要联合起来判断
    $matchedUserGrp=array();
    try {
        $scanner = $GLOBALS['mdb_client']->scannerOpen(__MDB_TAB_USERGROUP, '', array('info', 'member'));
        while (true) { //TODO 这里可能会发生超时，需要加时限 
            $get_arr = $GLOBALS['mdb_client']->scannerGet($scanner);
            if (array_filter($get_arr) == null) break;
            foreach ( $get_arr as $TRowResult ) {
                $user_group = $TRowResult->row; //以用户组为rowkey 
                /* {{{ 取出描述和成员用户
                 */
                $column = $TRowResult->columns;
                foreach ($column as $family_column=>$Tcell) {
                    $family = array_shift(explode(':', $family_column)); //取列族 
                    switch ($family) { //共2个列族，info和member 
                    case('info'):
                        $family_column=='info:desc' && $desc = $Tcell->value; //取得描述 
                        break;
                    case('member'):
                        $tmp_member = substr($family_column, strpos($family_column, ':')+1); //取得成员用户 
                        $member[] = $Tcell->value==__MONITOR_IS_MEMBER? $tmp_member: NULL; //断言值为member 
                        break;
                    }
                }
                $can_del = $user_group==__MONITOR_DEFAULT_USERGROUP? 0: 1; //为1可以删除，为0默认用户不能删除 
                $str[$user_group]=array($desc,(array)$member,$can_del); //组成用户组名为key的数组 
                if (in_array($user,$member)) {
                    if (!in_array($user_group,$matchedUserGrp)) {
                        $matchedUserGrp[]=$user_group;
                    }
                }
                /* }}} */
                unset($member);
            }
        }
        $GLOBALS['mdb_client']->scannerClose($scanner); //关闭scanner 
    } catch (Exception $e) {
        $err = true;
    }
    //遍历所属的用户组，取出全部权限的并集
    foreach ($matchedUserGrp as $ug) {
        $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_USERGROUP, $ug, 'info:privilege');
        $value = $arr[0]->value;
        $priArr=explode('|',$value);
        foreach ($priArr as $priStr) {
            list($priItem,$hasPri)=explode('#',$priStr);
            if (!isset($LastPriv[$priItem])) {
                $LastPriv[$priItem]=0;
            }
            if ($LastPriv[$priItem]==0) {
                $LastPriv[$priItem]=$hasPri=="1"?"0":"1";
            }
        }
    }
    return 0!=$LastPriv[$str_pri]?true:false;
}
?>
