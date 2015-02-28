<?php
/*
  +----------------------------------------------------------------------+
  | Name: fun/base.m                                                     |
  +----------------------------------------------------------------------+
  | Comment: 基础函数                                                    |
  +----------------------------------------------------------------------+
  | Author: Evoup                                                        |
  +----------------------------------------------------------------------+
  | Created: 2011-02-23 10:24:26                                         |
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-11-19 16:11:16
  +----------------------------------------------------------------------+
*/

/* {{{ 记录系统日志
 * @param   string  $data       log内容
 * @param   int     $level      log级别(与/etc/syslog.conf对应)  
 * @param   string  $tag        log标识
 * @param   string  $facility   log分类(与/etc/syslog.conf对应)
 *
 * @return  null
 */
function SaveSysLog($data,$level,$tag=__VERSION,$facility=__SYSLOG_FACILITY_API) {
    //define_syslog_variables();
    openlog('MMS-'.$tag,LOG_PID,constant($facility));
    syslog(constant($level),$data);
    closelog();
}
/* }}} */

/* {{{ debug函数
 * @param   string  $debugData      debug内容
 * @param   int     $debugLevel     debug级别
 * @param   string  $syslogLevel    debug对应系统日志的级别
 *
 * @return  null
 */
function DebugInfo($debugData,$debugLevel,$syslogLevel=__SYSLOG_LV_DEBUG) {
    if ($debugLevel<=$GLOBALS['debugLevel'] && !empty($debugData)) {
        if (!empty($GLOBALS['serviceName'])) {
            $debugData="[{$GLOBALS['serviceName']}] ".$debugData."::[{$GLOBALS['debugLevel']}][".__SUBVERSION."]";
        } else {
            $debugData.="::[{$GLOBALS['debugLevel']}][".__SUBVERSION."]";
        }
        if ($GLOBALS['debugOutput']) {
            printf("[%s]%s<br />",date('Y-m-d H:i:s'),$debugData);
        }
        SaveSysLog($debugData,$syslogLevel);
    }
}
/* }}} */

/* {{{ api执行函数
 */
function apiRun() {
    $errCode=NULL;
    //运行程序块
    $funcName=$GLOBALS['prefix'].ucfirst($GLOBALS['operation']);
    /* {{{ 登录状态判断和
     */
    $MTD=isset($_POST['snapshotid']) ?'snapshot' :$GLOBALS['serviceName']; 
    switch ($MTD) {
    default:
        if(empty($_COOKIE[__CO_MMSUID]) || empty($_COOKIE[__CO_MMSUNAME])) { //XXX 这里sid需要验证 
            if ($GLOBALS['prefix']==__PREFIX_LOGIN && $GLOBALS['selector']==__SELECTOR_SINGLE && $GLOBALS['operation']==__OPERATION_UPDATE) { // 不要阻断首页登录 
            } else {
                $GLOBALS['httpStatus'] = __HTTPSTATUS_UNAUTHORIZED; // 出错误状态码 
                ob_clean(); // 未认证删除任何要输出的内容后退出 
                mmsHeader();
                exit(0);
            }
        }
        break;
    }
    /* }}} */
    //输出结果
    outputResults($errCode);
}
/* }}} */

/* {{{ output函数,相当于view
 */
function outputResults($errCode,$encode='json') {

    //返回http状态码
    mmsHeader();

    if ($errCode!=0) {    //0都代表成功
        $errorFun=$GLOBALS['prefix'].'Error';
        if (!empty($errorFun) && function_exists($errorFun)) {
            //$funcName();
            call_user_func_array($errorFun,(array)$errCode);  // 比$funcName()稍慢,但是可读性高
        } else {
            DebugInfo("[fun.outputResults] [errorFun:$errorFun][function_not_exists]",2);
        }
    }

    $result=empty($GLOBALS['outputContent'])?array():$GLOBALS['outputContent'];
    if (!empty($result)) {  //result应该以一个数组传入
        if (!is_array($result)) $result=(array)$result;
        switch($encode) {   //暂时只支持json
        case 'json':
        default:
            header('Content-Type: application/json');
            $outputContent=json_encode($result);
            break;
        }
        echo $outputContent;
    }
}
/* }}} */

/* {{{ response header
 */
function mmsHeader() {
    $httpStatus=isset($GLOBALS['httpStatus'])?$GLOBALS['httpStatus']:__HTTPSTATUS_BAD_REQUEST;
    switch($httpStatus) {
    case __HTTPSTATUS_OK:
        $headerLine="HTTP/1.1 200 OK";
        break;
    case __HTTPSTATUS_CREATED:
        $headerLine="HTTP/1.1 201 Created";
        break;
    case __HTTPSTATUS_NO_CONTENT:
        $headerLine="HTTP/1.1 204 No Content";
        break;
    case __HTTPSTATUS_RESET_CONTENT:
        $headerLine="HTTP/1.1 205 Reset Content";
        break;
    case __HTTPSTATUS_BAD_REQUEST:
        $headerLine="HTTP/1.1 400 Bad Request";
        break;
    case __HTTPSTATUS_UNAUTHORIZED:
        $headerLine="HTTP/1.1 401 Unauthorized";
        break;
    case __HTTPSTATUS_FORBIDDEN:
        $headerLine="HTTP/1.1 403 Forbidden";
        break;
    case __HTTPSTATUS_NOT_FOUND:
        $headerLine="HTTP/1.1 404 Not Found";
        break;
    case __HTTPSTATUS_METHOD_NOT_ALLOWED:
        $headerLine="HTTP/1.1 405 Method Not Allowed";
        break;
    case __HTTPSTATUS_METHOD_CONFILICT:
        $headerLine="HTTP/1.1 409 Conflict";
        break;
    case __HTTPSTATUS_INTERNAL_SERVER_ERROR:
        $headerLine="HTTP/1.1 500 Internal Server Error";
        break;
    default:
        $headerLine="HTTP/1.1 400 Bad Request";
    }
    DebugInfo("[fun.mmsHeader] [httpStatus:$httpStatus][outputLine:$headerLine]",2);
    header($headerLine);
}
/* }}} */
?>
