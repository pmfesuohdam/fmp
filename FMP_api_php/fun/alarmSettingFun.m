<?php
/*
  +----------------------------------------------------------------------+
  | Name: alarmSettingFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理报警设置的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 11:52:37
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

//合法的json上传key
$valid_key = array(
    'current_engine',
    'all_default_gp_down',
    'all_cust_gp_down',
    'one_default_gp_down',
    'one_cust_gp_down',
    'one_default_server_down',
    'one_cust_server_down',
    'general_server_event',
    'recover_notifiction'
); 
switch($GLOBALS['operation']) {
case(__OPERATION_UPDATE): //更新操作 
    if($GLOBALS['selector'] == __SELECTOR_SINGLE && !empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST') { //要求上传数据非空和请求类型 
        if (!canAccess('update_alarmSet')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        //检查是否符合数据格式
        foreach($valid_key as $alarm_key) {
            if(!in_array($alarm_key,array_keys($_POST))) { //对少传判断为非法 
                $err=true;
            } else {
                $alarm_setting[$alarm_key] = $_POST[$alarm_key];
            } 
        } 
        //检查current_engine是否为空
        $err = $err==false? (!empty($alarm_setting['current_engine'])? false: true): true; 
        //回调检查所有秒数设置,除了第一个为字符串的
        $err = $err==false? (in_array(false,array_map("is_numeric",array_slice($alarm_setting, 1)))?true:false): true;
        if(!$err) { //没有错误则返回200 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_RESET_CONTENT;
            mdbUpdateAlarmSetting($alarm_setting); //更新MDB中相应的配置段落  
            mdbUpdateIni(); //更新MDB中的INI配置文本
        }
    }
    break;
case(__OPERATION_READ): //查询操作 
    if($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'GET') {
        if (!canAccess('read_alarmSet')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        $return_str = <<<EOT
{
  "current_engine": "{$_CONFIG['alarm_interval']['current_engine']}",
  "all_default_gp_down": {$_CONFIG['alarm_interval']['all_default_gp_down']},
  "all_cust_gp_down": {$_CONFIG['alarm_interval']['all_cust_gp_down']},
  "one_default_gp_down": {$_CONFIG['alarm_interval']['one_default_gp_down']},
  "one_cust_gp_down": {$_CONFIG['alarm_interval']['one_cust_gp_down']},
  "one_default_server_down": {$_CONFIG['alarm_interval']['one_default_server_down']},
  "one_cust_server_down": {$_CONFIG['alarm_interval']['one_cust_server_down']},
  "general_server_event": {$_CONFIG['alarm_interval']['general_server_event']},
  "recover_notifiction": {$_CONFIG['alarm_interval']['recover_notifiction']} 
}
EOT;
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //读取返回200 
        echo $return_str;
    }
    break;
}

?>
