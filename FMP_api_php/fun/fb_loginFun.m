<?php
/*
  +----------------------------------------------------------------------+
  | Name: fb_loginFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理facebook登录的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-02 01:42:14
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

if($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_UPDATE):
        /* {{{ facebook登录后的处理，主要是保存令牌下来
         */
        $msgs['err_msg']=array(); //返回的消息
        $err_item=null;
        $token=$_POST['ac'];
        if ( preg_match_all("/[a-zA-Z0-9]$/",$token,$match) ) {
        } else {
            $err_item['ac']='wrong format facebook access token';
            $msgs['err_msg'][]=$err_item;
        }
        if ( !isset($msgs['err_msg']) || empty($msgs['err_msg']) ) {
            $msgs['status']="true";
            //格式正确,再检查是否拥有广告账号
            $ret=file_get_contents('https://graph.facebook.com/v2.2/me/businesses?access_token='.$token);
            $ret=json_decode($ret,true);
            //存所有获取adaccount的数组
            $getAdAccuntsArr=$getAdAccuntsNameArr=null;
            if ( isset($ret['data']) && !empty($ret['data']) ) {
                foreach ($ret['data'] as $businessDetail) {
                    //捞到business的id之后，方可获取广告账号信息
                    $try4getadaccount=0;
                    $adaccounts_url='https://graph.facebook.com/v2.2/'.$businessDetail['id'].'?fields=adaccounts,name&access_token='.$token;
                    while ( $try4getadaccount<3 && !(isset($ret1['adaccounts']) && !empty($ret1['adaccounts'])) ) {
                        $ret1=json_decode(strval(file_get_contents($adaccounts_url)),true);
                        usleep(2000);
                        $try4getadaccount++;
                    }
                    if ( isset($ret1['adaccounts']) && !empty($ret1['adaccounts']) ) {
                        foreach ($ret1['adaccounts']['data'] as $adaccountDetail) {
                            $getAdAccuntsArr[$adaccountDetail['account_id']]=$adaccountDetail;
                            $getAdAccuntsNameArr[$adaccountDetail['account_id']]=$ret1['name'];
                        }
                    } else {
                        $msgs['business']='no ad account found under your facebook account!';
                    }
                    unset($try4getadaccount,$ret1);
                }
            } else {
                $msgs['business']='no business found under your facebook account!';
            }
            foreach ($getAdAccuntsArr as $adaccountDetail_id=>$adaccountDetail2) {
                $insert_detail=addslashes(json_encode($adaccountDetail2));
                $query=<<<EOT
            INSERT INTO `t_fb_account` (ad_account_name,ad_account_id,access_token,ad_account_detail) 
                VALUES ("{$getAdAccuntsNameArr[$adaccountDetail2['account_id']]}","{$adaccountDetail2['account_id']}","{$token}","{$insert_detail}")
                ON DUPLICATE KEY UPDATE 
                  ad_account_name="{$getAdAccuntsNameArr[$adaccountDetail2['account_id']]}",access_token="{$token}",ad_account_detail="{$insert_detail}",
                  update_time=now();
EOT;
                include(dirname(__FILE__).'/../inc/conn.php');
                if (!$link->query($query)) {
                    $msgs['err_msg']='Sorry, something we are disturbed.('.__FMP_ERR_UPDATE_ADACCOUNT.')';
                    $msgs['status']='false';
                    break;
                } else { //保存账号所属fmp用户关系 
                    $query=<<<EOT
INSERT INTO `t_relationship_fmp_fb` (fmp_user_id,fb_adaccount_id)
    VALUES ("10001","{$adaccountDetail2['account_id']}") 
    ON DUPLICATE KEY UPDATE 
      update_time=now();
EOT;
                    if (!$link->query($query)) {
                        $msgs['err_msg']='Sorry, something we are disturbed.('.__FMP_ERR_UPDATE_FMP_FB_REL.')';
                        $msgs['status']='false';
                        break;
                    }
                }
            } //end foreach
        } else $msgs['status']='false';
        echo json_encode($msgs);
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        break;
        /* }}} */
        /* {{{ 登录处理
         */
        $msgs['err_msg']=array(); //返回的消息
        $err_item=array();
        //已经登录的
        //{"status":"true"};
        //如果有问题的话
        //{"err_msg":[{"字段名":"错误消息"},{"字段名":"错误消息"}],"status":"false"}
        if ($_SERVER['REQUEST_METHOD'] == 'POST') {
            $row=null;
            //email需要满足格式，长度最少6，最大50,不为空，数据库中有
            $err_item=null;
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
            $err_item=null;
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
    }
}

?>
