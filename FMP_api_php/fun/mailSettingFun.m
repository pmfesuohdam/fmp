<?php
/*
  +----------------------------------------------------------------------+
  | Name: mailSettingFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理邮件设置的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 11:40:37
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
$err=false;

//合法的POST的key
$valid_key=array('send_mail_type', 'mail_from', 'sender_name', 'smtp_server', 'smtp_domain', 'smtp_port', 'smtp_username', 'smtp_password', 'smtp_auth'); 

switch($GLOBALS['operation']) {
case(__OPERATION_UPDATE): //更新操作 
    if($GLOBALS['selector'] == __SELECTOR_SINGLE && !empty($GLOBALS['postData']) && $_SERVER['REQUEST_METHOD'] == 'POST') { //要求上传数据非空和请求类型 
        if (!canAccess('update_emailSet')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        //检查是否符合数据格式
        foreach($valid_key as $mail_key) {
            if(!in_array($mail_key,array_keys($_POST))) { //对少传判断为非法 
                $err=true;
            } else {
                $mail_setting[$mail_key] = $_POST[$mail_key];
            } 
        } 
        $err=$err==false? (!empty($mail_setting['mail_from'])?false: true): true; //寄信人不为空 
        $err=$err==false? (!empty($mail_setting['sender_name'])?false: true): true; //发件人称谓不为空 
        $err=$err==false? (is_numeric($mail_setting['send_mail_type'])? false: true): true;
        $err=$err==false? (is_numeric($mail_setting['smtp_auth'])? false: true): true;
        $err=$err==false? (in_array($mail_setting['send_mail_type'], array(0, 1))? false: true): true; //检查发送邮件类型 
        $err=$err==false? (in_array($mail_setting['smtp_port'], range(0, 65536))? false: true): true; //检查smtp端口 
        $err=$err==false? (in_array($mail_setting['smtp_auth'], range(0, 1))? false: true): true; //检查是否使用SMTP认证 
        if(!$err) { //没有错误则返回200 
            $GLOBALS['httpStatus']=__HTTPSTATUS_RESET_CONTENT;
            mdbUpdateMailSetting($mail_setting); //更新MDB中相应的配置段落 
            mdbUpdateIni(); //更新MDB中的INI配置文本
        }
    }
    break;
case(__OPERATION_READ):
    if($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'GET') {
    if (!canAccess('read_emailSet')) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
        return;
    }
        $return_str = <<<EOT
{
  "send_mail_type": {$_CONFIG['general']['send_mail_type']},
  "mail_from": "{$_CONFIG['mail']['mail_from']}",
  "sender_name":"{$_CONFIG['mail']['sender_name']}",
  "smtp_server": "{$_CONFIG['general']['smtp_server']}",
  "smtp_domain": "{$_CONFIG['general']['smtp_domain']}",
  "smtp_port": {$_CONFIG['general']['smtp_port']},
  "smtp_username": "{$_CONFIG['general']['smtp_username']}",
  "smtp_password": "{$_CONFIG['general']['smtp_password']}",
  "smtp_auth": {$_CONFIG['general']['smtp_auth']} 
}
EOT;
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //读取返回200 
        echo ($return_str);
    }
    break;
}

?>
