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

function curlGet($url){
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HEADER, 1);
    $response = curl_exec($ch);
    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    //$header = substr($response, 0, $header_size);
    $body = substr($response, $header_size);
    return array($code,$body);
}

function curlPost(){
}

function checkDateMMDDYYYY($date){
    $date_regex = '/(0[1-9]|1[012])[- \/.](0[1-9]|[12][0-9]|3[01])[- \/.](19|20)\d\d/';
    $ret=preg_match($date_regex, $date)?true:false;
    return $ret;
}
?>
