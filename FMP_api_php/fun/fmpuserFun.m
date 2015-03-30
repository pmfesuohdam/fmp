<?php
/*
  +----------------------------------------------------------------------+
  | Name: fmpuserFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理fmp用户的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-02-28 04:51:20
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
$valid_key = array('realname', 'email', 'passwd', 'mailtype', 'desc');  //合法的POST的key 

switch ($GLOBALS['operation']) {
case(__OPERATION_READ): //查询操作 
    if ( in_array($GLOBALS['selector'], array(__SELECTOR_MASS,__SELECTOR_MASSMEMBER)) && 
        $_SERVER['REQUEST_METHOD'] == 'GET') {  //查询全部 
        //if ($GLOBALS['selector']==__SELECTOR_MASS && !canAccess('read_fmpuserList')) {
            //$GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            //return;
        //}
        /* {{{ 从MDB中获取全部用户
         */
        /* }}} */
        if (!$err) { 
            echo json_encode($str); //返回json 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //查询成功返回200 
        }
    }
    elseif ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'GET') {  //查询单个 
        if (!$err) {
            $str=array("username"=>"test","status"=>"true");
            echo json_encode($str); //返回json 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //查询成功返回200
        }
    }
    break;
}
?>
