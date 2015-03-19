<?php
$start_time=time();

/** version info **/
$custom_argvs=readArgv($argv);
if (isset($custom_argvs['version'])) {
    echo "version:".__VERSION."\n";
    exit;
}
$debug_level=isset($custom_argvs['_d'])?(int)$custom_argvs['_d']:0;
$debug_data="[debug_level:$debug_level]";
DebugInfo(1,$debug_level,$debug_data);

$input_source=empty($custom_argvs['_s'])?null:$custom_argvs['_s'];
$input_file=empty($custom_argvs['_f'])?null:$custom_argvs['_f'];

/** make sure only one process running **/
$pid_file=__PROC_ROOT.'/'.__RUN_SUBPATH.'/'.$process_name.'.pid';
makeDir($pid_file,"0755",0,'f');
if (SingleProcess($process_name,$pid_file)!==TRUE) {
    $sys_data="last upload process exists";
    DebugInfo(1,$debug_level,$sys_data);
    exit;
}
/** fix uncompile php script above code can`t make single proc bug **/
$lock_file=__PROC_ROOT.'/'.__RUN_SUBPATH.'/'.$process_name.'.lock';
if (!flock($tempLockFile=fopen($lock_file,'w'), LOCK_NB | LOCK_EX)) {
    $sys_data="last upload process exists,cause lock mechanisms";
    DebugInfo(1,$debug_level,$sys_data);
    exit;
}

$conf_file=__PROC_ROOT.'/'.__CONF_SUBPATH.'/'.$process_name.'.ini';
makeDir($conf_file,"0755",0,'f');

$status_file=__PROC_ROOT.'/'.__STATUS_SUBPATH."/".$process_name.'.status';
makeDir($status_file,"0755",0,'f');

$work_dir=__PROC_ROOT.'/'.__WORK_SUBPATH;
makeDir($work_dir,"0755",0,'d');

$debug_data="[run_file:$pid_file]-[conf_file:$conf_file]-[status_file:$status_file]-[work_dir:$work_dir]";
DebugInfo(1,$debug_level,$debug_data);

$del_stat=true;
$daemon_stat=true;
$run=true;

if (true===buildConf($conf_file,$array_conf)) {
    echo "build configuration file,done. run again\n";
    exit();
} else {
    $array_conf=parse_ini_file($conf_file,true);
}

//read configuration file

DebugInfo(1,$debug_level,$debug_data);

$sleep=empty($array_conf['sleep'])?__SLEEP:(int)$array_conf['sleep'];
$proc_life=empty($array_conf['proc_life'])?__PROC_LIFE:(int)$array_conf['proc_life'];
$mcd_server=empty($array_conf['mcd_server'])?__MCD_SERVER:$array_conf['mcd_server'];
