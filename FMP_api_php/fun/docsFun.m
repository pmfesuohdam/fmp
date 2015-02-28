<?php
/*
  +----------------------------------------------------------------------+
  | Name:fun/statusUnitFun.m                                                
  +----------------------------------------------------------------------+
  | Comment:处理statusUnit的函数                                            
  +----------------------------------------------------------------------+
  | Author:evoup                                                         
  +----------------------------------------------------------------------+
  | Created:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-05-16 15:38:29
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus']=__HTTPSTATUS_OK;
$arr=explode('/',$_SERVER['REQUEST_URI']);
$version=$arr[1];
$host=$_SERVER['HTTP_HOST'];
header("Content-type: application/json; charset=utf-8");

$out=array(
    "MonitorCore1.0AlarmDescription.pdf"=>"http://{$host}/{$version}/get/get_download_file/@self/MonitorCore1.0AlarmDescription.pdf"
);
echo json_encode($out);
?>
