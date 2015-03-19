<?php
define(__MCD_CONNTIMEOUT, 3);
define(__MCD_UDPTIMEOUT,  1);
define(__METHOD_SET,      'set');
define(__METHOD_ADD,      'add');
define(__METHOD_GET,      'get');
define(__METHOD_DELETE,   'delete');
define(__METHOD_INCR,     'incr');

function _get_socket_local($socket_file) {
    $socket=@fsockopen($socket_file,0,$errno,$errstr);
    return $socket;
}

function _get_socket_udp($host,$port) {
    $socket=@fsockopen("udp://".$host,$port,$errno,$errstr,__MCD_CONNTIMEOUT);
    return $socket;
}

function _get_socket_tcp($host,$port) {
    $socket=@fsockopen($host,$port,$errno,$errstr,__MCD_CONNTIMEOUT);
    return $socket;
}

function _get_socket($host,$conntype='udp',$port='11211') {
    if ($conntype=='tcp') {
        return _get_socket_tcp($host,$port);
    } else {
        return _get_socket_udp($host,$port);
    }
}

function _make_request_id() {
    list($usec,$sec)=explode(" ",microtime());
    mt_srand((float)$sec+((float)$usec*100000));
    return chr(mt_rand(0,255)).chr(mt_rand(0,255));
}

function _make_udp_package($cmd,$sequence=0,$total_datagrams=1) {
    $package.=_make_request_id();
    $package.=chr(0).chr($sequence);
    $package.=chr(0).chr($total_datagrams);
    $package.=chr(0).chr(0);
    $package.=$cmd;
    return $package;
}

function _write_socket_udp($cmd,$socket,$method,$noreply=false,$retry=false) {
    if ($socket) {
        $msg=_make_udp_package($cmd);
        fwrite($socket,$msg);
        switch($method) {
        case __METHOD_SET:
            if ($noreply || 'STORED'==($buffer=substr(trim(fgets($socket,32)),8))) {  //8byte header
                return true;
            } else {
                return false;
            }
        case __METHOD_ADD:
            if ($noreply || 'STORED'==($buffer=substr(trim(fgets($socket,32)),8))) {
                return true;
            } else {
                return false;
            }
        case __METHOD_GET:
            $buffer=substr(trim(fgets($socket,512)),8);
            if ($buffer=='END' || $buffer=='ND' || $buffer=='D') {
                //'ND','D',是为了重试时候出现的小问题
                return null;
            } elseif (!empty($buffer)) {
                list($tag,$key,$flag,$bytes)=explode(' ',$buffer);
                if (is_numeric($bytes)) {
                    $res=trim(fgets($socket,$bytes+8));
                    fgets($socket,16);  //reach end
                    return $res;
                }
            }

            if (!$retry) {
                //获取失败可尝试再获取一次,2009-05-19 15:04:27 added by odin
                return _write_socket_udp($cmd,$socket,$method,false,true);
            }

            return false;
        case __METHOD_DELETE:
            if ($noreply || 'DELETED'==($buffer=substr(trim(fgets($socket,32)),8))) {
                return true;
            } else {
                return false;
            }
        case __METHOD_INCR:
            if ($noreply) {
                return true;
            } else {
                if (is_numeric($buffer=substr(trim(fgets($socket,32)),8))) {
                    return $buffer;
                } elseif ($buffer=='NOT_FOUND') {
                    return false;
                } else {
                    return null;
                }
            }
        }
    } else {
        return false;
    }
}

function _write_socket_tcp($cmd,$socket,$method,$noreply=false,$retry=false) {
    if ($socket) {
        fwrite($socket,$cmd);
        switch($method) {
        case __METHOD_SET:
            if ($noreply || 'STORED'==($buffer=trim(fgets($socket,32)))) {
                return true;
            } else {
                return false;
            }
        case __METHOD_ADD:
            if ($noreply || 'STORED'==($buffer=trim(fgets($socket,32)))) {
                return true;
            } else {
                return false;
            }
        case __METHOD_GET:
            $buffer=trim(fgets($socket,512));
            if ($buffer=='END') {
                return null;
            } elseif (!empty($buffer)) {
                list($tag,$key,$flag,$bytes)=explode(' ',$buffer);
                if (is_numeric($bytes) && $bytes>0) {
                    $res=trim(fgets($socket,$bytes+8));
                    fgets($socket,16);  //reach end
                    return $res;
                } else {
                    return null;
                }
            }

            if (!$retry) {
                //获取失败可尝试再获取一次,2009-05-19 15:04:27 added by odin
                return _write_socket_tcp($cmd,$socket,$method,false,true);
            }

            return false;
        case __METHOD_DELETE:
            if ($noreply || 'DELETED'==($buffer=trim(fgets($socket,32)))) {
                return true;
            } else {
                return false;
            }
        case __METHOD_INCR:
            if ($noreply) {
                return true;
            } else {
                $buffer=trim(fgets($socket,32));
                if (is_numeric($buffer)) {
                    return $buffer;
                } else {
                    return false;
                }
            }
        }
    } else {
        return false;
    }
}

function _set($key,$conntype,$socket,$data,$exptime,$noreply=true,$flag=0) {
    $len=strlen($data);
    $cmd =__METHOD_SET." $key $flag $exptime $len";
    $cmd.=($noreply)?" noreply\r\n":"\r\n";
    $cmd.="$data\r\n";
    if ($conntype=='udp') {
        return _write_socket_udp($cmd,$socket,__METHOD_SET,$noreply);
    } else {
        return _write_socket_tcp($cmd,$socket,__METHOD_SET,$noreply);
    }
}

function _add($key,$conntype,$socket,$data,$exptime,$noreply=false,$flag=0) {
    $len=strlen($data);
    $cmd =__METHOD_ADD." $key $flag $exptime $len";
    $cmd.=($noreply)?" noreply\r\n":"\r\n";
    $cmd.="$data\r\n";
    if ($conntype=='udp') {
        return _write_socket_udp($cmd,$socket,__METHOD_ADD,$noreply);
    } else {
        return _write_socket_tcp($cmd,$socket,__METHOD_ADD,$noreply);
    }
}

function _get($key,$conntype,$socket) {
    $cmd=__METHOD_GET." $key\r\n";
    if ($conntype=='udp') {
        return _write_socket_udp($cmd,$socket,__METHOD_GET);
    } else {
        return _write_socket_tcp($cmd,$socket,__METHOD_GET);
    }
}

function _delete($key,$conntype,$socket,$time=0,$noreply=true) {
    $cmd =__METHOD_DELETE." $key $time";
    $cmd.=($noreply)?" noreply\r\n":"\r\n";
    if ($conntype=='udp') {
        return _write_socket_udp($cmd,$socket,__METHOD_DELETE,$noreply);
    } else {
        return _write_socket_tcp($cmd,$socket,__METHOD_DELETE,$noreply);
    }
}

function _incr($key,$conntype,$socket,$value=null,$exptime=null,$noreply=false) {
    $value=empty($value)?1:$value;
    $exptime=($exptime===null)?86400:$exptime;
    $cmd =__METHOD_INCR." $key $value";
    $cmd.=($noreply)?" noreply\r\n":"\r\n";
    if ($conntype=='udp') {
        $res=_write_socket_udp($cmd,$socket,__METHOD_INCR,$noreply);
    } else {
        $res=_write_socket_tcp($cmd,$socket,__METHOD_INCR,$noreply);
    }
    if ($res!==false) {
        return $res;
    } else {
        _set($key,$conntype,$socket,$value,$exptime);
        return $value;
    }
}

function mcd_query($method,$socket,$key,$data=null,$exptime=300,$conntype='udp') {
    $mcd_methods=array(__METHOD_SET,__METHOD_ADD,__METHOD_GET,__METHOD_DELETE,__METHOD_INCR);
    $method=strtolower($method);
    $conntype=strtolower($conntype);
    if (!in_array($method,$mcd_methods)) {
        return false;
    }
    switch($method) {
        case __METHOD_GET:
            return _get($key,$conntype,$socket);
        case __METHOD_SET:
            return _set($key,$conntype,$socket,$data,$exptime);
        case __METHOD_ADD:
            return _add($key,$conntype,$socket,$data,$exptime);
        case __METHOD_INCR:
            return _incr($key,$conntype,$socket,$data,$exptime);
        case __METHOD_DELETE:
            return _delete($key,$conntype,$socket);
    }
}
?>
