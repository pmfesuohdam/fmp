<?php
function microtime_float() {
    list($usec,$sec)=explode(" ",microtime());
    return ((float)$usec+(float)$sec);
}

function readArgv($orig_argv) {
    $offset=1;
    if (!empty($orig_argv) && is_array($orig_argv)) {
        foreach ($orig_argv as $key=>$argv_value) {
            if ($key==$offset) {
                if (0===strpos($argv_value,'-')) {
                    $key='_'.substr($argv_value,1);
                    $next_value=$orig_argv[++$offset];
                    if (null!==($next_value) && 0!==strpos($next_value,'-')) {
                        $return[$key]=$next_value;
                    } else {
                        $return[$key]=true;
                        --$offset;
                    }
                } else {
                    $return[$argv_value]=true;
                }
                $offset++;
            }
        }
    }
    return isset($return)?$return:false;
}

function procSpeed($point,$last_stamp=null) {
    global $debug_level;
    $cur_stamp=microtime_float();
    if ($point=='0') {
        DebugInfo(0,$debug_level,"[fun.procSpeed]-[begin_test]");
    } else {
        $duration=round($cur_stamp-$last_stamp,2);
        DebugInfo(0,$debug_level,"[fun.procSpeed]-[$point]-[$duration]");
    }
    return $cur_stamp;
}

function scan_dir($file,$dir_root,$filetype='J',$check_file=false,$array_return=null) {
    global $debug_level;
    if (empty($array_return)) $array_return=array();
    if (empty($file)) {
        if ($filetype==='J') {
            $ext='tbz2';
        } elseif ($filetype==='Z') {
            $ext='tgz';
        }
        if ($dh=@opendir($dir_root)) {
            while(($file=readdir($dh))!==false) {
                list($file_name,$file_ext)=explode(".",$file);
                if ($file!=="." && $file!=="..") {
                    if (is_dir($dir_root.'/'.$file)) {
                        $array_return=scan_dir(null,$dir_root.'/'.$file,$filetype,$check_file,$array_return);
                    } elseif ($file_ext==$ext) {
                        if ($check_file) {
                            if ($filetype==='J') {
                                system("/usr/bin/bzip2 -t $dir_root/$file",$file_stat);
                            } elseif ($filetype==='Z') {
                                system("/usr/bin/gzip -t $dir_root/$file",$file_stat);
                            }
                        } else {
                            $file_stat=0;
                        }
                        if ($file_stat===0) {
                            DebugInfo(4,$debug_level,"[fun.scan_dir]-[find_file:$dir_root/$file]");
                            $array_return[]=$dir_root.'/'.$file;
                        }
                    }
                }
            }
            closedir($dh);
        }
    } elseif (file_exists($file)) {
        $array_return[]=$file;
    }
    return $array_return;
}

function SingleProcess($process_name_s,$pid_file_s) {
    if (file_exists($pid_file_s) && $fp=@fopen($pid_file_s,"rb")) {
        flock($fp,LOCK_SH);
        $last_pid=trim(fread($fp,filesize($pid_file_s)));
        fclose($fp);
        if (!empty($last_pid)) {
            $proc_info=exec("/bin/ps -p $last_pid -o pid= -o comm=");
            list($last_pid,$running_process_name)=explode(" ",trim($proc_info));
            if (!flock($pid_fp=fopen($pid_file_s,'r'), LOCK_NB | LOCK_EX)) {
                exit();
            }
            if ($running_process_name==$process_name_s) {
                return FALSE;
            }
        }
    }
    /** save process ID in pid file **/
    $cur_pid=posix_getpid();
    if ($fp=@fopen($pid_file_s,"wb")) {
        fputs($fp,$cur_pid);
        ftruncate($fp,strlen($cur_pid));
        fclose($fp);
        return TRUE;
    } else {
        return FALSE;
    }
}

function DebugInfo($debug_level_org,$debug_level_input,$debug_data) {
    if ($debug_level_org<=$debug_level_input && !empty($debug_data)) {
        $debug_data.='::['.__VERSION."]";
        echo $debug_data."\n";
    }
}

function SaveSysLog($data,$syslog_facility='LOG_LOCAL1',$syslog_level='LOG_ALERT',$syslog_tag='monitor') {
    define_syslog_variables();
    openlog($syslog_tag,LOG_PID,constant($syslog_facility));
    syslog(constant($syslog_level),$data);
    closelog();
}

function buildConf($conf_file,$array_conf) {
    if (!file_exists($conf_file)) {
        $fp=@fopen($conf_file,"a+");
        foreach ($array_conf as $key=>$value) {
            if (is_array($value)) {
                fputs($fp,"[$key]\n");
                foreach($value as $subkey=>$subvalue) {
                    if (is_array($subvalue)) {
                        fputs($fp,"$key=\"".implode(',',$subvalue)."\"\n");
                    } else {
                        fputs($fp,"$subkey=\"$subvalue\"\n");
                    }
                }
            } else {
                fputs($fp,"$key=\"$value\"\n");
            }
        }
        fclose($fp);
        return true;
    } else {
        return false;
    }
}

function netRange($IP,$mask=24) {
    $classclong=ip2long($IP)&~((1<<(32-$mask))-1);
    return long2ip($classclong);
}

function mailHeaderEncode($header,$charset='UTF-8') {
    if (!empty($header)) {
        return "=?".$charset."?B?".base64_encode($header)."?=";
    } else {
        return null;
    }
}

function sendMail($message,$subject,$addrs,$fromuser=__WARN_USER,$sysuser='madreport',$sysutil="/usr/sbin/sendmail -t",$contenttype="text/plain; charset=\"utf-8\""){
    global $debug_level;
    foreach ($addrs as $addr) {
        $messages ="To: $addr\n";
        $messages.="From: ".mailHeaderEncode($fromuser)." <$sysuser@localhost>\n";
        $messages.="Subject: ".mailHeaderEncode($subject)."\n";
        $messages.="MIME-version: 1.0\n";
        $messages.="Content-Type: $contenttype\n\n";
        $messages.=$message;
        $messages.=".";
        //system("echo '$message' | /usr/bin/mail -s '$subject' $addr -sendmail-option -F'$fromuser'",$stat);
        $command="echo '$messages' | $sysutil";
        system($command,$stat);
        DebugInfo(2,$debug_level,"[fun.sendMail]-[mail:$addr]-[from:$fromuser]");
    }
    return $stat;
}

function findString($orig_string,$tag1,$tag2=null) {
    $offset1=empty($tag1)?false:strpos($orig_string,$tag1);
    $offset2=empty($tag2)?false:strpos($orig_string,$tag2);
    if ($offset1===false && $offset2===false) {
        return $orig_string;
    } elseif ($offset1===false || $offset2===false) {
        return ($offset1===false)?substr($orig_string,0,$offset2):substr($orig_string,0,$offset1);
    } else {
        return ($offset1>$offset2)?substr($orig_string,0,$offset2):substr($orig_string,0,$offset1);
    }
}

function checkIp($ip){
    $arr=explode('.',$ip);
    if(count($arr) != 4){
        return false;
    }else{
        for($i = 0;$i < 4;$i++){
            if(($arr[$i] <'0') || ($arr[$i] > '255')){
                return false;
            }
        }
    }
    return true;
}

function whichCmd($confPath,$command) {
    if (!is_file($confPath)) {
        @exec("which {$command}",$info,$status);
        if ($status==0) {
            $confPath=is_file($info[0])?$info[0]:$confPath;
        }
    }
    return $confPath;
}

function isFreeBSD() {
    @exec('uname -a',$info,$status);
    if ($status==0) {
        if ( strstr(strtolower($info[0]),'freebsd') ) {
            return true;
        }
    }
    return false;
}
?>
