<?php
/*
  +----------------------------------------------------------------------+
  | Name: campaignFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理campaign的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-04 23:36:11
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
if ($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ):
        if ($_SERVER['REQUEST_METHOD'] == 'GET') {
            $ret=null;
            $ret['status']="true";
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo json_encode($ret);
        }
        break;
    }
} 

//TODO 做完第一步就可以分一分文件了
//发布广告第一步
if ($GLOBALS['selector'] == __SELECTOR_STEP1) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ): //发送当前保存的数据 
        if ($_SERVER['REQUEST_METHOD']=='GET'){
            include(dirname(__FILE__).'/../inc/conn.php');
            $query="select t1.fb_adaccount_id,t2.ad_account_name from t_relationship_fmp_fb as t1 inner join t_fb_account as t2 where t1.fmp_user_id='{$_SESSION['fmp_uid']}' and t1.fb_adaccount_id=t2.ad_account_id;";
            $rows=null;
            if ($result=$link->query($query)) {
                while ($row=mysqli_fetch_assoc($result)) {
                    $rows[]=array('id'=>$row['fb_adaccount_id'],'name'=>$row['ad_account_name']);
                }
            }
            @mysqli_close($link);
            $adaccounts=null;
            foreach($rows as $adaccountInfo) {
                $adaccounts[]=array('id'=>$adaccountInfo['id'],'name'=>$adaccountInfo['name'],'selected'=>'');
            }
            $buyingType=null;
            $buyingType[]=array('value'=>'cpc','text'=>'CPC(Pay for Clicks)','selected'=>'');
            $buyingType[]=array('value'=>'cpm','text'=>'CPM(Pay for impressions)','selected'=>'true');
            $buyingType[]=array('value'=>'ocpm','text'=>'OCPM(Optimize for clicks)','selected'=>'');
            $objective=null;
            $objective[]=array('value'=>'1','text'=>'Multi-Product Ads(Website Clicks)','selected'=>'');
            $objective[]=array('value'=>'2','text'=>'News feed(Website Clicks)','selected'=>'true');
            $objective[]=array('value'=>'3','text'=>'Right-Hand Column(Website Clicks)','selected'=>'');
            $ret=array(
                'billingAccount'=>$adaccounts,
                'campaignName'=>'test camp',
                'buyingType'=>$buyingType,
                'objective'=>$objective
            );
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo json_encode($ret);
        }
        break;
    case(__OPERATION_UPDATE): //接受提交数据 
        if ($_SERVER['REQUEST_METHOD']=='POST'){
            //billing account需要满足格式，是数字，不为空，长度正常(70内)，数据库中有
            //TODO 还要检查billing是否属于本帐号!注意安全，稍后加上
            $err_item=null;
            $msgs=null;
            if (empty($_POST['billingAccount'])) {
                $err_item['billingAccount']='billing account must be not empty';
                $msgs['err_msg'][]=$err_item;
            } elseif(!filter_var(intval($_POST['billingAccount']),FILTER_VALIDATE_INT)) {
                $err_item['billingAccount']='billing account must be integer';
                $msgs['err_msg'][]=$err_item;
            } elseif(strlen($_POST['billingAccount'])>20) {
                $err_item['billingAccount']='billing account is too long';
                $msgs['err_msg'][]=$err_item;
            } else {
                include(dirname(__FILE__).'/../inc/conn.php');
                $query="select * from t_fb_account where ad_account_id={$_POST['billingAccount']};";
                $result=$link->query($query);
                if ( !($row = mysqli_fetch_assoc($result)) ) {
                    $err_item['billingAccount']='billingAccount not exists';
                    $msgs['err_msg'][]=$err_item;
                    @mysqli_close($link);
                }
            }
            @mysqli_close($link);
            $err_item=null;
            if ( !isset($msgs['err_msg']) || empty($msgs['err_msg']) ) {
                $msgs['status']="true";
            } else {
                $msgs['status']="false";
            }
            echo json_encode($msgs);
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        }
        break;
    }
}

?>
