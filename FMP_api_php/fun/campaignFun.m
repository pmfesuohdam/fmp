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
  | Last-Modified: 2015-03-04 17:02:24
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
            $adaccounts=null;
            $adaccounts[]=array('id'=>12,'name'=>'duang','selected'=>'');
            $adaccounts[]=array('id'=>13,'name'=>'wakaka','selected'=>'true');
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
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        }
        break;
    }
}

?>
