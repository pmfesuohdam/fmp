<?php
/*
  +----------------------------------------------------------------------+
  | Name:fbaccountFun.m
  +----------------------------------------------------------------------+
  | Comment:处理facebook帐号的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-04 11:11:49
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
if($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    if ($_SERVER['REQUEST_METHOD'] == 'GET') {
        switch($GLOBALS['operation']) {
        case(__OPERATION_DELETE):
            if (empty($_GET['delete_adaccount'])) {
                $msgs['err_msg'][]=array('delete_adaccount'=>'param delete_adaccount must not be empty');
            } else {
                include(dirname(__FILE__).'/../inc/conn.php');
                $query="select t1.fb_adaccount_id,t2.ad_account_name from t_relationship_fmp_fb as t1 inner join t_fb_account as t2 where t1.fmp_user_id='{$_SESSION['fmp_uid']}' and t1.fb_adaccount_id=t2.ad_account_id;";
                $rows=null;
                if ($result=$link->query($query)) {
                    while ($row=mysqli_fetch_assoc($result)) {
                        $rows[]=$row['fb_adaccount_id'];
                    }
                }
                if (!in_array($_GET['delete_adaccount'],$rows)) {
                    $msgs['err_msg'][]=array('delete_adaccount'=>'the ad account is not belong to you');
                } else {
                    $query2="delete a.*,b.* from t_fb_account a,t_relationship_fmp_fb b where a.ad_account_id={$_GET['delete_adaccount']} and a.ad_account_id=b.fb_adaccount_id;";
                    if (!$link->query($query2)) {
                        $msgs['err_msg'][]=array('delete_adaccount'=>'delete fail');
                    }
                }
            }
            if ( !isset($msgs['err_msg']) || empty($msgs['err_msg']) ) {
                $msgs['status']='true';
            } else {
                $msgs['status']='false';
            }
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo json_encode($msgs);
            break;
        case(__OPERATION_READ):
            $adaccounts['adaccounts']=null;
            include(dirname(__FILE__).'/../inc/conn.php');
            $query="select fb_adaccount_id from t_relationship_fmp_fb where fmp_user_id='{$_SESSION['fmp_uid']}';";
            if ( !($result=$link->query($query)) ) {
                $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
                echo json_encode(array('status'=>'false','system'=>__FMP_ERR_SELECT_ADACCOUNT));
                break;
            }
            while ($row=mysqli_fetch_assoc($result)) {
                $fb_adaccount_id=$row['fb_adaccount_id'];
                //获取广告帐号的详细数据
                //查出access_token
                $query1="select access_token from t_fb_account where ad_account_id='{$fb_adaccount_id}';";
                if ( !($result1=$link->query($query1)) ) {
                    $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
                    echo json_encode(array('status'=>'false','system'=>__FMP_ERR_SELECT_ACCTOK));
                    @mysqli_close($link);
                    break;
                }

                $row1=mysqli_fetch_assoc($result1);
                $act_url="https://graph.facebook.com/v2.2/act_{$fb_adaccount_id}?fields=name,currency,daily_spend_limit,account_status&access_token=".$row1['access_token'];
                $ret=file_get_contents($act_url);
                $ret=json_decode($ret,true);
                $adaccounts['adaccounts'][]=array(
                    'id'=>$fb_adaccount_id,
                    'name'=>$ret['name'],
                    'spent_sum'=>$ret['daily_spend_limit'],
                    'currency'=>$ret['currency'],
                    'status'=>$ret['account_status'],
                    'imported'=>0
                );
                $ALL_AD_ACCOUNTS[$fb_adaccount_id]=1;

            }
            //查询adaccount是否已经被导入
            $query2="SELECT fb_adaccount_id FROM t_relationship_fmp_fb WHERE imported=0 AND fb_adaccount_id IN(".join(',',array_keys($ALL_AD_ACCOUNTS)).");";
            $notImportAccounts=null;
            $result2=$link->query($query2);
            while ($row2=mysqli_fetch_assoc($result2)) {
                $notImportAccounts[]=$row2['fb_adaccount_id'];

            }
            @mysqli_close($link);
            $tempArr=$adaccounts['adaccounts'];
            for ($i=0;$i<sizeof($tempArr);$i++) {
                if (in_array($tempArr[$i]['id'],$notImportAccounts)) {
                    $adaccounts['adaccounts'][$i]['imported']=1;
                    //如果已经导入了，但是accesstoken过期，上面无法获取的话，前端要尽量显示，因为已经保存在数据库里了
                    if (empty($adaccounts['adaccounts'][$i]['name'])) {
                        include(dirname(__FILE__).'/../inc/conn.php');
                        $qid=intval($adaccounts['adaccounts'][$i]['id']);
                        $query3="select ad_account_name from t_fb_account where ad_account_id=\"{$qid}\" limit 1;";
                        if ($result3=$link->query($query3)) {
                            $row=mysqli_fetch_assoc($result3);
                            $adaccounts['adaccounts'][$i]['name']=$row['ad_account_name'];
                        }
                        @mysqli_close($link);
                    }
                }
            }

            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo json_encode($adaccounts);
            break;
        }
    }
}
?>
