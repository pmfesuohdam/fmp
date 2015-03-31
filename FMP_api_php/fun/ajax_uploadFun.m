<?php
/*
  +----------------------------------------------------------------------+
  | Name: ajax_uploadFun.m
  +----------------------------------------------------------------------+
  | Comment:接收物料上传的api
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2015-03-30 17:47:34
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-03-31 16:52:06
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");


if( in_array(
    $GLOBALS['selector'], array(
        __SELECTOR_PRODUCT1,
        __SELECTOR_PRODUCT2,
        __SELECTOR_PRODUCT3,
        __SELECTOR_PRODUCT4,
        __SELECTOR_PRODUCT5)
    )) {
    switch($GLOBALS['operation']) {
    case(__OPERATION_CREATE):
        $tempFile = $_FILES['Filedata']['tmp_name'];
        $fileContent=file_get_contents($tempFile);
        $fileSize=$_FILES['Filedata']['size'];
        $fileTypes = array('jpg','jpeg','gif','png'); // File extensions
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
        $fileParts = pathinfo($_FILES['Filedata']['name']);
        $imgInfo=getimagesize($_FILES['Filedata']['tmp_name']);
        if (!isset($imgInfo['mime']) || !in_array($imgInfo['mime'],array('image/gif','image/jpeg','image/png','image/pjpeg','image/x-png'))) {
            $msgs['err_msg']='Not valid image.';
        } elseif (!in_array($fileParts['extension'],$fileTypes)) {
            $msgs['err_msg']='Not png,gif,jpeg';
        } elseif ($fileSize>2097152) {
            $msgs['err_msg']='Size large than 2M limit';
        } else {
            //upload
            include(dirname(__FILE__).'/../inc/conn.php');
            $imgHash=md5($fileContent);
            $imgWidth=$imgInfo[0];
            $imgHeight=$imgInfo[1];
            $imgMime=$imgInfo['mime'];
            $content=addslashes($fileContent);
            if ($imgWidth<458 || $imgHeight<458) {
                $msgs['err_msg']='Image dimensions should be equal or greater than 458x458px';
            } else {
                $link->query("SET AUTOCOMMIT=0");
                $link->query("BEGIN");
                $query=<<<EOT
INSERT INTO t_fmp_material(fmp_hash,content,img_width,img_height,mime,filesize,create_time) 
    VALUES('{$imgHash}','{$content}',{$imgWidth},{$imgHeight},'{$imgMime}',{$fileSize},now()) 
    ON DUPLICATE KEY UPDATE update_time=now();
EOT;
                if ( !($link->query($query)) ) {
                    $msgs['err_msg']='system error:'.__FMP_ERR_UPDATE_MATERIAL;
                    $link->query("ROOLBACK");
                } else {
                    $query2=<<<EOT
INSERT INTO t_fmp_user_material(fmp_user_id,fmp_material_hash)
    VALUES({$_SESSION[__SESSION_FMP_UID]},'{$imgHash}') 
    ON DUPLICATE KEY UPDATE update_time=now();
EOT;
                    if ( !($link->query($query2)) ) {
                        $msgs['err_msg']='system error:'.__FMP_ERR_UPDATE_USER_MATERIAL;
                        $link->query("ROOLBACK");
                    } else {
                        $link->query("COMMIT") or $msgs['err_msg']='system error:'.__FMP_ERR_COMMIT_MATERIAL_UPLOAD;
                    }
                }
            }
        }
        @mysqli_close($link);
        if ( !isset($msgs['err_msg']) || empty($msgs['err_msg']) ) {
            $msgs['url']=GetMaterialPath($imgHash)."/{$imgHash}.";
            $msgs['status']='true';
        } else {
            $msgs['status']='false';
        }
        $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        echo json_encode($msgs);
        break;
    }
}
?>
