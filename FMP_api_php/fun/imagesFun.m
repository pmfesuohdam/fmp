<?php
/*
  +----------------------------------------------------------------------+
  | Name:imagesFun.m
  +----------------------------------------------------------------------+
  | Comment:广告物料显示的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2015-03-31 15:41:20
  +----------------------------------------------------------------------+
  | Last-Modified: 2015-04-01 16:58:18
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
        __SELECTOR_PRODUCT5,
        __SELECTOR_MASS
    )
)) {
/*{{{如果是获取图片的路径*/
    switch($GLOBALS['operation']) {
    case(__OPERATION_READ):
        if ($_SERVER['REQUEST_METHOD']=='GET'){
            include(dirname(__FILE__).'/../inc/conn.php');
            $query=<<<EOT
SELECT a.content FROM t_fmp_material a INNER JOIN t_fmp_user_material b 
    WHERE b.fmp_user_id{$_SESSION[__SESSION_FMP_UID]}
    AND a.fmp_hash=b.fmp_material_hash;
EOT;
            $result=$link->query($query);
            if ( !($row = mysqli_fetch_assoc($result)) ) {
                $msgs['err_msg'][]=array('billingAccount'=>'billingAccount not exists');
            }
            @mysqli_close($link);
            $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        }
        break;
    }
/*}}}*/
} else {
/*{{{如果是根据url获取图片*/
    $arrPathInfo=parse_url($_SERVER['REQUEST_URI']);
    $qs=$arrPathInfo['path'];
    $qs=explode('/',$arrPathInfo['path']);
    $fileName=array_pop($qs);
    $info=pathinfo($fileName);
    $hash=$info['filename'];
    $tail=array_pop($qs);
    $head=array_pop($qs);
    if (strlen($hash)!=32) {
        //不是md5 32位啊
    } elseif(!in_array(strtolower($info['extension']),array('gif','png','jpg','jpeg'))) {
        ////扩展名不对吧
    } elseif(GetMaterialPath($hash)!="{$head}/{$tail}") {
        //路径不对吧
    } else {
        //出图
        include(dirname(__FILE__).'/../inc/conn.php');
        $query="select content,mime from t_fmp_material where fmp_hash='{$hash}' limit 1";
        $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        if ($result=$link->query($query)) {
            while ($row=mysqli_fetch_assoc($result)) {
                $content=$row['content'];
            }
        }
        @mysqli_close($link);
        @header("content-type: {$mime}");
        @header("content-length: ".strlen($content));
        echo $content;
    }
/*}}}*/
}
?>
