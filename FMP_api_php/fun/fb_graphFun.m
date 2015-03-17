<?php
/*
  +----------------------------------------------------------------------+
  | Name: fb_graphFun.m 
  +----------------------------------------------------------------------+
  | Comment: 通用的facebook graph接口代理，专门返回fb的数据
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-16 11:02:42
  +----------------------------------------------------------------------+
*/
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
if ($GLOBALS['selector'] == __SELECTOR_SINGLE) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ):
        if ($_SERVER['REQUEST_METHOD'] == 'POST') {
            $ret=null;
            $batchAccessArr=$_POST['batch'];
            $access_token=null;
            include(dirname(__FILE__).'/../inc/conn.php');
            $query="select access_token from t_fb_account where ad_account_id={$_SESSION['camp_edit']['step1']['billingAccount']} limit 1;";
            if ($result=$link->query($query)) {
                $row=mysqli_fetch_assoc($result);
                $access_token=$row['access_token'];
            }
            @mysqli_close($link);
            foreach($batchAccessArr as $batchAccessInfo) {
                list($req_method,$req_url)=array($batchAccessInfo['method'],$batchAccessInfo['url']);
                switch ($req_method){
                case("GET"):
                    $req_url="https://graph.facebook.com/v2.2/".$req_url."&access_token={$access_token}";
                    $ret[]=curlGet($req_url);
                    break;
                case("POST"):
                    //TODO
                    break;
                }
            }
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
            echo json_encode($ret);
        }
        break;
    }
}
