<?php
/*
  +----------------------------------------------------------------------+
  | Name:fun/statusUnitFun.m                                                
  +----------------------------------------------------------------------+
  | Comment:处理statusUnit的函数                                            
  +----------------------------------------------------------------------+
  | Author:evoup                                                         
  +----------------------------------------------------------------------+
  | Created:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-03-29 15:27:08
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus']=__HTTPSTATUS_OK;
header("Content-type: application/json; charset=utf-8");
$down_nums = 0;
$err = false;
if ($GLOBALS['selector']==__SELECTOR_MDB) {
    //查询hbase状态的时候不能用thrift
} else {
    // 获取全部监控节点 
    $result=$GLOBALS['mdb_client']->scannerOpen(__MDB_TAB_ENGINE, '', (array)'scan:usable');
    while (true) {
        $record = $GLOBALS['mdb_client']->scannerGet($result);
        if ($record == NULL) {
            break;
        }
        $recordArray = array();
        foreach($record as $TRowResult) {
            $row=$TRowResult->row;
            list(,$serverNode)=explode('|',$row);
            $tempArr = $GLOBALS['mdb_client']->get(__MDB_TAB_ENGINE, 'monitorengine|'.$serverNode, "scan:master");
            if ($tempArr[0]->value) {
                $monitorNode[$serverNode]['master']=1;
            } else {
                $monitorNode[$serverNode]['slave']=1;
            }
        }
    }
    /* {{{ 查询needfix事件(以防止恢复事件没有set到事件表造成的事件仍然没有解决的问题)
     */
    $needfixList=$GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, "needfix", "event:item");
    $needfixList=$needfixList[0]->value;
    $needfixArr=explode('|',$needfixList);
    /* }}} */
}
switch ($GLOBALS['selector']) {
case (__SELECTOR_MONENGINE):
    foreach ($monitorNode as $snode => $monInfo) {
        $resMonNode[]=array('name'=>$snode,'status'=>1);
    }
    $str=json_encode($resMonNode);
    break;
case (__SELECTOR_MDB):
    $hbasehost=$hadoopConf['hadoop_host'];
    $totalHbaseServers=explode(',',$hadoopConf['hbase']['regionservers']);
    list($mcd_server,$mcd_port)=explode(':',$conf['memcache_host']);
    $mcd=memcache_connect($mcd_server, $mcd_port); //初始化memcache对象
    list($hbase_master,$master_port)=explode(":",memcache_get($mcd,__KEY_HBASEMASTER));
    $found=false;
    foreach ($hbasehost as $ip => $hostNameInfo) {
        if (!empty($hbase_master) && in_array($hbase_master,(array)explode(',',$hostNameInfo))) {
            $outPut=file("http://{$ip}:60010/master.jsp");
            $keyTags=array('<h2>Region Servers</h2>','<table>','</table>');
            $key=array_shift($keyTags);
            for($i=0;$i<sizeof($outPut);$i++) {
                if (strstr($outPut[$i],$key)) {
                    $key=array_shift($keyTags);
                    $lineRange[]=$i;
                }
            }
            $found=true;
            break;
        }
    }
    list(,$startLine,$endLine)=$lineRange;
    for ($i=$startLine;$i<$endLine;$i++) {
        if (preg_match('/<[aA]\\s+(.*?)href\\s*=\\s*(\"([^\"]*)\"|[^\\s>])\\s*>/',$outPut[$i],$match)) {
            foreach ($match as $mt) {
                if (preg_match('/http:\/\/(.*):/',$mt,$match2)) {
                    $hbaseServers[$match2[1]]=1;
                } 
            }
        }
    }
    $hbaseServers["namenode1"]=1;
    foreach (array_keys($hbaseServers) as $srv) {
        $out[]=array('name'=>$srv,'status'=>1);
    }
    foreach ($totalHbaseServers as $hbaseServer) {
        foreach ($out as $info) {
            if ($hbaseServer==$info['name']) {
                $out2[$hbaseServer]=array('name'=>$hbaseServer,'status'=>1);
                break;
            }
            $out2[$hbaseServer]=array('name'=>$hbaseServer,'status'=>1);
        }
    }
    foreach ($out2 as $srv => $info) {
        $out3[]=$info;
    }
    $str=json_encode($out3);
    break;
case (__SELECTOR_MONHEALTH):
    /* {{{ 扫描所有主机
     */
    $autoScaleServers=getAutoScalingSrvs();
    list($table_name,$start_row,$family) = array(__MDB_TAB_HOST, '', array('info')); //从row的起点开始 
    try {
        $scanner = $GLOBALS['mdb_client']->scannerOpen($table_name, $start_row , $family);
        while (true) {
            $get_arr = $GLOBALS['mdb_client']->scannerGet($scanner);
            if (array_filter($get_arr) == null) break;
            foreach ( $get_arr as $TRowResult ) {
                if (!empty($TRowResult->row)) {
                    if ($TRowResult->columns['info:status']->value==__HOST_STATUS_DOWN) {
                        !in_array($TRowResult->row, (array)$dw_arr) && !in_array($TRowResult->row,$autoScaleServers) && $dw_arr[]=$TRowResult->row;
                    }
                    !in_array($TRowResult->row, $host_arr) && $host_arr[] = $TRowResult->row;
                    if ($TRowResult->columns['info:status']->value==__HOST_STATUS_UP) {
                        $allUpSrv[$TRowResult->row]=1;
                    }
                }
            }
        }
        $GLOBALS['mdb_client']->scannerClose($scanner); //关闭scanner 
    } catch (Exception $e) {
        $err = true;
    }

    /* 排除未监控 */
    $host_arr = array_diff((array)$host_arr, (array)explode(',', $_CONFIG['not_monitored']['not_monitored']));
    $host_nums = count($host_arr);
    $dw_arr = array_diff((array)$dw_arr, (array)explode(',', $_CONFIG['not_monitored']['not_monitored']));
    $down_nums = count($dw_arr);
    $down_nums <=0 && $down_nums = 0;
    $host_arr = array_diff((array)$host_arr, (array)explode(',', $_CONFIG['not_monitored']['not_monitored']));

    $caution_event = 0;
    $warning_event = 0;
    $total_event = $host_nums*count($event_map_table)/__EVENT_TOTAL_STATUS; 
    do {
        $host = array_shift(&$host_arr);
        try {
            if (!empty($host)) {
                $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $host, array("event:"));
                if (!empty($arr)) {
                    $events = $arr[0]->columns;
                    if (array_filter($events)) {
                        foreach ($events as $event => $eventVal) {
                            $event_code = strtolower(substr($event, -4)); //取出4位事件代码 
                            if (in_array($event_code,$needfixArr) && $event_code!=__EVENTCODE_DOWN ) { //TODO 考虑把已经解决的事件显示出来 
                                if (array_shift(explode('|',$eventVal->value))==__EVENT_ACTIVE) { //激活的事件计数器+1 
                                    $event_level = substr($event_code , -1);  //判断事件等级 
                                    switch ($event_level) {
                                    case('c'):
                                        $caution_event++;
                                        break;
                                    case('w'):
                                        $warning_event++;
                                        break;
                                    }
                                }

                            }
                        }
                    }
                }
            }
        } catch (Exception $e) { }
    } while (!empty($host_arr));

    $event_percent = sprintf('%01.2f', ($total_event - $caution_event - $warning_event) / $total_event *100);
    if (!$err) {
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
    }
    /* }}} */
    $t = sprintf('%01.2f', ($host_nums - $down_nums) / $host_nums * 100); //主机health 
    $t2 = $event_percent; //事件health 
    $unscalings=array_diff($autoScaleServers,array_keys($allUpSrv));
    if (count($autoScaleServers)==0) {
        $t3=0;
    } else {
        $t3=sprintf("%01.2f", ((count($autoScaleServers)-count($unscalings))/count($autoScaleServers)) * 100);
    }
    $str = <<<EOT
{
    "hosts":"$t",
    "events":"$t2",
    "scalings":"$t3"
}
EOT;
    break;
case (__SELECTOR_MONEVENTSUMMARY):
case (__SELECTOR_MOBCLIENT):
    //扫描全部主机存在的事件
    /* 获取全部server */
    /* {{{ 扫描所有主机
     */
    list($table_name,$start_row,$family) = array(__MDB_TAB_HOST, '', array('info:')); //从row的起点开始 
    try {
        $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
        while (true) {
            $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
            if (array_filter($get_arr) == null) break;
            foreach ( $get_arr as $TRowResult ) {
                if (!empty($TRowResult->row)) {
                    $host_arr[] = $TRowResult->row;
                }
            }
        }
        $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
    } catch (Exception $e) {
        $err = true;
    }
    /* }}} */
    /* 排除不监控的 */
    $host_arr = array_diff((array)$host_arr, (array)explode(',', $_CONFIG['not_monitored']['not_monitored']));
    $caution_event = 0;
    $warning_event = 0;
    $total_event = count($host_arr)*count($event_map_table)/__EVENT_TOTAL_STATUS; 
    do {
        $host = array_shift(&$host_arr);
        try {
            if (!empty($host)) {
                $rs = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $host, array('info:'));
                $uiWordArr = getEventUIDesc($host, $rs[0]->columns, false); // 对于即时表，info列族内的监控项列，不带有timestamp，第三个参数传false
                $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $host, array("event:"));
                if (!empty($arr)) {
                    $events = $arr[0]->columns;
                    if (array_filter($events)) {
                        foreach ($events as $eventCode => $eventVal) {
                            $eventCode = strtolower(substr(str_replace('event:','',$eventCode), -4)); //取出4位事件代码 
                            if (in_array($eventCode, $needfixArr) && $eventCode != __EVENTCODE_DOWN && $eventVal->value==__EVENT_ACTIVE) { //TODO 可以添加已经解决和为解决的状态到UI
                                $event_level = substr($eventCode , -1);  //判断事件等级 
                                $eventNum = substr($eventCode, 0 , 3);
                                switch ($event_level) {
                                case('c'):
                                    //if (!empty($uiWordArr[$host][$eventNum])) {
                                        $caution_event++;
                                    //}
                                    break;
                                case('w'):
                                    //if (!empty($uiWordArr[$host][$eventNum])) {
                                        $warning_event++;
                                    //}
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception $e) { }
    } while (!empty($host_arr));

    $total_event = $total_event - $caution_event - $warning_event;
    $str = <<<EOT
{
    "caution":$caution_event,
    "warning":$warning_event,
    "ok":$total_event
}
EOT;
    if ($GLOBALS['selector']==__SELECTOR_MOBCLIENT) { // 给智能手机客户端的接口 
        $str = "{$caution_event}|{$warning_event}|{$total_event}";
    }
    break;
case (__SELECTOR_LOGININFO):
    if (!empty($_COOKIE['__CO_MMSUNAME'])) { //从mdb中查找该用户所在的用户组 if any 
        /* {{{ 获取全部用户组列表,找出存在该用户的组 
         */
        list($table_name,$start_row,$family) = array(__MDB_TAB_USERGROUP, '', array('info', 'member')); //从row的起点开始 
        try {
            $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
            while (true) { //TODO 这里可能会发生超时，需要加时限 
                $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                if (array_filter($get_arr) == null) break;
                foreach ( $get_arr as $TRowResult ) {
                    $user_group = $TRowResult->row; //以用户组为rowkey 
                    /* {{{ 取出成员用户
                     */
                    $column = $TRowResult->columns;
                    foreach ($column as $family_column=>$Tcell) {
                        $family = array_shift(explode(':', $family_column)); //取列族 
                        switch ($family) { //共2个列族，info和member,只取member 
                        case('info'):
                            $family_column=='info:desc' && $desc = $Tcell->value; //取得描述 
                            break;
                        case('member'):
                            $tmp_member = substr($family_column, strpos($family_column, ':')+1); //取得成员用户 
                            $member[] = $Tcell->value==__MONITOR_IS_MEMBER? $tmp_member: NULL; //断言值为member 
                            break;
                        }
                    }
                    $can_del = $user_group==__MONITOR_DEFAULT_USERGROUP? 0: 1; //为1可以删除，为0默认用户不能删除 
                    $ugroup[$user_group]['member']=(array)$member; //组成用户组名为key的数组 
                    $ugroup[$user_group]['desc']=$desc; //组成用户组名为key的数组 
                    /* }}} */
                    unset($member);
                }
            }
            $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
        } catch (Exception $e) {
            $err = true;
        }
        if (!$err) {
            foreach ($ugroup as $group => $users) {
                if (in_array($_COOKIE['__CO_MMSUNAME'],$users['member'])) {
                    $belong_group[]=$users['desc']; //找出用户所在的全部组存到数组 
                }
            } 
        }
        /* }}} */
    }
    if (!$err) {
        $str1 = array(join(',', $belong_group),$_COOKIE['__CO_MMSUNAME']); //多个用户组之前用,连接 
        echo json_encode($str1);
        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
    }
    break;
default:
    break;
}
echo $str;
?>
