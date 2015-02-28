<?php
/*
  +----------------------------------------------------------------------+
  | Name:generic_setting.m
  +----------------------------------------------------------------------+
  | Comment:常规设置函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 11:35:22
  +----------------------------------------------------------------------+
 */

$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; // 默认返回400 
header("Content-type: application/json; charset=utf-8");
$err = false;

switch ($GLOBALS['operation']) {
case(__OPERATION_READ):
    /* {{{ 读取常规设置
     */
    $GLOBALS['selector'] != __SELECTOR_SINGLE && $err = true; 
    if (!canAccess('read_generalSet')) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
        return;
    }
    list($sendHour, $sendMin, $sendSec) = explode(':', $_CONFIG['general']['send_daily_mail_time']);
    $sendHour = intval($sendHour);
    $sendMin = intval($sendMin);
    $sendSec = intval($sendSec);
    if (!$err) {
        $str = <<<EOT
{
    "engine": {
        "watchdogUrl": "{$_CONFIG['general']['watchdog_url']}"
    },
    "client": {
        "sleepSecPerReq": {$_CONFIG['general']['client_sleep_time']},
        "keepAliveOvertimeSec":{$_CONFIG['general']['down_over_time']} 
    },
    "daily": {
        "sendMail": {$_CONFIG['general']['send_daily_mail']},
        "sendHour": {$sendHour},
        "sendMin": {$sendMin},
        "sendSec": {$sendSec} 
    }
}
EOT;
    }
    if (!$err) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        echo $str;
    }
    /* }}} */
    break;
case(__OPERATION_UPDATE):
    /* {{{ 更新常规设置
     */
    if (!canAccess('update_generalSet')) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
        return;
    }
    // 合法的POST的key
    $valid_key = array('watchdogUrl','sleepSecPerReq', 'sendMail', 'sendHour', 'sendMin', 'sendSec'); 
    // 检查是否符合数据格式
    foreach ($valid_key as $generial_key) {
        if (!in_array($generial_key, array_keys($_POST))) { // 对少传判断为非法 
            $err = true;
        } else {
            switch ($generial_key) { // 客户端需求设计的时候上传的参数没有设计一致，转换下 
            case('watchdogUrl'):
                $generial_setting['watchdog_url'] = urldecode($_POST[$generial_key]);
                break;
            case('sleepSecPerReq'):
                $generial_setting['client_sleep_time'] = intval($_POST[$generial_key]);
                break;
            case('sendMail'):
                $generial_setting['send_daily_mail'] = $_POST[$generial_key];
                break;
            default:
                $generial_setting[$generial_key] = intval($_POST[$generial_key]);
                break;
            }
        } 
    } 
    // watchdog的url需要符合HTTP或者HTTPS的格式
    if (!$err && !preg_match('/(http|https):\/\/[\w.]+[\w\/]*[\w.]*\??[\w=&\+\%]*/is',$generial_setting['watchdog_url'])) {
        $err=true;
    }
    $generial_setting['send_daily_mail'] = empty($generial_setting['send_daily_mail']) ?__GENERIAL_SETTING_SENDDAILYMAIL_NO :__GENERIAL_SETTING_SENDDAILYMAIL_YES;
    $err = $err==false ?(!empty($generial_setting['client_sleep_time']) && intval($generial_setting['client_sleep_time'])>0 ?false :true) :true; // 客户端请求间隔秒数不为空
    $err = $err==false ?(in_array($generial_setting['sendHour'], (array)range(0, 23)) ?false :true) :true;
    $err = $err==false ?(in_array($generial_setting['sendMin'], (array)range(0, 59)) ?false :true) :true;
    $err = $err==false ?(in_array($generial_setting['sendSec'], (array)range(0, 59)) ?false :true) :true;
    $generial_setting['send_daily_mail_time'] = intval($generial_setting['sendHour']).":".$generial_setting['sendMin'].":".$generial_setting['sendSec'];
    $generial_setting['version']=$conf['version'];
    if (!$err) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_RESET_CONTENT;
        mdbUpdateGenerialSetting($generial_setting); // 更新MDB中相应的配置段落 
        mdbUpdateIni(); // 更新MDB中的INI配置文本
    }
    /* }}} */
    break;
}
?>
