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
/*{{{发布广告第一步*/
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
                $selected=$_SESSION[__SESSION_CAMP_EDIT]['step1']['buyingType']==$buytype_name?true:false;
                $buyingType[]=array('value'=>$buytype_name,'text'=>$buytype_desc,'selected'=>$selected);
            }
            $objective=null;
            foreach($AD_TYPES as $adtype=>$adtype_desc){
                $selected=$_SESSION[__SESSION_CAMP_EDIT]['step1']['objective']==$adtype?true:false;
                $objective[]=array('value'=>$adtype,'text'=>$adtype_desc,'selected'=>$selected);
            }
            $ret=array(
                'billingAccount'=>$adaccounts,
                'campaignName'=>!empty($_SESSION[__SESSION_CAMP_EDIT]['step1']['campaignName'])?
                $_SESSION[__SESSION_CAMP_EDIT]['step1']['campaignName']:'',
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
/*}}}*/

/*{{{发布广告第二步*/
if ($GLOBALS['selector'] == __SELECTOR_STEP2) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ):
        if ($_SERVER['REQUEST_METHOD']=='GET'){
        }
        break;
    case(__OPERATION_UPDATE): //接受提交数据 
        if ($_SERVER['REQUEST_METHOD']=='POST'){
            $msgs=null;
            //google analytics选择，则必须ga_source，ga_medium，ga_name不为空，长度正常(100内)
            if (isset($_POST['ga_enable']) && $_POST['ga_enable']=='on') {
                $err_item=null;
                if (empty($_POST['ga_source'])) {
                    $err_item['ga_source']='google analytics source must be not empty';
                    $msgs['err_msg'][]=$err_item;
                } elseif(strlen($_POST['ga_source'])>100) {
                    $err_item['ga_source']='google analytics source is too long';
                    $msgs['err_msg'][]=$err_item;
                }
                $err_item=null;
                if(empty($_POST['ga_medium'])) {
                    $err_item['ga_medium']='google analytics medium musr be not empty';
                    $msgs['err_msg'][]=$err_item;
                } elseif(strlen($_POST['ga_medium'])>100) {
                    $err_item['ga_medium']='google analytics medium is too long';
                    $msgs['err_msg'][]=$err_item;
                }
                $err_item=null;
                if(empty($_POST['ga_name'])) {
                    $err_item['ga_name']='google analytics name musr be not empty';
                    $msgs['err_msg'][]=$err_item;
                } elseif(strlen($_POST['ga_name'])>100) {
                    $err_item['ga_name']='google analytics name is too long';
                    $msgs['err_msg'][]=$err_item;
                }
            }
            //sigmad tracking code选择，则必须sm_cvid不为空,长度正常(100内)
            if (isset($_POST['sm_enable']) && $_POST['sm_enable']=='on') {
                $err_item=null;
                if (empty($_POST['sm_cvid'])) {
                    $err_item['sm_cvid']='sigmad tracking code must be not empty';
                    $msgs['err_msg'][]=$err_item;
                } elseif(strlen($_POST['sm_cvid'])>100) {
                    $err_item['sm_cvid']='sigmad tracking code is too long';
                    $msgs['err_msg'][]=$err_item;
                }
            }
            //facebook convert pixel选择，则必须fb_cvpx不为空，长度正常(100内)
            if (isset($_POST['fb_enable']) && $_POST['fb_enable']=='on') {
                $err_item=null;
                if (empty($_POST['fb_cvpx'])) {
                    $err_item['fb_cvpx']='facebook convert pixel must be not empty';
                    $msgs['err_msg'][]=$err_item;
                } elseif(strlen($_POST['fb_cvpx'])>100) {
                    $err_item['fb_cvpx']='facebook convert pixel is too long(<100)';
                    $msgs['err_msg'][]=$err_item;
                }
            }
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
/*}}}*/

/*{{{发布广告第三步*/
if ($GLOBALS['selector'] == __SELECTOR_STEP3) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ):
        if ($_SERVER['REQUEST_METHOD']=='GET'){
            include(dirname(__FILE__).'/../inc/conn.php');
            $query="select * from t_fmp_template where fmp_user_id='{$_SESSION[__SESSION_FMP_UID]}';";
            $rows_template=null;
            if ($result=$link->query($query)) {
                while ($row=mysqli_fetch_assoc($result)) {
                    $theTemplate=$_SESSION[__SESSION_CAMP_EDIT]['step3']['last_template_id']==$row['id']?
                        array('id'=>$row['id'],'name'=>$row['name'],'selected'=>1):array('id'=>$row['id'],'name'=>$row['name'],'selected'=>0);
                    $rows_template[]=$theTemplate;
                }
            }
            @mysqli_close($link);
            $ret['fmptemplate']=$rows_template;
            $ret['fmplocation']=array();
            for ($i=0;$i<=100;$i++){
                $ret['age_from'][]=array("id"=>$i,"name"=>$i);
                $ret['age_to'][]=array("id"=>$i,"name"=>$i);
                $ret['age_from'][empty($_SESSION[__SESSION_CAMP_EDIT]['step3']['age_from'])?0:$_SESSION[__SESSION_CAMP_EDIT]['step3']['age_from']]['selected']=1;
                $ret['age_to'][empty($_SESSION[__SESSION_CAMP_EDIT]['step3']['age_to'])?0:$_SESSION[__SESSION_CAMP_EDIT]['step3']['age_to']]['selected']=1;
            }
            $age_intval_range=array(1,2,4,6,8,16);
            foreach($age_intval_range as $itv) {
                $ret['age_intval'][]=array('id'=>$itv,"name"=>$itv);
                $ret['age_intval'][empty($_SESSION[__SESSION_CAMP_EDIT]['step3']['age_intval'])?0:array_search($_SESSION[__SESSION_CAMP_EDIT]['step3']['age_intval'],$age_intval_range)]['selected']=1;
            }
            $ret['age_split']=($_SESSION[__SESSION_CAMP_EDIT]['step3']['age_split'])?1:0;
            $ret['gender'][]=array('id'=>0,'name'=>'all');
            $ret['gender'][]=array('id'=>1,'name'=>'male');
            $ret['gender'][]=array('id'=>2,'name'=>'female');
            if (empty($_SESSION[__SESSION_CAMP_EDIT]['step3']['gender'])) {
                $ret['gender'][0]['selected']=1;
            } else {
                $ret['gender'][$_SESSION[__SESSION_CAMP_EDIT]['step3']['gender']]['selected']=1;
            }
            $ret['gender_split']=($_SESSION[__SESSION_CAMP_EDIT]['step3']['gender_split'])?1:0;
            echo json_encode($ret);
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        }
        break;
    case(__OPERATION_UPDATE):
        if ($_SERVER['REQUEST_METHOD']=='POST'){
            $msgs=null;
            //save_template选择，则必须template_name长度不超过30个，且数据库中没有超过20个模板
            if (isset($_POST['save_template']) && $_POST['save_template']=='on') {
                $err_item=null;
                if (empty($_POST['template_name'])) {
                    $err_item['template_name']='template name must be not empty';
                    $msgs['err_msg'][]=$err_item;
                } elseif (strlen($_POST['template_name'])>30) {
                    $err_item['template_name']='template name is too long(<30)';
                    $msgs['err_msg'][]=$err_item;
                }
            }
            //age_from必须为0-100的数字,且必须不大于age_to,如果设置了age_to，必须设置age_from
            if (isset($_POST['age_to']) && !isset($_POST['age_from'])) {
                $msgs['err_msg'][]=array('age_from'=>'must set age from if set age to');
            } elseif (!in_array($age_from,range(0,100))) {
                $msgs['err_msg'][]=array('age_from'=>'age from must from 0 to 100');
            } elseif ($_POST['age_from']>$_POST['age_to']) {
                $msgs['err_msg'][]=array('age_from'=>'age from must less than age to');
            }
            //age_to必须为0-100的数字，且必须大于age_from,如果设置了age_from,必须设置age_to
            if (isset($_POST['age_from']) && !isset($_POST['age_to'])) {
                $msgs['err_msg'][]=array('age_to'=>'must set age to if set age from');
            } elseif(!in_array($age_to,range(0,100))) {
                $msgs['err_msg'][]=array('age_to'=>'age to must from 0 to 100');
            } elseif ($_POST['age_to']<$_POST['age_from']) {
                $msgs['err_msg'][]=array('age_to'=>'age to must large than age from');
            }
            //age_split选择，则必须age_intval不为空，且要在age_intval的范围里
            if (isset($_POST['age_split']) && $_POST['age_split']=='on') {
                if (!in_array($_POST['age_intval'],array(1,2,4,6,8,16))) {
                    $msgs['err_msg'][]=array('age_intval'=>'age intval must in 1,2,4,6,8,16');
                }
            }
            //gender必须为0,1,2，也就是all、male、female
            if (!isset($_POST['gender']) || !in_array($_POST['gender'],array(0,1,2))) {
                $msgs['err_msg'][]=array('gender'=>'gender must be type of all,male,female');
            }
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
/*}}}*/
?>
