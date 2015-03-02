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
  | Last-Modified: 2015-03-02 16:20:55
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
if($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    if ($_SERVER['REQUEST_METHOD'] == 'GET') {
        switch($GLOBALS['operation']) {
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
                    break;
                }

                $row1=mysqli_fetch_assoc($result1);
                //print_r($row1);
                $act_url="https://graph.facebook.com/v2.2/act_{$fb_adaccount_id}?fields=name,currency,daily_spend_limit,account_status&access_token=".$row1['access_token'];
                $ret=file_get_contents($act_url);
                $ret=json_decode($ret,true);
                //(
                    //[currency] => USD
                    //[daily_spend_limit] => 5000
                    //[account_status] => 1
                    //[account_id] => 1568648550045049
                    //[id] => act_1568648550045049
                //)
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
            //print_r($adaccounts['adaccounts']);
            $query2="SELECT fb_adaccount_id FROM t_relationship_fmp_fb WHERE imported=0 AND fb_adaccount_id IN(".join(',',array_keys($ALL_AD_ACCOUNTS)).");";
            //echo $query2;
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
                }
            }

            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo json_encode($adaccounts);
            break;
        }
    }
}
?>
