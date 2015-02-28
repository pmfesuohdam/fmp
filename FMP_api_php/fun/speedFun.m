<?php
/*
  +----------------------------------------------------------------------+
  | Name:speedFun.m
  +----------------------------------------------------------------------+
  | Comment:测速统计的模块
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2012年 9月 4日 星期二 15时08分15秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 17:00:59
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400
header("Content-type: application/json; charset=utf-8");
//合法的json上传key
$valid_key = Array('start'); // start必须上传，end选传 
$err=false;
switch ( $GLOBALS['operation'] ) {
case(__OPERATION_READ):
    if ( $GLOBALS['selector'] == __SELECTOR_SINGLE && !empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST' ) { //要求上传数据非空和请求类型
        if (!canAccess('read_sitespeedSingle')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        //检查是否符合数据格式
        foreach ( $valid_key as $site_key ) {
            if ( !in_array($site_key,array_keys($_POST)) ) { //对少传判断为非法
                $err=true;
            }
        }
        if ( !$err && !empty($_POST['start']) ) {
            $speed_setting['date']=urlencode($_POST['start']);
        }
        if ( !$err && isset($_POST['end']) ) {
            $speed_setting['date'].=','.urlencode($_POST['end']);
        }
        if ( !$err ) {
            $speed_setting['site'].=urlencode($GLOBALS['rowKey']);
        }
        foreach ($speed_setting as $key=>$value) {
            $fields[]="{$key}={$value}";
        }
        $fields_string=join('&',$fields);
        $speed_url=$conf['testspeed_api'].'get/speed/@self';
        $ch = curl_init(); 
        curl_setopt($ch, CURLOPT_URL,$speed_url);
        curl_setopt($ch, CURLOPT_POST,count($fields));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HEADER, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS,$fields_string);
        curl_setopt($ch, CURLOPT_TIMEOUT, 20);
        $result = curl_exec($ch);
        $statusCode=curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ( $statusCode =='200' ) {
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            $arr=explode("\r\n\r\n",$result,2);
            echo $arr[1];
        } else {
            $GLOBALS['httpStatus']=$statusCode;
        }
        return;
    } elseif ( $GLOBALS['selector'] == __SELECTOR_MASS && !empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST' ) {
        if (!canAccess('read_sitespeedList')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        //检查是否符合数据格式
        foreach ( $valid_key as $site_key ) {
            if ( !in_array($site_key,array_keys($_POST)) ) { //对少传判断为非法
                $err=true;
            }
        }
        if ( !$err && !empty($_POST['start']) ) {
            $speed_setting['date']=urlencode($_POST['start']);
        }
        if ( !$err && isset($_POST['end']) ) {
            $speed_setting['date'].=','.urlencode($_POST['end']);
        }
        foreach ($speed_setting as $key=>$value) {
            $fields[]="{$key}={$value}";
        }
        $fields_string=join('&',$fields);
        $speed_url=$conf['testspeed_api'].'get/speed/@all';
        $ch = curl_init(); 
        curl_setopt($ch, CURLOPT_URL,$speed_url);
        curl_setopt($ch, CURLOPT_POST,count($fields));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HEADER, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS,$fields_string);
        $result = curl_exec($ch);
        $statusCode=curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ( $statusCode =='200' ) {
            $arr=explode("\r\n\r\n",$result,2);
            $json=$arr[1];
        } else {
            $GLOBALS['httpStatus']=$statusCode;
            return;
        }
        $arr=json_decode($json);
        if (empty($arr)) {
            $GLOBALS['httpStatus']=__HTTPSTATUS_NO_CONTENT;
        } else {
            foreach ( (array)$arr as $date => $sitesInfo ) {
                foreach ( (array)$sitesInfo as $site => $speedInfo ) {
                    $allSite[$site]['average_time'][$date]=($speedInfo->lspeed+$speedInfo->hspeed)/2;
                    $allSite[$site]['lspeed'][$date]=$speedInfo->lspeed;
                    $allSite[$site]['hspeed'][$date]=$speedInfo->hspeed;
                    $allSite[$site]['test_time'][$date]=1;
                }
            }
            foreach ( array_keys($allSite) as $site ) {
                $ret[$site]['average_time']=sprintf('%01.3f',10/array_sum($allSite[$site]['average_time'])/count($allSite[$site]['average_time']));
                $ret[$site]['lspeed']=sprintf('%01.3f',array_sum($allSite[$site]['lspeed'])/count($allSite[$site]['lspeed']));
                $ret[$site]['hspeed']=sprintf('%01.3f',array_sum($allSite[$site]['hspeed'])/count($allSite[$site]['hspeed']));
                $ret[$site]['test_time']=array_sum($allSite[$site]['test_time'])/count($allSite[$site]['test_time']);
            }
            unset($allSite);
            echo json_encode($ret);
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        }
        return;
    } 
    break;
}
?>
