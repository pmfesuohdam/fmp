<?php
/*
  +----------------------------------------------------------------------+
  | Name:fun/fun.monitor.m                                               |
  +----------------------------------------------------------------------+
  | Comment:监控函数                                                     |
  +----------------------------------------------------------------------+
  | Author:Odin,Modified:Rhinux,Yinjia                                   |
  +----------------------------------------------------------------------+
  | Create:2009-09-17 10:48:09                                           |
  +----------------------------------------------------------------------+
  | Last Modified: 2013-07-30 16:21:02
  +----------------------------------------------------------------------+
*/
function checkService($port,$host=null,$service_name=null) {
    global $_expect;
    if (!isset($_printf)) $_printf="/usr/bin/printf";
    if (!isset($_nc)) $_nc="/usr/bin/nc";
    if (!isset($_grep)) $_grep="/usr/bin/grep";

    if (empty($host)) $host='127.0.0.1';
    $tried=0;
    while (!$chk && $tried<2) {
        //double check
        if ($service_name=='memcached') {
            $command_memcached="$_printf 'stats\\r\\n' | $_nc $host $port -w 2 | $_grep 'evictions'";
            unset($mcack_info);
            @exec($command_memcached,$mcack_info,$mcack_stats);
            $mcack_value=end(explode(" ",(trim($mcack_info[0]))));
            if (!$mcack_stats && $mcack_value=='0') {
                $chk=1; //返回状态为0，并且 evictions 数值为0 为正常
            } 
        } elseif ( strstr($service_name,'thriftServer') ) { //检查thrift的一连上去就断的状态
            /*{{{expect脚本，请勿缩进*/
            $expectShell=<<<EOT
#!{$_expect}
spawn telnet {$host} {$port}
set timeout  1
expect {
        "*Escape character is*" {
                exp_continue
        }
        "*Connection closed by foreign host*" {
                send "note: 1) detect a unsafe connection"
        }
}
expect {
        "*Connection closed by foreign host*" {
                send "note: 2) detect a unsafe connection"
        }
        send "\\003"
        exit
}
expect "*Connection closed by foreign host*"
send "note: 3) disconnect by client cause timeout or not immediately exit expect"
exit
expect eof

exit
expect eof
EOT;
            /*}}}*/
            $expectShellLocation=__PROC_ROOT."/work/_expectShell.exp";
            file_put_contents($expectShellLocation,$expectShell);
            chmod($expectShellLocation,'755');
            $res=shell_exec("{$_expect} {$expectShellLocation}");
            $lines=(array)explode("\n",$res);
            $lines=array_unique($lines);
            array_pop($lines);
            $chk=strstr(end($lines),"Connection closed by foreign host")?false:true;
            $chk=$chk?fsockopen($host,$port,$errno,$errstr,2):false;
        } else {
            $chk = fsockopen($host,$port,$errno,$errstr,2);
        }
        $tried++;
    }
    if (!$chk) {
        fclose($chk);
        unset($chk);
        if ($service_name=='thriftServer') {
            echo "detect a unsafe thriftServer connection,telnet lost connections immediately!\n";
        }
        return false;
    } else {
        if ($service_name=='memcached') {
            unset($chk);
            return true;
        }else {
            fclose($chk);unset($chk);
        return true;
        }
    }
}

function stringToArray($string,$stag='|') {
    $ret=array();
    $orig_array=explode($stag,$string);
    foreach ($orig_array as $value) {
        $ret[]=trim($value);
    }
    return $ret;
}
?>
