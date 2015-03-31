<?php
/*
  +----------------------------------------------------------------------+
  | Name: ajax_uploadFun.m
  +----------------------------------------------------------------------+
  | Comment:接收物料上传的api
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2015-03-30 17:47:34
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-30 17:47:34
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");


if( in_array(
    $GLOBALS['selector'], array(
        __SELECTOR_PRODUCT1,
        __SELECTOR_PRODUCT2,
        __SELECTOR_PRODUCT3,
        __SELECTOR_PRODUCT4,
        __SELECTOR_PRODUCT5)
    )) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_CREATE):
        $tempFile = $_FILES['Filedata']['tmp_name'];
        //$fileTypes = array('jpg','jpeg','gif','png'); // File extensions
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        $fileParts = pathinfo($_FILES['Filedata']['name']);
        if (in_array($fileParts['extension'],$fileTypes)) {
            echo 1;
        } else {
            echo 'Invalid file type.';
        }
        break;
    }
}
?>
