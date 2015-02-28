<?php
/*
  +----------------------------------------------------------------------+
  | Name:testspeed_siteFun.m
  +----------------------------------------------------------------------+
  | Comment:测速统计的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:2012年 8月28日 星期二 15时58分58秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 16:32:58
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

//合法的json上传key
$valid_key = Array('url', 'type');
switch($GLOBALS['operation']) {
case(__OPERATION_CREATE):
    if($GLOBALS['selector'] == __SELECTOR_SINGLE && !empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST') { //要求上传数据非空和请求类型 
        if (!canAccess('create_site')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        //检查是否符合数据格式
        foreach ($valid_key as $site_key) {
            if ( !in_array($site_key,array_keys($_POST)) ) { //对少传判断为非法 
                $err=true;
            } else {
                $site_setting[$site_key] = $_POST[$site_key];
            } 
        } 
        if ( !$err )
            $site_setting['site']=$GLOBALS['rowKey'];
        do {
            $siteinfo_url=$conf['testspeed_api'].'create/testspeed_site/@self';
            $res=sockPost($siteinfo_url,$site_setting);
            $line=explode("\n",$res);
            list(,$statusCode,)=explode(' ',$line[0]);
            if ( empty($statusCode) || $statusCode!='201' ) {
                $err=true;
                break;
            }
            $GLOBALS['httpStatus'] = __HTTPSTATUS_CREATED;
        } while (!$err);
    }
    break;
case(__OPERATION_READ): //获取全部站点操作 
    DebugInfo("[testspeed][testspeed_api:{$conf['testspeed_api']}]", 3);
    if ( !$err ) {
        if (!canAccess('read_siteList')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        if ( $GLOBALS['selector'] == __SELECTOR_ALLSITE) {
            $siteinfo_url=$conf['testspeed_api'].'get/testspeed_site/@all';
            $res=file_get_contents($siteinfo_url);
            if ( !empty($res) ) {
                $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //读取返回200 
                echo $res;
                return;
            } else {
                $GLOBALS['httpStatus'] = __HTTPSTATUS_NO_CONTENT;
                return;
            }
        } elseif ($GLOBALS['selector'] == __SELECTOR_SINGLE_SITE) {
            $site_setting['site']=$GLOBALS['rowKey'];
            $err=empty($GLOBALS['rowKey'])?true:false;
            DebugInfo("[testspeed][err:$err]", 3);
            $fields_string='site='.urlencode($GLOBALS['rowKey']);
            $siteinfo_url=$conf['testspeed_api'].'get/testspeed_site/@self';
            $ch = curl_init(); 
            curl_setopt($ch, CURLOPT_URL,$siteinfo_url);
            curl_setopt($ch, CURLOPT_POST,1);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch, CURLOPT_HEADER, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS,$fields_string);
            $result = curl_exec($ch);
            $statusCode=curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            if ( $statusCode =='200' ) {
                $arr=explode("\r\n\r\n",$result,2);
                $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
                echo $arr[1];
            } else {
                $GLOBALS['httpStatus']=$statusCode;
            }
        }
    } 
    break;
case(__OPERATION_UPDATE):
    if($GLOBALS['selector'] == __SELECTOR_SINGLE_SITE && !empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST') { //要求上传数据非空和请求类型 
        if (!canAccess('update_site')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        $valid_key=Array('url','type'); // url,type必传，enable可传 
        //检查是否符合数据格式
        foreach ($valid_key as $site_key) {
            if ( !in_array($site_key,array_keys($_POST)) ) { //对少传判断为非法 
                $err=true;
            } else {
                $site_setting[$site_key] = $_POST[$site_key];
            } 
        } 
        if ( !$err && isset($_POST['enable']) ) {
            $site_setting['enable']=$_POST['enable'];
        }
        if ( !empty($GLOBALS['rowKey']) ) {
            $site_setting['site']=$GLOBALS['rowKey'];
        }
        if ( !$err ) {
            do {
                $siteinfo_url=$conf['testspeed_api'].'update/testspeed_site/@self';
                $res=sockPost($siteinfo_url,$site_setting);
                $line=explode("\n",$res);
                list(,$statusCode,)=explode(' ',$line[0]);
                if ( empty($statusCode) || $statusCode!='205' ) {
                    $err=true;
                    break;
                }
                break;
            } while (!$err);
        }
        if ( !$err ) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_RESET_CONTENT; // 修改成功返回205 
            return;
        } else {
            if ( !empty($statusCode) ) // 如果请求这步返回不成功则出它的状态码
                $GLOBALS['httpStatus'] = $statusCode;
        }
        // 其他就是400了
    }
    break;
case(__OPERATION_DELETE):
    $err = empty($GLOBALS['rowKey']) ? true : false;
    if ( !$err ) {
        if (!canAccess('delete_site')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        $site_setting['site']=$GLOBALS['rowKey'];
        $siteinfo_url=$conf['testspeed_api'].'delete/testspeed_site/@self';
        $res=sockPost($siteinfo_url,$site_setting);
        $line=explode("\n",$res);
        list(,$statusCode,)=explode(' ',$line[0]);
        $GLOBALS['httpStatus']=$statusCode;
        return;
    }
    break;
}

?>
