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
  | Last-Modified: 2015-04-15 17:58:47
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
    global $conf;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HEADER, 1);
    curl_setopt($ch, CURLOPT_TIMEOUT,60);
    if ($conf['use_proxy']) {
        curl_setopt($ch, CURLOPT_PROXY, $conf['proxy_addr']); 
        //curl_setopt($ch, CURLOPT_HTTPPROXYTUNNEL, 1); 
        curl_setopt($ch, CURLOPT_PROXYTYPE, CURLPROXY_HTTP);
    }
    $response = curl_exec($ch);
    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    //$header = substr($response, 0, $header_size);
    $body = substr($response, $header_size);
    if ($conf['use_proxy']) {
        preg_match("/\r\n\r\n(.*)/",$body,$match);
        $body=$match[1];
    }
    return array($code,$body);
}

function curlPost(){
}

function checkDateMMDDYYYY($date){
    $date_regex = '/(0[1-9]|1[012])[- \/.](0[1-9]|[12][0-9]|3[01])[- \/.](19|20)\d\d/';
    $ret=preg_match($date_regex, $date)?true:false;
    return $ret;
}

function GetMaterialPath($md5checksum) {
    $head=sprintf("%04s",hexdec(substr($md5checksum, 0, 4)));
    $tail=sprintf("%04s",hexdec(substr($md5checksum, -4)));
    $path=substr($head, -2).'/'.substr($tail, -2);
    return $path;
}

function checkUrl($url) {
    return preg_match("/\b(?:(?:https?|ftp):\/\/|www\.)[-a-z0-9+&@#\/%?=~_|!:,.;]*[-a-z0-9+&@#\/%=~_|]/i",$url);
}

/** @检查图片hash是否属于当前用户所上传
 */
function checkImgHashPerm($img_hash){
    return true;
}

/** @brief 获取切分后的n个活动
  * @return arr 
  */
function getSplitedCampaigns(){
    global $OBJECTIVE_ARR;
    list($start_mon,$start_day,$start_year)=explode('/',$_SESSION[__SESSION_CAMP_EDIT]['step4']['schedule_start']);
    list($end_mon,$end_day,$end_year)=explode('/',$_SESSION[__SESSION_CAMP_EDIT]['step4']['schedule_end']);
    // 切分算法，如果有interval的，间隔的挖掉，用剩下的组成范围
    $demonsion=array(
        'age'=>null,
        'gender'=>null
    );
    $age_from=$_SESSION[__SESSION_CAMP_EDIT]['step3']['age_from'];
    $age_to=$_SESSION[__SESSION_CAMP_EDIT]['step3']['age_to'];
    $age_interval=$_SESSION[__SESSION_CAMP_EDIT]['step3']['age_split_interval'];
    if (!empty($_SESSION[__SESSION_CAMP_EDIT]['step3']['age_split']) && !empty($age_interval)){
        $dm_end=$dm_start=$age_from;
        for($i=$age_from;$i<=$age_to;null){
            $demonsion['age'][]=array('from'=>$i,'to'=>$i);
            $i+=$age_interval;
        }
    } else {
        $demonsion['age'][]=array('from'=>$age_from,'to'=>$age_to);
    }
    $gender=$_SESSION[__SESSION_CAMP_EDIT]['step3']['gender'];
    if (!empty($_SESSION[__SESSION_CAMP_EDIT]['step3']['gender_split'])) {
        $demonsion['gender'][]=__FMP_GENDER_ALL;
        $demonsion['gender'][]=__FMP_GENDER_MALE;
        $demonsion['gender'][]=__FMP_GENDER_FEMALE;
    } else {
        $demonsion['gender'][]=$gender;
    }

    $tblRowInfo=null;
    $tblRowInfo['campaign_name']=$_SESSION[__SESSION_CAMP_EDIT]['step1']['campaignName'];
    $tblRowInfo['delivery']=1;
    $tblRowInfo['start']="{$start_year}-{$start_mon}-{$start_day} 00:00:00";
    $tblRowInfo['end']="{$end_year}-{$end_mon}-{$end_day} 23:59:59";
    $tblRowInfo['objective']=$OBJECTIVE_ARR[$_SESSION[__SESSION_CAMP_EDIT]['step1']['objective']];
    $tblRowInfo['location']=$_SESSION[__SESSION_CAMP_EDIT]['step3']['location'];
    foreach($demonsion['age'] as $ageInfo){
        foreach($demonsion['gender'] as $gender){
            $tblRowInfo['age_from']=$ageInfo['from'];
            $tblRowInfo['age_to']=$ageInfo['to'];
            $tblRowInfo['gender']=$gender;
            $tblRowInfo['ad_set_name']="ag{$ageInfo['from']}-{$ageInfo['to']}_gd{$gender}";
            $publish_rows[]=$tblRowInfo;
        }
    }
    return $publish_rows;
}
?>
