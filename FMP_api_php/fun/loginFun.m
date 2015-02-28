<?php
/*
  +----------------------------------------------------------------------+
  | Name: loginFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理登录的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified:
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
$ua = $_SERVER['HTTP_USER_AGENT']; //ua直接取php默认的 
$co = $_COOKIE[__CO_MMSUID];
$now = time();
$NotLogin  = false;

if($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ):
        /* {{{ 获取登录状态
         */
        empty($ua) && $NotLogin = true;
        if($co && !$NotLogin) { //sid存在 
            DebugInfo("[$moduleName][check sid][cookie exist]", 3);
            /* 判断sid有效 */
            $SidValid = true; //TODO sid的认证在这里 
            !$SidValid && $NotLogin  = true;
        } else { //sid不存在 
            $NotLogin = true;
        }
        if($NotLogin) { //未登录返回401 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_UNAUTHORIZED;
        } else { //已登录返回200 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        }
        /* }}} */
        break;
    case(__OPERATION_UPDATE):
        /* {{{ 登录处理
         */
        $NotLogin = true; //这里直接视为未登录,因为客户端已经通过GET得知登录状态，请求这里不再检测状态 
        if($NotLogin) {  
            /* {{{ 未登录则校验用户名密码和setcookie
             */
            $check_login = true;
            $valid_key = array('username', 'passwd'); //用户名密码必传 
            /* 检查是否符合上传数据格式 */
            foreach($valid_key as $login_key) {
                if(!in_array($login_key, array_keys($_REQUEST))) { //检查参数是否传满，对少传判断为非法 
                    $check_login = false;
                } else {
                    $login_info[$login_key] = $_REQUEST[$login_key];
                }
            }
            //检测用户名密码
            list($table_name, $row_key) = array(__MDB_TAB_USER, $login_info['username']); //以用户名为row_key 
            $res = $GLOBALS['mdb_client']->getRow($table_name, $row_key);
            $res = array_filter($res);
            $check_login = empty($res)? false: true;
            if($check_login) { //mdb中存在此用户名 
                $res = (array)$res[0];
                $real_password = $res['columns']['info:passwd']->value; //得到mdb中对应的密码 
                if($real_password!=$login_info['passwd']) {
                    $check_login = false;
                    DebugInfo("[$moduleName][check passwd:false]", 3);
                }  
            } else {
                DebugInfo("[$moduleName][check login:no this user]", 3);
            }
            if($check_login) { //用户名密码正确,setcookie 
                DebugInfo("[$moduleName][check user ok]", 3);
                $stag_base = MadUuid();
                $uid = MadidEncode($stag_base.$now);
                $mad_views = "";
                $ua_crc = sprintf("%010s",sprintf("%u",crc32(strtolower($ua))));
                $ui_cstring = "$stag_base,".get_encrypt($uid,0,0,0).",$ua_crc,$mad_views"; //cookie的值分四段 stag 加密的uid， ua的crc， mad_view XXX 第四段不要 
                $co_time = $_REQUEST['keeplogin']? 315360000: 1440; //保持登录则setcookie有效期为10年(864000*365)，否则24分钟(60*24) 
                setcookie(__CO_MMSUID, $ui_cstring, $now+$co_time, '/');
                setcookie(__CO_MMSUNAME, $login_info['username'], $now+$co_time, '/');
                $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
                break;
            } else { //用户名密码错误返回401 
                $GLOBALS['httpStatus'] = __HTTPSTATUS_UNAUTHORIZED;
            }
            /* }}} */
        } else { //已登录返回200 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        }
        /* }}} */
        break;
    case(__OPERATION_DELETE):
        /* {{{ 退出登录
         */
        setcookie(__CO_MMSUID,null,$now,'/');
        setcookie(__CO_MMSUNAME,null,$now,'/');
        $GLOBALS['httpStatus'] = __HTTPSTATUS_UNAUTHORIZED;
        /* }}} */
        break;
    }
}

/**
 *@brief 为uid预编码 
 */
function MadidEncode($mid,$pcode='0000') {
    $madid=$pcode.sprintf("%010s",sprintf("%u",crc32($mid)));
    return $madid;
}

/**
 *@brief 生成唯一标识
 */
function MadUuid() {
    if (function_exists('com_create_guid')) {
        return com_create_guid();
    }else{
        mt_srand((double)microtime()*10000);//optional for php 4.2.0 and up.
        $charid = strtoupper(md5(uniqid(rand(), true)));
        $hyphen = chr(45);// "-"
        $uuid = chr(123)// "{"
            .substr($charid, 0, 8).$hyphen
            .substr($charid, 8, 4).$hyphen
            .substr($charid,12, 4).$hyphen
            .substr($charid,16, 4).$hyphen
            .substr($charid,20,12)
            .chr(125);// "}"
        return md5($uuid);
    }
}

/**
 *brief 为cookie的value加密
 */
function get_encrypt($mobile,$uaid,$aid,$campid){
    $mobile2 = substr($mobile,-8,8);
    $mobile1 = substr($mobile,0,strlen($mobile)-8);
    $data=array($mobile1,$uaid,$aid,$campid,$mobile2);
    foreach($data as $value){
        $value = base_convert(strlen($value),10,36).base_convert($value,10,36);
        @$ret .= base_convert(strlen($value)+1,10,36).$value;
    }
    return base_convert(strlen($ret)+1,10,36).$ret;
}
?>
