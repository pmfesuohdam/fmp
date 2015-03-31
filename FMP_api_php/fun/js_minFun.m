<?php
/*
  +----------------------------------------------------------------------+
  | Name:js_minFun.m
  +----------------------------------------------------------------------+
  | Comment:server端合并js的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-04-01 00:58:49
  +----------------------------------------------------------------------+
 */
switch($GLOBALS['operation']) {
case(__OPERATION_READ):
    if ($_SERVER['REQUEST_METHOD'] == 'GET') {
        $jsFiles=explode(',',$_GET['f']);
        foreach($jsFiles as $jsFile) {
            if (file_exists(__WEBUI_ROOT."/{$jsFile}")){
                $minJs.="/*!\n* COMBINE:{$jsFile}\n*/\n".file_get_contents(__WEBUI_ROOT."/{$jsFile}");
            }
        }
        header("Content-type: application/x-javascript; charset=utf-8");
        echo $minJs;
        $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
    }
    break;
}
?>
