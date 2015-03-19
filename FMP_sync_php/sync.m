<?php
/*
  +----------------------------------------------------------------------------+
  | Name:sync.m
  +----------------------------------------------------------------------------+
  | Comment:同步fb数据到fmp
  +----------------------------------------------------------------------------+
  | Author:Yinjia
  +----------------------------------------------------------------------------+
  | Create:2015-03-19 17:23:10
  +----------------------------------------------------------------------------+
  | Last Modified: 2015-03-19 17:29:15
  +----------------------------------------------------------------------------+
 */
include_once('inc/inc.sync.m');
include_once('fun/fun.common.m');
include_once('fun/fun.fs.m');
include_once('fun/fun.mcd.m');
include_once('fun/fun.monitor.m');
list($process_name,$ext_name)=explode('.',basename(__FILE__));
include_once('modules/sync_init.m');

chdir($work_dir);
while ($run) {
    $now=time();

    /*** read status file***/
    if ($fp=@fopen($status_file,"rb")) {
        flock($fp,LOCK_SH);
        $last_status=trim(fread($fp,filesize($status_file)));
        list($last_ustamp,$last_offset,$last_inode)=explode('|',$last_status);
        fclose($fp);
        $debug_data="[$process_name]::[last_time:".date("Y-m-d H:i:s",$last_ustamp)."]-[last_offset:$last_offset]-[last_inode:$last_inode]";
        DebugInfo(1,$debug_level,$debug_data);
    }

    //build upload string
    $upload_str='';


    //update status
    $tmp_status="$now|$cur_offset|$read_inode";
    if ($fp=@fopen($status_file,"wb")) {
        fputs($fp,$tmp_status);
        ftruncate($fp,strlen($tmp_status));
        fclose($fp);
    }

    //continue?
    if (!$daemon_stat || $proc_life<=($process_old=$now-$start_time)) {
        $run=false;
    } else {
        sleep($sleep);
    }
}
?>
