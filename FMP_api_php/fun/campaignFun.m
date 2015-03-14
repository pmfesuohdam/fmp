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
  | Last-Modified: 2015-03-10 18:28:15
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
                $msgs['err_msg'][]=array('billingAccount'=>'billing account must be not empty');
            } elseif(!filter_var(intval($_POST['billingAccount']),FILTER_VALIDATE_INT)) {
                $msgs['err_msg'][]=array('billingAccount'=>'billing account must be integer');
            } elseif(strlen($_POST['billingAccount'])>20) {
                $msgs['err_msg'][]=array('billingAccount'=>'billing account is too long');
            } else {
                include(dirname(__FILE__).'/../inc/conn.php');
                $query="select * from t_fb_account where ad_account_id={$_POST['billingAccount']};";
                $result=$link->query($query);
                if ( !($row = mysqli_fetch_assoc($result)) ) {
                    $msgs['err_msg'][]=array('billingAccount'=>'billingAccount not exists');
                    @mysqli_close($link);
                }
            }
            @mysqli_close($link);
            //campaignName要满足长度正常(70内),不为空,数据库中没有重复
            $err_item=null;
            if (empty($_POST['campaignName'])) {
                $msgs['err_msg'][]=array('campaignName'=>'campaign name must be not empty');
            } elseif(strlen($_POST['campaignName'])>70) {
                $msgs['err_msg'][]=array('campaignName'=>'campaign name is too long');
            }
            //buyingType要满足必须是合法的
            $err_item=null;
            if (!in_array($_POST['buyingType'],array(__BYT_CPC,__BYT_CPM,__BYT_OCPM,__BYT_CPA))) {
                $msgs['err_msg'][]=array('buyingType'=>'buying type is not valid');
            }
            //objective必须合法
            $err_item=null;
            if (!in_array($_POST['objective'],array(__OBJT_MULTI_PRODUCT,__OBJT_NEWSFEED,__OBJT_RIGHTCOL))) {
                $msgs['err_msg'][]=array('objective'=>'objective is not valid');
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
                    $msgs['err_msg'][]=array('ga_source'=>'google analytics source must be not empty');
                } elseif(strlen($_POST['ga_source'])>100) {
                    $msgs['err_msg'][]=array('ga_source'=>'google analytics source is too long');
                }
                $err_item=null;
                if(empty($_POST['ga_medium'])) {
                    $msgs['err_msg'][]=array('ga_medium'=>'google analytics medium musr be not empty');
                } elseif(strlen($_POST['ga_medium'])>100) {
                    $msgs['err_msg'][]=array('ga_medium'=>'google analytics medium is too long');
                }
                $err_item=null;
                if(empty($_POST['ga_name'])) {
                    $msgs['err_msg'][]=array('ga_name'=>'google analytics name musr be not empty');
                } elseif(strlen($_POST['ga_name'])>100) {
                    $msgs['err_msg'][]=array('ga_name'=>'google analytics name is too long');
                }
            }
            //sigmad tracking code选择，则必须sm_cvid不为空,长度正常(100内)
            if (isset($_POST['sm_enable']) && $_POST['sm_enable']=='on') {
                $err_item=null;
                if (empty($_POST['sm_cvid'])) {
                    $msgs['err_msg'][]=array('sm_cvid'=>'sigmad tracking code must be not empty');
                } elseif(strlen($_POST['sm_cvid'])>100) {
                    $msgs['err_msg'][]=array('sm_cvid'=>'sigmad tracking code is too long');
                }
            }
            //facebook convert pixel选择，则必须fb_cvpx不为空，长度正常(100内)
            if (isset($_POST['fb_enable']) && $_POST['fb_enable']=='on') {
                $err_item=null;
                if (empty($_POST['fb_cvpx'])) {
                    $msgs['err_msg'][]=array('fb_cvpx'=>'facebook convert pixel must be not empty');
                } elseif(strlen($_POST['fb_cvpx'])>100) {
                    $msgs['err_msg'][]=array('fb_cvpx'=>'facebook convert pixel is too long(<100)');
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
            $ret['fmplocation']=array();
            if (!empty($_GET['template_id'])){
                $selected_tmplid=intval($_GET['template_id']);
                $fmp_loc_dic=include(dirname(__FILE__).'/../inc/location_map.php');
                $qTemplateId=empty($selected_tmplid)?$_SESSION[__SESSION_CAMP_EDIT]['step3']['last_template_id']:$selected_tmplid;
                $query="select location from t_fmp_template where fmp_user_id='{$_SESSION[__SESSION_FMP_UID]}' and id={$qTemplateId} limit 1;";
                if ($result=$link->query($query)) {
                    $row=mysqli_fetch_assoc($result);
                    $tmpArr=explode('|',$row['location']);
                    foreach ($tmpArr as $loc) {
                        $ret['fmplocation'][]=$fmp_loc_dic[$loc];
                    }
                }
            } else {
                foreach((array)explode('|',$_SESSION[__SESSION_CAMP_EDIT]['step3']['location']) as $lc){
                    $fmp_loc_dic=include(dirname(__FILE__).'/../inc/location_map.php');
                    $locArr[]=$fmp_loc_dic[$lc];
                }
                $ret['fmplocation']=$locArr;
            }
            @mysqli_close($link);
            $ret['sel_fmptemplate']=$rows_template;
            for ($i=0;$i<=100;$i++){
                if ($_SESSION[__SESSION_CAMP_EDIT]['step3']['age_to']==$i) {
                    $ret['age_to'][]=array("id"=>$i,"name"=>$i,"selected"=>"selected");
                } else {
                    $ret['age_to'][]=array("id"=>$i,"name"=>$i);
                }
                if ($_SESSION[__SESSION_CAMP_EDIT]['step3']['age_from']==$i) {
                    $ret['age_from'][]=array("id"=>$i,"name"=>$i,"selected"=>"selected");
                } else {
                    $ret['age_from'][]=array("id"=>$i,"name"=>$i);
                }
            }
            $age_split_intval_range=array(1,2,4,6,8,16);
            foreach($age_split_intval_range as $itv) {
                if ($_SESSION[__SESSION_CAMP_EDIT]['step3']['age_split_intval']==$itv) {
                    $ret['age_split_intval'][]=array('id'=>$itv,"name"=>$itv,'selected'=>'selected');
                } else {
                    $ret['age_split_intval'][]=array('id'=>$itv,"name"=>$itv);
                }
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
            $STEP3_SAVE_DATA=array(
                'name'=>'','age_from'=>0,'age_to'=>0,'age_split'=>0,'age_split_intval'=>0,'gender'=>0,''=>0,'location'=>''
            );
            //sel_fmptemplate选择，必须id存在且属于当前用户
            if (!empty($_POST['sel_fmptemplate'])) {
                include(dirname(__FILE__).'/../inc/conn.php');
                $query="select count(*) from t_fmp_template where fmp_user_id={$_SESSION[__SESSION_FMP_UID]} and id=".intval($_POST['sel_fmptemplate']).";";
                if ($result=$link->query($query)) {
                    $row=mysqli_fetch_assoc($result); 
                    $row['count(*)']==0 && $msgs['err_msg'][]=array('sel_fmptemplate'=>'template id not exist');
                }
                @mysqli_close($link);
            }
            //save_template选择，则必须template_name长度不超过30个，且数据库中没有超过20个模板
            if (isset($_POST['save_template']) && $_POST['save_template']=='on') {
                $err_item=null;
                if (empty($_POST['template_name'])) {
                    $msgs['err_msg'][]=array('template_name'=>'template name must be not empty');
                } elseif (strlen($_POST['template_name'])>30) {
                    $msgs['err_msg'][]=array('template_name'=>'template name is too long(<30)');
                } else {
                    include(dirname(__FILE__).'/../inc/conn.php');
                    $query="select count(*) from t_fmp_template where fmp_user_id={$_SESSION[__SESSION_FMP_UID]} limit 1;";
                    if ($result=$link->query($query)) {
                        $row=mysqli_fetch_assoc($result); 
                        if ($row['count(*)']>__FMP_MAX_USER_TMPL) {
                            $msgs['err_msg'][]=array('template_name'=>'reaching  max owned '.__FMP_MAX_USER_TMPL.' templates' );
                        } else {
                            $STEP3_SAVE_DATA['name']=$_POST['template_name'];
                        }
                    }
                    @mysqli_close($link);
                }
            }
            //country如果输入了，必须属于已经定义的国家
            if (isset($_POST['fmplocation']) && !empty($_POST['fmplocation']) ) {
                $upload_country=array_filter(array_unique((array)explode('|',$_POST['fmplocation'])));
                if (!empty($upload_country)) {
                    $fmp_loc_dic=include(dirname(__FILE__).'/../inc/location_map.php');
                    foreach($upload_country as $country) {
                        if (!in_array($country,array_values($fmp_loc_dic))) {
                            $msgs['err_msg'][]=array('fmplocation'=>"location({$country}) not exist");
                            break;
                        } else {
                            $STEP3_SAVE_DATA['location'][]=array_search($country,$fmp_loc_dic);
                        }
                    }
                }
                $STEP3_SAVE_DATA['location']=join('|', $STEP3_SAVE_DATA['location']);
            }
            //age_from必须为0-100的数字,且必须不大于age_to,如果设置了age_to，必须设置age_from
            if (isset($_POST['age_to']) && !isset($_POST['age_from'])) {
                $msgs['err_msg'][]=array('age_from'=>'must set age from if set age to');
            } elseif (!in_array($age_from,range(0,100))) {
                $msgs['err_msg'][]=array('age_from'=>'age from must from 0 to 100');
            } elseif ($_POST['age_from']>$_POST['age_to']) {
                $msgs['err_msg'][]=array('age_from'=>'age from must less than age to');
            } else {
                $STEP3_SAVE_DATA['age_from']=intval($_POST['age_from']);
            }
            //age_to必须为0-100的数字，且必须大于age_from,如果设置了age_from,必须设置age_to
            if (isset($_POST['age_from']) && !isset($_POST['age_to'])) {
                $msgs['err_msg'][]=array('age_to'=>'must set age to if set age from');
            } elseif(!in_array($age_to,range(0,100))) {
                $msgs['err_msg'][]=array('age_to'=>'age to must from 0 to 100');
            } elseif ($_POST['age_to']<$_POST['age_from']) {
                $msgs['err_msg'][]=array('age_to'=>'age to must large than age from');
            } else {
                $STEP3_SAVE_DATA['age_to']=intval($_POST['age_to']);
            }
            //age_split选择，则必须age_split_intval不为空，且要在age_split_intval的范围里
            if (isset($_POST['age_split']) && $_POST['age_split']=='on') {
                if (!in_array($_POST['age_split_intval'],array(1,2,4,6,8,16))) {
                    $msgs['err_msg'][]=array('age_split_intval'=>'age intval must in 1,2,4,6,8,16');
                } else {
                    $STEP3_SAVE_DATA['age_split']=1;
                    $STEP3_SAVE_DATA['age_split_intval']=intval($_POST['age_split_intval']);
                }
            }
            //gender必须为0,1,2，也就是all、male、female
            if (!isset($_POST['gender']) || !in_array($_POST['gender'],array(0,1,2))) {
                $msgs['err_msg'][]=array('gender'=>'gender must be type of all,male,female');
            }
            $STEP3_SAVE_DATA['gender']=intval($_POST['gender']);
            
            //gender_spli选择，直接过
            $STEP3_SAVE_DATA['gender_split']=(isset($_POST['gender_split']) && $_POST['gender_split']=='on')?1:0;
            if ( !isset($msgs['err_msg']) || empty($msgs['err_msg']) ) {
                $msgs['status']="true";
                //没有错误保存数据
                if (!empty($STEP3_SAVE_DATA['name'])) {
                    include(dirname(__FILE__).'/../inc/conn.php');
                    $query="insert into t_fmp_template(fmp_user_id,name,age_from,age_to,age_split,age_split_intval,gender,gender_split,location) values ({$_SESSION[__SESSION_FMP_UID]},'{$STEP3_SAVE_DATA['name']}',{$STEP3_SAVE_DATA['age_from']},{$STEP3_SAVE_DATA['age_to']},{$STEP3_SAVE_DATA['age_split']},{$STEP3_SAVE_DATA['age_split_intval']},{$STEP3_SAVE_DATA['gender']},{$STEP3_SAVE_DATA['gender_split']},'{$STEP3_SAVE_DATA['location']}') on duplicate key update age_from={$STEP3_SAVE_DATA['age_from']},age_to={$STEP3_SAVE_DATA['age_to']},age_split={$STEP3_SAVE_DATA['age_split']},age_split_intval={$STEP3_SAVE_DATA['age_split_intval']},gender={$STEP3_SAVE_DATA['gender']},gender_split={$STEP3_SAVE_DATA['gender_split']},location='{$STEP3_SAVE_DATA['location']}';";
                    if (!$link->query($query)) {
                        addLog(__FMP_LOGTYPE_ERROR,array('run query error'=>$query));
                        $msgs['err_msg'][]=Array('system'=>'Sorry, something we are disturbed.('.__FMP_ERR_UPDATE_TEMPLATE.')');
                        $msgs['status']='false';
                    } else {
                        $_SESSION[__SESSION_CAMP_EDIT]['step3']['last_template_id']=mysqli_insert_id($link);
                    }
                    @mysqli_close($link);
                }
                $_SESSION[__SESSION_CAMP_EDIT]['step3']['age_from']=$STEP3_SAVE_DATA['age_from'];
                $_SESSION[__SESSION_CAMP_EDIT]['step3']['age_to']=$STEP3_SAVE_DATA['age_to'];
                $_SESSION[__SESSION_CAMP_EDIT]['step3']['age_split']=$STEP3_SAVE_DATA['age_split'];
                $_SESSION[__SESSION_CAMP_EDIT]['step3']['age_split_intval']=$STEP3_SAVE_DATA['age_split_intval'];
                $_SESSION[__SESSION_CAMP_EDIT]['step3']['gender']=$STEP3_SAVE_DATA['gender'];
                $_SESSION[__SESSION_CAMP_EDIT]['step3']['gender_split']=$STEP3_SAVE_DATA['gender_split'];
                $_SESSION[__SESSION_CAMP_EDIT]['step3']['location']=$STEP3_SAVE_DATA['location'];
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
