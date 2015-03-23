<?php
/*
  +----------------------------------------------------------------------+
  | Name:syncFun.m
  +----------------------------------------------------------------------+
  | Comment:同步facebook广告帐号数据的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-23 14:16:17
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
if($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    if ($_SERVER['REQUEST_METHOD'] == 'GET') {
        switch($GLOBALS['operation']) {
        case(__OPERATION_READ):
            //adaccount必须存在且属于当前用户
            if (empty($_GET['sync_adaccount'])) {
                $msgs['err_msg'][]=array('sync_adaccount'=>'param sync_adaccount must not be empty');
            } else {
                include(dirname(__FILE__).'/../inc/conn.php');
                $query="select t1.fb_adaccount_id,t2.ad_account_name from t_relationship_fbaccount as t1 inner join t_fb_account as t2 where t1.fmp_user_id='{$_SESSION['fmp_uid']}' and t1.fb_adaccount_id=t2.ad_account_id;";
                $rows=null;
                if ($result=$link->query($query)) {
                    while ($row=mysqli_fetch_assoc($result)) {
                        $rows[]=$row['fb_adaccount_id'];
                    }
                }
                if (!in_array($_GET['sync_adaccount'],$rows)) {
                    $msgs['err_msg'][]=array('sync_adaccount'=>'the ad account is not belong to you');
                } else {
                    $query2="update t_fb_account set want_sync=1 where ad_account_id={$_GET['sync_adaccount']} limit 1;";
                    if (!$link->query($query2)) {
                        $msgs['err_msg'][]=array('sync_adaccount'=>'set sync flag fail');
                    }
                }
                @mysqli_close($link);
            }
            if ( !isset($msgs['err_msg']) || empty($msgs['err_msg']) ) {
                $msgs['status']='true';
            } else {
                $msgs['status']='false';
            }
                $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo json_encode($msgs);
            break;
        }
    }
}
?>
