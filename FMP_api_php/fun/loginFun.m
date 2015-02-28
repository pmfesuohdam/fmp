<?php
/*
  +----------------------------------------------------------------------+
  | Name: loginFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理登录的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-02-28 13:37:28
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

if($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ):
        if ($_SERVER['REQUEST_METHOD'] == 'GET') {
            if (!empty($_SESSION['username'])) {
                $msgs['username']=$_SESSION['username'];
                $msgs['status']='true';
                $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
                echo json_encode($msgs);
            }
        }
        break;
    case(__OPERATION_UPDATE):
        /* {{{ 登录处理
         */
        $msgs=array(); //返回的消息
        $err_item=array();
        //已经登录的
        //{"status":"true"};
        //如果有问题的话
        //{"err_msg":[{"字段名":"错误消息"},{"字段名":"错误消息"}],"status":"false"}
        if ($_SERVER['REQUEST_METHOD'] == 'POST') {
            $row=null;
            //email需要满足格式，长度最少6，最大50,不为空，数据库中有
            if (empty($_POST['email'])) {
                $err_item['email']='email must be not empty';
                $msgs['err_msg'][]=$err_item;
            } else if (!filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
                $err_item['email']='email format err';
                $msgs['err_msg'][]=$err_item;
            } else if (strlen($_POST['email'])<6 || strlen($_POST['email'])>50 ) {
                $err_item['email']='email size must between 6 and 50';
                $msgs['err_msg'][]=$err_item;
            } else {
                $link= mysqli_init();
                $link->options(MYSQLI_OPT_CONNECT_TIMEOUT, 8);
                $link->real_connect(__DB_MYSQL_HOST, __DB_MYSQL_USER, __DB_MYSQL_PASS, __DB_MYSQL_DB);
                $link->query("SET NAMES utf8");
                $query="select name,passwd from `".__TB_FMP_USER."` where email='".$_POST['email']."';";
                $result=$link->query($query);
                if ( !($row = mysqli_fetch_assoc($result)) ) {
                    $err_item['email']='user not exists';
                    $msgs['err_msg'][]=$err_item;
                }
            }

            //password需要满足长度最少6，最大20,不为空,如果用户民存在要检查密码匹配
            if (empty($_POST['passwd'])) {
                $err_item['passwd']='password must be not empty';
                $msgs['err_msg'][]=$err_item;
            } else if (strlen($_POST['passwd'])<6 || strlen($_POST['passwd'])>20 ) {
                $err_item['passwd']='password size must between 6 and 20';
                $msgs['err_msg'][]=$err_item;
            } else {
                if ( !empty($row) ) {
                    if (md5($_POST['passwd'])!=$row['passwd']) {
                        $err_item['passwd']='passwd wrong';
                        $msgs['err_msg'][]=$err_item;
                    }
                }
            }
        }
        /* }}} */
        if ( !isset($msgs['err_msg']) || empty($msgs['err_msg']) ) {
            $msgs['status']="true";
            $_SESSION['username']=$row['name'];
        } else $msgs['status']="false";
        $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        echo json_encode($msgs);
        break;
    case(__OPERATION_DELETE):
        /* {{{ 退出登录
         */
        if ($_SERVER['REQUEST_METHOD']=='GET') {
            session_destroy();
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            $msgs['status']='true';
            echo json_encode($msgs);
        }
        /* }}} */
        break;
    }
}

?>
