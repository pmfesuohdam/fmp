<?php
/*
  +----------------------------------------------------------------------+
  | Name:log.m
  +----------------------------------------------------------------------+
  | Comment:日志的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-12 16:23:27
  +----------------------------------------------------------------------+
*/
function addLog($log_type,$log_content){
    global $link;
    $query="insert into t_fmp_log(fmp_user_id,log_type,content) values({$_SESSION[__SESSION_FMP_UID]},{$log_type},\"".safeAddSlashes(json_encode($log_content))."\");";
    $link->query($query);
}
?>
