<?php
/*
  +----------------------------------------------------------------------+
  | Name:sp_campaignsFun.m
  +----------------------------------------------------------------------+
  | Comment:切分广告活动的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2015-04-15 18:00:55
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-04-15 18:24:00
  +----------------------------------------------------------------------+
*/
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
if ($GLOBALS['selector'] == __SELECTOR_MASS) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ):
        if ($_SERVER['REQUEST_METHOD'] == 'GET') {
            $sp_camp_rows=getSplitedCampaigns();
            $ret=null;
            $ret['sp_camps']=$sp_camp_rows;
            $ret['status']="true";
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo json_encode($ret);
        }
        break;
    }
} 
?>
