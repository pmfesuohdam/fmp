<?php
/*
  +----------------------------------------------------------------------+
  | Name:mdndeliver_settingFun.m
  +----------------------------------------------------------------------+
  | Comment:MDN的deliver内部接口管理模块
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:2012年 4月23日 星期一 16时22分52秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 16:01:13
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; // 默认返回400 
header("Content-type: application/json; charset=utf-8");
switch ($GLOBALS['operation']) {
case(__OPERATION_READ):
    if (!canAccess('read_madnManagement')) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
        return;
    }
    /*{{{从MWS_USER和MWS_MSS_BUCKET表中获取用户数据*/
    // 取出全部用户的设置 // TODO 加try 
    $result=$GLOBALS['mdb_client']->scannerOpen(__MDB_TAB_MWS_USER, "", (array)'property');
    while (true) {
        $record = $GLOBALS['mdb_client']->scannerGet($result);
        if ($record == NULL) {
            break;
        }
        foreach($record as $TRowResult) {
            $row = $TRowResult->row; // rowKey为用户 
            $col=$TRowResult->columns;
            $enable=$col['property:status']->value==1?1:0;
            /////////////////获取拥有的bucket///////////////////
            $result2=$GLOBALS['mdb_client']->scannerOpen(__MDB_TAB_MDNDELIVER_BUCKET, "", (array)"index:O:{$row}");
            while (true) {
                $record2 = $GLOBALS['mdb_client']->scannerGet($result2);
                if ($record2 == NULL) {
                    break;
                }
                foreach($record2 as $TRowResult2) {
                    $buckets[]=$TRowResult2->row;
                }
            }
            ////////////////////////////////////////////////////
            try {
                $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_MWS_USER, $row,array('security:'));
                foreach ($arr[0]->columns as $colName=>$colInfo) {
                    if (substr($colName,0,strlen('security:KP:'))=='security:KP:') {
                        $secretKeyId = substr($colName,strlen('security:KP:'));
                    } else {
                        throw new Exception('keyPair not found');
                    }
                    $secretKey=$colInfo->value;
                }
            }
            catch (Exception $e) {
                $GLOBALS['httpStatus']=__HTTPSTATUS_BAD_REQUEST;
                DebugInfo("[keyPair not found]", 3);
                return;
            }
            $column = $TRowResult->columns;
            $user[$row]=array($enable,join('|',$buckets),$secretKeyId, $secretKey);
            unset($buckets);
        }
    }
    /*}}}*/
    $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
    echo json_encode($user);
    break;
case(__OPERATION_UPDATE):
    if (!canAccess('update_madnManagement')) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
        return;
    }
    /* {{{ 获取原先保存的全部用户
     */
    $result=$GLOBALS['mdb_client']->scannerOpen(__MDB_TAB_MWS_USER, "", array('index','property','security','groupid'));
    while (true) {
        $record = $GLOBALS['mdb_client']->scannerGet($result);
        if ($record == NULL) {
            break;
        }
        foreach($record as $TRowResult) {
            $row = $TRowResult->row; // rowKey为用户 
            $column = $TRowResult->columns;
            $prevUser[$row]=1;
        }
    }
    /* }}} */
    $user=base64_decode($_POST['data']);
    DebugInfo("[base64_encode:$user]", 3);
    $user=str_replace(array("\n","\r\n"),'',$user);
    $userArr=array_filter((array)explode(';',$user));
    foreach($userArr as $line) {
        list($user,$enable,$bucketsStr,$skid,$sk)=explode(',',$line);
        $buckets=explode('|',$bucketsStr);
        foreach ($buckets as $bk) {
            $bucketArr[$bk]=1;
        }
        $uArr[$user]=1;
        $skidArr[$skid]=1;
        $skArr[$sk]=1;
        if (!empty($user) && in_array($enable,array(0,1)) && !empty($buckets) && !empty($skid) && !empty($sk)) {
            $checkOk=true;
    } else {
        DebugInfo("[check false 0][line:$line][user:$user][enable:$enable][bucket:$bucketsStr][skid:$skid][sk:$sk]", 3);
        $checkOk=false;
    }
    if (!$checkOk) {
        DebugInfo("[check false]", 3);
        break;
    }
}
$allLine=count($userArr);
if ($checkOk && count($uArr)==$allLine && count($skidArr)==$allLine && count($skArr)==$allLine) {
    // 要求每行的keyPair不一样，不然认为是脏数据
} else {
    $checkOk=false;
}
DebugInfo("[checkOk:$checkOk]", 3);
if ($checkOk) {
    // 数据检查完毕,写入
    foreach($userArr as $line) {
        list($user,$enable,$buckets,$skid,$sk)=explode(',',$line);
        try {
            $mutations[]=new Mutation( array(
                'column' => 'security:KP:'.$skid,
                'value' => $sk
            ) );
            //状态判断
            DebugInfo("[user:$user][enable:$enable]", 3);
            if ($enable) {
                $GLOBALS['mdb_client']->deleteAll(__MDB_TAB_MWS_USER, $user, 'index:ST:0');
                $mutations[]=new Mutation( array(
                    'column' => 'property:status',
                    'value' => 1 
                ) );
                $mutations[]=new Mutation( array(
                    'column' => 'index:ST:1',
                    'value' => 1 
                ) );
            } else {
                $GLOBALS['mdb_client']->deleteAll(__MDB_TAB_MWS_USER, $user, 'index:ST:1');
                $mutations[]=new Mutation( array(
                    'column' => 'property:status',
                    'value' => 0 
                ) );
                $mutations[]=new Mutation( array(
                    'column' => 'index:ST:0',
                    'value' => 1 
                ) );
            }
            $GLOBALS['mdb_client']->mutateRow(__MDB_TAB_MWS_USER, $user, $mutations);
        } catch (Exception $e) {
            DebugInfo("[write data fail,$e]", 3);
            return __HTTPSTATUS_BAD_REQUEST;
        }
        unset($mutations);
        /*{{{save to bucket table*/
        foreach ((array)explode('|',$buckets) as $bk) {
            $mutations[]=new Mutation( array(
                'column' => 'index:ST:1', 
                'value' => 1 
            ) );
            $mutations[]=new Mutation( array(
                'column' => 'index:O:'.$user, 
                'value' => 1 
            ) );
            $mutations[]=new Mutation( array(
                'column' => 'property:owner', 
                'value' => $user 
            ) );
            $mutations[]=new Mutation( array(
                'column' => 'property:status', 
                'value' => 1 
            ) );
            $mutations[]=new Mutation( array(
                'column' => 'property:log', 
                'value' => 1 
            ) );
            try {
                $GLOBALS['mdb_client']->mutateRow(__MDB_TAB_MDNDELIVER_BUCKET, $bk, $mutations);
                $saveOk=true;
            } catch (Exception $e) {
                $saveOk=false;
            }
            unset($mutations);
        }
        /*}}}*/
    }
    /*{{{删除用户检测和操作，视为禁用*/
    $disabledUsers=array_diff(array_keys($prevUser),array_keys($uArr));
    foreach ((array)$disabledUsers as $rowkey) {
        DebugInfo("[disable user:$rowkey]", 3);
        try {
            $GLOBALS['mdb_client']->deleteAll(__MDB_TAB_MWS_USER, $rowkey, 'index:ST:1');
            $mutations[]=new Mutation( array(
                'column' => 'index:ST:0', 
                'value' => 0 
            ) );
            $mutations[]=new Mutation( array(
                'column' => 'property:status', 
                'value' => 0 
            ) );
        } catch (Exception $e) {
            DebugInfo("[err in disable user]", 3);
            $GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST;
            return;
        }
        $GLOBALS['mdb_client']->mutateRow(__MDB_TAB_MWS_USER, $rowkey, $mutations);
        unset($mutations);
    }
    /*}}}*/
    $saveOk && $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
}
break;
}
?>
