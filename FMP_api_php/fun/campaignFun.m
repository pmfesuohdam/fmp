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
                $selected=($_SESSION[__SESSION_CAMP_EDIT]['step1']['billingAccount']==$adaccountInfo['id'])?true:false;
                $adaccounts[]=array('id'=>$adaccountInfo['id'],'name'=>$adaccountInfo['name'],'selected'=>"$selected");
            }
            $buyingType=null;
            foreach ($BYT_ARR as $buytype_name=>$buytype_desc){
                $selected=$_SESSION[__SESSION_CAMP_EDIT]['step1']['buyingType']==$buytype_name?"true":"false";
                $buyingType[]=array('value'=>$buytype_name,'text'=>$buytype_desc,'selected'=>$selected);
            }
            $objective=null;
            $objective[]=array('value'=>'1','text'=>'Multi-Product Ads(Website Clicks)','selected'=>'');
            $objective[]=array('value'=>'2','text'=>'News feed(Website Clicks)','selected'=>'true');
            $objective[]=array('value'=>'3','text'=>'Right-Hand Column(Website Clicks)','selected'=>'');
            $ret=array(
                'billingAccount'=>$adaccounts,
                'campaignName'=>!empty($_SESSION[__SESSION_CAMP_EDIT]['step1']['campaignName'])?
                $_SESSION[__SESSION_CAMP_EDIT]['step1']['campaignName']:'test camp',
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
            //campaignName要满足长度正常(70内),不为空,数据库中没有重复
            $err_item=null;
            if (empty($_POST['campaignName'])) {
                $err_item['campaignName']='campaign name must be not empty';
                $msgs['err_msg'][]=$err_item;
            } elseif(strlen($_POST['campaignName'])>70) {
                $err_item['campaignName']='campaign name is too long';
                $msgs['err_msg'][]=$err_item;
            }
            //buyingType要满足必须是合法的
            $err_item=null;
            if (!in_array($_POST['buyingType'],array(__BYT_CPC,__BYT_CPM,__BYT_OCPM,__BYT_CPA))) {
                $err_item['buyingType']='buying type is not valid';
                $msgs['err_msg'][]=$err_item;
            }
            //objective必须合法
            $err_item=null;
            if (!in_array($_POST['objective'],array(__OBJT_MULTI_PRODUCT,__OBJT_NEWSFEED,__OBJT_RIGHTCOL))) {
                $err_item['objective']='objective is not valid';
                $msgs['err_msg'][]=$err_item;
            }
            if ( !isset($msgs['err_msg']) || empty($msgs['err_msg']) ) {
                //没有问题就保存
                $_SESSION['camp_edit']['step1']=array(
                    'billingAccount'=>$_POST['billingAccount'],
                    'campaignName'=>$_POST['campaignName'],
                    'buyingType'=>$_POST['buyingType'],
                    'objective'=>$_POST['objective']
                );
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
