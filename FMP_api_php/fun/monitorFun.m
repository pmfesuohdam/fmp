<?php
/*
  +----------------------------------------------------------------------+
  | Name: monitorFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理监控设置的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified:
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus']=__HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

switch($GLOBALS['operation']) {
case(__OPERATION_READ):
    /* {{{  branch read 
     */
    if($_SERVER['REQUEST_METHOD'] == 'GET') {
        switch($GLOBALS['selector']){
        case(__SELECTOR_MASS):
            $return_str = <<<EOT
{
    "db1": [
        "11000",
        "210,13,108.121",
        1
    ],
    "msreport01": [
        "10001",
        "210,13.108.222",
        0
    ],
    "server35": [
        "11111",
        "172.16.27.35",
        1
    ]
}
EOT;
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo $return_str; 
            break;
        }
    }
    /*}}}*/
    break;
}

?>
