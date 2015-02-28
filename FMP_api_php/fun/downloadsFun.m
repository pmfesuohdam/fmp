<?php
/*
  +----------------------------------------------------------------------+
  | Name:fun/downloadsFun.m                                                
  +----------------------------------------------------------------------+
  | Comment:download的数据的函数                                            
  +----------------------------------------------------------------------+
  | Author:evoup                                                         
  +----------------------------------------------------------------------+
  | Created:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-05-16 16:30:51
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus']=__HTTPSTATUS_OK;
$arr=explode('/',$_SERVER['REQUEST_URI']);
$version=$arr[1];
$host=$_SERVER['HTTP_HOST'];
header("Content-type: application/json; charset=utf-8");

$out=array(
    "madmonitor1.0-CentOS6.x-amd64.bin (MD5: 71b60ebe6716551073773be9fac79437)"=>"http://{$host}/{$version}/get/get_download_file/@self/madmonitor1.0-centos6.x-amd64.bin",
    "madmonitor1.0-FreeBSD7.x-amd64.bin (MD5: 61fb95b96e35e8f30a62ffd694715826)"=>"http://{$host}/{$version}/get/get_download_file/@self/madmonitor1.0-freebsd7.x-amd64.bin",
    "madmonitor1.0-FreeBSD8.x-amd64.bin (MD5: 4ef156ef3621b06f168ed4b07841d3e2)"=>"http://{$host}/{$version}/get/get_download_file/@self/madmonitor1.0-freebsd8.x-amd64.bin",
    "madmonitor1.0-FreeBSD9.x-amd64.bin (MD5: d958c70f955893564237d1c5de5548c2)"=>"http://{$host}/{$version}/get/get_download_file/@self/madmonitor1.0-freebsd9.x-amd64.bin"
);
echo json_encode($out);
?>
