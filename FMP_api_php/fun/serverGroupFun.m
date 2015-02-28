<?php
/*
  +----------------------------------------------------------------------+
  | Name:fun/serverGroupFun.m                                                
  +----------------------------------------------------------------------+
  | Comment:处理serverGroup的函数                                            
  +----------------------------------------------------------------------+
  | Author:evoup                                                         
  +----------------------------------------------------------------------+
  | Created:
  +----------------------------------------------------------------------+
  | Last-Modified: 2014-06-12 12:53:12
  +----------------------------------------------------------------------+
 */

$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

/* 以下符号应限制其不出现在组名 */
$replace_arr = array('~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '+', ',', '.', '/', '<', '>', '?');

switch ($GLOBALS['operation']) {
case(__OPERATION_CREATE): 
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'POST') { 
        if (!canAccess('create_serverGroup')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        /*{{{ [创建]一个新的服务器组的操作
         */
        $valid_key = array('name', 'desc', 'mailtype', 'membergroup','monitoritem','override_set'); //合法的POST的key

        /* 检查是否符合数据格式 */
        foreach ($valid_key as $servgroup_key) {
            if (!in_array($servgroup_key, array_keys($_POST))) { //对少传判断为非法 
                $GLOBALS['httpStatus'] = __HTTPSTATUS_METHOD_NOT_ALLOWED;  
                $err = true;
            } else {
                $servgroup_setting[$servgroup_key] = $_POST[$servgroup_key];
                if ($servgroup_key=='membergroup') {
                    $tmpArr=array_filter(explode('|',$servgroup_setting[$servgroup_key]));
                    $servgroup_setting[$servgroup_key]=join('|',$tmpArr);
                }
            }
        }
        /* 组名不为空且不能为数字(因为数字是默认组的) */
        $err = $err==false ?(!empty($servgroup_setting['name']) && !is_numeric($servgroup_setting['name']) ?false :true) :true; 

        /* 组名不超过100个英文字母,描述不超过200个英文字母 */
        $err = $err==false ?((strlen($servgroup_setting['desc'])<=200 && strlen($servgroup_setting['name'])<=100) ?false :true) :true; 
        /* 报警类型检查 */
        $err = $err==false ?(in_array($servgroup_setting['mailtype'], array(__MAILTYPE_NOSEND, __MAILTYPE_CAUTION, __MAILTYPE_WARNING, __MAILTYPE_ALL)) ?false :true) :true;

        /* {{{ 如果传了成员用户组，检查是否存在
         */
        if (!$err && !empty($servgroup_setting['membergroup'])) {
            list($table_name,$start_row,$family) = array(__MDB_TAB_USERGROUP, '', array('info')); //从row的起点开始 
            try {
                $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
                while (true) {
                    $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                    if (array_filter($get_arr) == null) break;
                    foreach ( $get_arr as $TRowResult ) {
                        $usergrp_arr[] = $TRowResult->row; //获取全部用户组名 
                    }
                }
                $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
            } catch (Exception $e) {
                $err = true;
            }
            foreach ((array)explode('|', $servgroup_setting['membergroup']) as $member) {
                !in_array($member, $usergrp_arr) && $err = true;
                break;
            }
        }
        /* }}} */
        /* {{{ 进行和全部内置监控项和上传监控项的对比，确认上传完备
         */
        if (!$err) { //上传的监控项转到数组upload_monitor_arr
            $itm_arr = (array)explode('#', $servgroup_setting['monitoritem']); //得到没有归类好的上传的监控项字符串 
            $itm_arr = array_filter($itm_arr);
            $itm_arr = array_pad($itm_arr,__MAX_DEFAULT_GROUP_NUM,'');
            foreach ($itm_arr as $item_str) {
                $key = array_shift(explode('|', $item_str)); //得到监控类别，作为key 
                $tmp_items = strstr($item_str,'|');
                /* 得到该监控种类下所有监控项和设置值 */
                $tmp_items = array_filter((array)explode('|', $tmp_items)); //第一个元素shift掉了为空要排除 
                $upload_monitor_arr[$key]=array();
                foreach ($tmp_items as $item_set) { //剩余该类别的监控项字符串 
                    list($item, $set_value) = explode(':', $item_set); //把监控项和设置值存到item和set_value 
                    $upload_monitor_arr[$key][$item] = $set_value; //得到归类完毕后的监控项设置数组 
                    unset($item,$set_value);
                } 
            }
        }
        if (!$err) { //先比较第一维是否完备
            $item = array_diff_key($monitor_item_arr, $upload_monitor_arr);
            $err = empty($item)? false: true;
        }
        if (!$err) { //再比较第二维是否完备 
            foreach ((array)array_keys($monitor_item_arr) as $needed_key) {
                $item2 = array_diff_key($monitor_item_arr[$needed_key], $upload_monitor_arr[$needed_key]);
                $err = empty($item2)? false: true;
                if ($err) {
                    break;
                }
            }
        }
        /* }}} */
        if (!$err) { //没错则返回200 
            //简化监控项信息
            foreach ($upload_monitor_arr as $item) {
                foreach ($item as $mon_key => $mon_value) {
                    if ($mon_value == "1") {
                        $tmp_str .= "1"; //如果监控项设置了，则字符串置1 
                    } else {
                        $tmp_str .= "0"; //否则置0 
                    }
                } 
                $mon_str_arr[] = $tmp_str; //得到每个监控种类对应的字符串
                unset($tmp_str);
            }
            $servgroup_setting['monitoritem'] = implode('|', $mon_str_arr); //最终简化了的监控项信息
            //形如11111111111111111111111111111111|001111111111111111111111111|1111111111111|11111|11111|||||||

            $param = array(
                'name'        => str_replace($replace_arr, '', $servgroup_setting['name']), //去掉空格 
                'desc'        => $servgroup_setting['desc'],
                'mailtype'    => $servgroup_setting['mailtype'],
                'membergroup' => $servgroup_setting['membergroup'],
                'monitoritem' => $servgroup_setting['monitoritem'],
                'override_set'=> $servgroup_setting['override_set']
            );
            if (false != mdbCreateServGroup($param)) { //创建自定义组 
                $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
            }
            if (false === mdbUpdateIni()) { //更新配置文本有误返回内部错误 
                $GLOBALS['httpStatus'] = __HTTPSTATUS_INTERNAL_SERVER_ERROR;
            }
        }
        /*}}}*/
    }
    break;
case(__OPERATION_READ): //查询操作 
    if ($GLOBALS['selector'] == __SELECTOR_MASS && $_SERVER['REQUEST_METHOD'] == 'GET') { //查询全部服务器组 
        /* {{{ 取出默认组配置项
         */
        list($table, $col, $row_key) = array(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, __KEY_INI_SERVLIST);
        try {
            $res = $GLOBALS['mdb_client']->getRowWithColumns($table, $row_key, array($col)); //取出设置项--现有自定义组的值 
            $res = $res[0]->columns;
            $res = $res[$col]->value; //获取value
            $default_servgroups = (array)json_decode($res); 
            DebugInfo("[serverGroup][read default_servgroups][res:".serialize($default_servgroups)."]", 3);
        } catch (Exception $e) {
            DebugInfo("[serverGroup][read default_servgroups][error]", 3);
            return false;
        }
        foreach ($default_servgroups as $group_id => $member_servers) {
            switch ($group_id) {
            case(__PREFIX_INI_SERVGROUP.__MONITOR_TYPE_GENERIC): //默认组(generic) 
                $group_type_1=getGroupCount(__MONITOR_TYPE_GENERIC);
                break;
            case(__PREFIX_INI_SERVGROUP.__MONITOR_TYPE_MYSQL): //默认组2(mysql)
                $group_type_2=getGroupCount(__MONITOR_TYPE_MYSQL);
                break;
            case(__PREFIX_INI_SERVGROUP.__MONITOR_TYPE_SERVING): //默认组3(serving)
                $group_type_3=getGroupCount(__MONITOR_TYPE_SERVING);
                break;
            case(__PREFIX_INI_SERVGROUP.__MONITOR_TYPE_DAEMON): //默认组4(daemon)
                $group_type_4=getGroupCount(__MONITOR_TYPE_DAEMON);
                break;
            case(__PREFIX_INI_SERVGROUP.__MONITOR_TYPE_REPORT): //默认组5(report)
                $group_type_5=getGroupCount(__MONITOR_TYPE_REPORT);
                break;
            case(__PREFIX_INI_SERVGROUP.__MONITOR_TYPE_MADN): //默认组6(madn) 
                $group_type_6=getGroupCount(__MONITOR_TYPE_MADN);
                break;
            case(__PREFIX_INI_SERVGROUP.__MONITOR_TYPE_HADOOP): //默认组7(hadoop) 
                $group_type_7=getGroupCount(__MONITOR_TYPE_HADOOP);
                break;
            case(__PREFIX_INI_SERVGROUP.__MONITOR_TYPE_BIZLOG): //默认组8(bizlog) 
                $group_type_8=getGroupCount(__MONITOR_TYPE_BIZLOG);
                break;
            }
        }
        /* }}} */
        /* {{{ 取出自定义组配置项
         */
        $row_key = __KEY_INI_SERVLIST_CUST;
        try {
            $res = $GLOBALS['mdb_client']->getRowWithColumns($table, $row_key, array($col)); //取出设置项--现有自定义组的值 
            $res = $res[0]->columns;
            $res = $res[$col]->value; //获取value
            $cust_servgroups = (array)json_decode($res); 
            $cust_servgroups = (array)$cust_servgroups[__TEMPLATE_VAR_CUSTGROUPS]; //获取全部自定义组 
            DebugInfo("[serverGroup][read cust_servgroups][res:".serialize($cust_servgroups)."]", 3);
        } catch (Exception $e) {
            DebugInfo("[serverGroup][read cust_servgroups][error]", 3);
            return false;
        }
        /* 构建自定义组的json字符串部分*/
        foreach ($cust_servgroups as $cust_group_name => $member_servers) {
            DebugInfo("[serverGroup][cust_group_name str:$cust_group_name]", 3);
            list($onlineNums,$downNums,$okEvents,$cautionEvents,$warningEvents) = getGroupCount($cust_group_name);
            $tmp_str .= ",\"{$cust_group_name}\":[{$onlineNums},{$downNums},{$okEvents},{$cautionEvents},{$warningEvents},1]";
        }
        DebugInfo("[serverGroup][cust json str:$tmp_str]", 3);
        /* }}} */
        /* {{{ 输出read操作的json
         */
        $GLOBALS['httpStatus']=__HTTPSTATUS_OK;
        switch ($GLOBALS['rowKey']) {
        case('cust'):
            $tmp_str = substr($tmp_str, 1); //去掉首个逗号 
            $str = "{{$tmp_str}}";
            break;
        default:
            $str = <<<EOT
{
    "GENERIC": [
        $group_type_1[0],
        $group_type_1[1],
        $group_type_1[2],
        $group_type_1[3],
        $group_type_1[4],
        0
    ],
    "MYSQL": [
        $group_type_2[0],
        $group_type_2[1],
        $group_type_2[2],
        $group_type_2[3],
        $group_type_2[4],
        0
    ],
    "SERVING": [
        $group_type_3[0],
        $group_type_3[1],
        $group_type_3[2],
        $group_type_3[3],
        $group_type_3[4],
        0
    ],
    "DAEMON": [
        $group_type_4[0],
        $group_type_4[1],
        $group_type_4[2],
        $group_type_4[3],
        $group_type_4[4],
        0
    ],
    "REPORT": [
        $group_type_5[0],
        $group_type_5[1],
        $group_type_5[2],
        $group_type_5[3],
        $group_type_5[4],
        0
    ],
    "MADN": [
        $group_type_6[0],
        $group_type_6[1],
        $group_type_6[2],
        $group_type_6[3],
        $group_type_6[4],
        0
    ],
    "HADOOP": [
        $group_type_7[0],
        $group_type_7[1],
        $group_type_7[2],
        $group_type_7[3],
        $group_type_7[4],
        0
    ],
    "BISINESS LOG": [
        $group_type_8[0],
        $group_type_8[1],
        $group_type_8[2],
        $group_type_8[3],
        $group_type_8[4],
        0
    ],
    "JAIL": [
0,0,0,0,0,0
    ],
    "MDB": [
0,0,0,0,0,0
    ],
    "GSLB": [
0,0,0,0,0,0
    ],
    "SECURITY": [
0,0,0,0,0,0
    ]{$tmp_str}
}
EOT;
            break;
        }
        echo $str;
        /* }}} */
    } elseif ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'GET') { //查询单个服务器组 
        /* {{{ 取出自定义组配置项
         */
        $input = urldecode(ltrim(trim($GLOBALS['rowKey']))); //获取服务器组名 
        list($table, $col, $row_key) = array(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, __KEY_INI_GROUP_CUST);
        try {
            $res = $GLOBALS['mdb_client']->getRowWithColumns($table, $row_key, array($col)); //取出设置项--现有自定义组的值 
            $res = $res[0]->columns;
            $res = $res[$col]->value; //获取value
            $cust_servgroups = (array)json_decode($res); 
            DebugInfo("[serverGroup][read cust_servgroups][res:".serialize($cust_servgroups)."]", 3);
        } catch (Exception $e) {
            DebugInfo("[serverGroup][read cust_servgroups][error]", 3);
            return false;
        }
        /* }}} */
        /* {{{ 输出read操作的json 
         */
        $cust_servgroups['server_group']=(array)$cust_servgroups['server_group']; // from json to array! 
        if (false != in_array($input, array_keys($cust_servgroups['server_group']))) {  //判断组名是否存在 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
            $cust_grp_info = (array)($cust_servgroups['server_group'][$input]);
            if (false!==($cust_grp_info['monitoritem']=getServGroupMonitorItem($input))) {
            }
            $str = json_encode($cust_grp_info);
            echo $str;  
        } else {
            DebugInfo("[serverGroup][read cust_servgroups][group name ($input) not exist][custgrps:".join(',',$cust_servgroups)."]", 3);
        }
        /* }}} */
    }
    break;
        case(__OPERATION_UPDATE):
            if ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'POST') { 
                if (!canAccess('update_serverGroup')) {
                    $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
                    return;
                }
                /* {{{ [更新]服务器(组)列表,调整组 
                 */
                $valid_key = array('name', 'desc','mailtype','membergroup','monitoritem','override_set'); //合法的POST的key
                /* 检查是否符合数据格式 */
                foreach ($valid_key as $servgroup_key) {
                    if (!in_array($servgroup_key, array_keys($_POST))) { //对少传判断为非法 
                        $GLOBALS['httpStatus'] = __HTTPSTATUS_METHOD_NOT_ALLOWED;
                        $err = true;
                    } else {
                        $servgroup_setting[$servgroup_key] = $_POST[$servgroup_key];
                        if ($servgroup_key=='membergroup') {
                            $tmpArr=array_filter(explode('|',$servgroup_setting[$servgroup_key]));
                            $servgroup_setting[$servgroup_key]=join('|',$tmpArr);
                        }
                    }
                }
                /* 组名不为空且不能为数字(因为数字是默认组的) */
                $err = $err==false? (!empty($servgroup_setting['name']) && !is_numeric($servgroup_setting['name'])?false: true): true; 

                /* 组名不超过100个英文字母,描述不超过200个英文字母 */
                $err = $err==false? ((strlen($servgroup_setting['desc'])<=200 && strlen($servgroup_setting['name'])<=100)?false: true): true; 
                $input = urldecode(ltrim(trim($GLOBALS['rowKey']))); //获取要修改的自定义组的名字 

                /* 报警类型检查 */
                $err = $err==false ?(in_array($servgroup_setting['mailtype'], array(__MAILTYPE_NOSEND, __MAILTYPE_CAUTION, __MAILTYPE_WARNING, __MAILTYPE_ALL)) ?false :true) :true;

                /* {{{ 如果传了成员用户组，检查是否存在
                 */
                if (!$err && !empty($servgroup_setting['membergroup'])) {
                    list($table_name,$start_row,$family) = array(__MDB_TAB_USERGROUP, '', array('info')); //从row的起点开始 
                    try {
                        $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
                        while (true) {
                            $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                            if (array_filter($get_arr) == null) break;
                            foreach ( $get_arr as $TRowResult ) {
                                $usergrp_arr[] = $TRowResult->row; //获取全部用户组名 
                            }
                        }
                        $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
                    } catch (Exception $e) {
                        $err = true;
                    }
                    foreach ((array)explode('|', $servgroup_setting['membergroup']) as $member) {
                        !in_array($member, $usergrp_arr) && $err = true;
                        break;
                    }
                }
                /* }}} */
                /* {{{ 进行和全部内置监控项和上传监控项的对比，确认上传完备
                 */
                if (!$err) { //上传的监控项转到数组upload_monitor_arr
                    $itm_arr = explode('#', $servgroup_setting['monitoritem']); //得到没有归类好的上传的监控项字符串 
                    foreach ($itm_arr as $item_str) {
                        $key = array_shift(explode('|', $item_str)); //得到监控类别，作为key 
                        $tmp_items = strstr($item_str,'|');
                        /* 得到该监控种类下所有监控项和设置值 */
                        $tmp_items = array_filter((array)explode('|', $tmp_items)); //第一个元素shift掉了为空要排除 
                        $upload_monitor_arr[$key]=array();
                        foreach ($tmp_items as $item_set) { //剩余该类别的监控项字符串 
                            list($item, $set_value) = explode(':', $item_set); //把监控项和设置值存到item和set_value 
                            $upload_monitor_arr[$key][$item] = $set_value; //得到归类完毕后的监控项设置数组 
                            unset($item,$set_value);
                        } 
                    }
                }
                if (!$err) { //先比较第一维是否完备
                    $item = array_diff_key($monitor_item_arr, $upload_monitor_arr);
                    $err = empty($item)? false: true;
                }
                if (!$err) { //再比较第二维是否完备 
                    foreach ((array)array_keys($monitor_item_arr) as $needed_key) {
                        $item2 = array_diff_key($monitor_item_arr[$needed_key], $upload_monitor_arr[$needed_key]);
                        $err = empty($item2)? false: true;
                        if ($err) {
                            break;
                        }
                    }
                }
                /* }}} */
                //简化监控项信息
                foreach ($upload_monitor_arr as $item) {
                    foreach ($item as $mon_key => $mon_value) {
                        if ($mon_value == "1") {
                            $tmp_str .= "1"; //如果监控项设置了，则字符串置1 
                        } else {
                            $tmp_str .= "0"; //否则置0 
                        }
                    } 
                    $mon_str_arr[] = $tmp_str; //得到每个监控种类对应的字符串
                    unset($tmp_str);
                }
                $servgroup_setting['monitoritem'] = implode('|', $mon_str_arr); //最终简化了的监控项信息
                //形如11111111111111111111111111111111|001111111111111111111111111|1111111111111|11111|11111|||||||

                /* {{{ 判断是否存在该自定义组，存在则更新组名和描述的过程
                 */
                /*    {{{ 取出自定义组配置项并更新
                 */
                list($table, $col, $row_key) = array(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, __KEY_INI_GROUP_CUST);
                if (!$err) {
                    try {
                        $res = $GLOBALS['mdb_client']->getRowWithColumns($table, $row_key, array($col)); //取出设置项--现有自定义组的值 
                        $res = $res[0]->columns;
                        $res = $res[$col]->value; //获取value
                        $cust_servgroups =(array)json_decode($res);  //获取全部自定义组和组描述 
                        $cust_servgroups=(array)$cust_servgroups['server_group'];
                        DebugInfo("[serverGroup][read cust_servgroups][input:$input][cust_servgroups:".serialize($cust_servgroups)."]", 3);
                        if (false != in_array($input, array_keys($cust_servgroups))) {  //判断原先的组名是否存在 
                            DebugInfo("[prevGrpName:$input][newGrpName:{$servgroup_setting['name']}]");
                            /* 存在则更新该自定组的组名和描述后返回200 */
                            foreach ($cust_servgroups as $grp=>$grpInfo) { // for json convert to array 
                                $tmpCustGroups[$grp]=(array)$grpInfo;
                            }
                            $cust_servgroups=$tmpCustGroups;
                            unset($tmpCustGroups);
                            if ($input==$servgroup_setting['name']) { // 服务器组名和以前一样 
                                $cust_servgroups[$input]['desc']=$servgroup_setting['desc'];
                                $cust_servgroups[$input]['mailtype']=$servgroup_setting['mailtype'];
                                $cust_servgroups[$input]['membergroup']=$servgroup_setting['membergroup'];
                                $cust_servgroups[$input]['monitoritem']=$servgroup_setting['monitoritem'];
                                $cust_servgroups[$input]['override_set']=$servgroup_setting['override_set'];
                            } else { // 服务器组名更改 
                                $cust_servgroups[$servgroup_setting['name']]=$cust_servgroups[$input];
                                unset($cust_servgroups[$input]);
                                $cust_servgroups[$servgroup_setting['name']]['desc']=$servgroup_setting['desc'];
                                $cust_servgroups[$servgroup_setting['name']]['mailtype']=$servgroup_setting['mailtype'];
                                $cust_servgroups[$servgroup_setting['name']]['membergroup']=$servgroup_setting['membergroup'];
                                $cust_servgroups[$servgroup_setting['name']]['monitoritem']=$servgroup_setting['monitoritem'];
                                $cust_servgroups[$servgroup_setting['name']]['override_set']=$servgroup_setting['override_set'];
                            }
                            $cust_servgroups=array('server_group'=>$cust_servgroups);
                            if (false != mdb_set($table, $col, $row_key, json_encode($cust_servgroups))) {
                                DebugInfo("[$moduleName][delete server group][name:$input][ok]", 3);
                                if (false === mdbUpdateIni()) { //更新配置文本有误返回内部错误 
                                    $GLOBALS['httpStatus'] = __HTTPSTATUS_INTERNAL_SERVER_ERROR;
                                } else {
                                    $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //删除成功哦返回200 
                                    return true;
                                }
                            }
                        } else {
                            DebugInfo('[serverGroup][update fail][previous group not exist]', 3);
                            $GLOBALS['httpStatus'] = __HTTPSTATUS_METHOD_CONFILICT;
                        }
                    } catch (Exception $e) {
                        DebugInfo("[serverGroup][update cust_servgroups][error]", 3);
                        $GLOBALS['httpStatus'] = __HTTPSTATUS_INTERNAL_SERVER_ERROR;
                    }
                }
                return false; //任何删除失败或异常返回false  
                /*    }}} */

                /* }}} */
                /* }}} */
            }
            break;
        case(__OPERATION_DELETE):
            if ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'GET') { 
                if (!canAccess('delete_serverGroup')) {
                    $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
                    return;
                }
                /* {{{ [删除]的过程
                 */
                $input = urldecode(ltrim(trim($GLOBALS['rowKey']))); //获取要删除的自定义组的名字 
                DebugInfo("[$moduleName][serverGroup][groupName:$input]", 3);
                //检查该组下面是否有服务器，如果有不能够删除
                if ( !empty($_CONFIG['server_list']["type_{$GLOBALS['rowKey']}"]) ) {
                    $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
                    return;
                }

                /*    {{{ 取出自定义组配置项并删除组
                 */
                list($table, $col, $row_key) = array(__MDB_TAB_SERVER, __MDB_COL_CONFIG_INI, __KEY_INI_GROUP_CUST);
                try {
                    $res = $GLOBALS['mdb_client']->getRowWithColumns($table, $row_key, array($col)); //取出设置项--现有自定义组的值 
                    $res = $res[0]->columns;
                    $res = $res[$col]->value; //获取value
                    DebugInfo("[$moduleName][serverGroup][read cust_servgroups][res:".serialize($res)."]", 3);
                    $cust_servgroups = (array)json_decode($res);  //获取全部自定义组
                    $cust_servgroups = (array)$cust_servgroups[__JSONKEY_SERVER_GROUP]; //获取值
                    DebugInfo("[$moduleName][serverGroup][read cust_servgroups][cust_servgroups:".join(',', array_keys($cust_servgroups))."]", 3);
                    if (false != in_array($input, array_keys($cust_servgroups))) {  //判断组名是否存在 
                        /* 存在则删除该自定组后返回200 */
                        unset($cust_servgroups[$input]);
                        DebugInfo("[$moduleName][serverGroup][read cust_servgroups][will delete the cust_servgroup:$input]", 3);
                        $cust_servgroups=array(__JSONKEY_SERVER_GROUP => $cust_servgroups);
                        if (false != mdb_set($table, $col, $row_key, json_encode($cust_servgroups))) {
                            DebugInfo("[$moduleName][delete server group][name:$input][ok]", 3);
                            if (false === mdbUpdateIni()) { //更新配置文本有误返回内部错误 
                                $GLOBALS['httpStatus'] = __HTTPSTATUS_INTERNAL_SERVER_ERROR;
                            } else {
                                mdb_set(__MDB_TAB_SERVER,'event:item','servtype'.$input,'');
                                $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //删除成功哦返回200 
                                return true;
                            }
                        }
                    }
                } catch (Exception $e) {
                    DebugInfo("[serverGroup][delete cust_servgroups][error]", 3);
                }
                return false; //任何删除失败或异常返回false  
                /*    }}} */
                /* }}} */
            }
            break;
}

/**
 *@brief 获取组的统计信息数组
 *@param $group 组名
 *return 由在线数、宕机数、正常事件数、注意事件数，严重事件数组成的数组
 */
function getGroupCount($group) {
    global $_CONFIG;
    $totalOnlineMembers=$totalDownMembers=$totalCautionEvents=$totalWarningEvents=0;
    $Hosts = array_unique(explode(',', $_CONFIG['server_list']["type_{$group}"]));
    $Unmonitoed = explode(',', $_CONFIG['not_monitored']['not_monitored']);
    $Hosts = array_diff((array)$Hosts, (array)$Unmonitoed);
    if (array_filter($Hosts)) {
        $totalOnlineMembers=count($Hosts);
        foreach ($Hosts as $host) {
            /*{{{获取在线状态*/
            $arr=$GLOBALS['mdb_client']->get(__MDB_TAB_HOST, $host, "info:status");
            $status=$arr[0]->value;
            if ($status===__HOST_STATUS_DOWN) {
                $totalOnlineMembers--;
                $totalDownMembers++;
            }
            /*}}}*/
            /*{{{获取事件*/
            $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER, $host, array("event:"));
            if ($arr) {
                $arr=$arr[0]->columns;
                foreach ($arr as $tmpEvent=>$tmpArr) {
                    $eventCode=str_replace('event:','',$tmpEvent); //得到4位事件代码 
                    //除了宕机的event就是注意和严重事件 
                    if ($eventCode!=__EVENTCODE_DOWN) {
                        $eventLevel=substr($eventCode,-1); //得到事件的等级 
                        list($event_status,)=explode('|',$tmpArr->value); //得到事件激活状态 
                        if ($eventLevel==__SUFFIX_EVENT_CAUTION) {
                            $event_status!=0 && $totalCautionEvents++;
                        } elseif ($eventLevel==__SUFFIX_EVENT_WARNING) {
                            $event_status!=0 && $totalWarningEvents++;
                        }
                    } 
                }
            }
            /*}}}*/
        }
        $okEvents = 27*count($Hosts)-$totalCautionEvents-$totalWarningEvents;
        return array($totalOnlineMembers,$totalDownMembers,$okEvents,$totalCautionEvents,$totalWarningEvents);
    } else {
        return array(0,0,0,0,0); //空的组 
    }
}

/**
 *@brief 获取服务器组的设置
 */
function getServGroupMonitorItem($srv) {
    global $monitor_item_arr;
    // 先获取已经设置过的监控项
    try {
        $ini_arr = $GLOBALS['mdb_client']->get(__MDB_TAB_SERVER, __KEY_INIDATA, __MDB_COL_CONFIG_INI);
        $get_string = $ini_arr[0]->value;
        $server_group_string=parse_ini_string($get_string,true);
        $servgrp_setting=$server_group_string['server_group'][$srv];
        DebugInfo("[servgrp_monitoritem][found {$srv}`s setting:{$servgrp_setting}]",3);
        if (empty($servgrp_setting)) {
            return false;
        }
        list(,,$monitorStr)=explode('#',$servgrp_setting);
        DebugInfo("[servgrp_monitoritem][found {$srv}`s monitor setting:{$monitorStr}]",3);
        $tmpMonitorArr=explode('|',$monitorStr);
        $tmpMonitorArr=array_filter($tmpMonitorArr,'is_numeric');
        foreach ($tmpMonitorArr as $monStr) {
            DebugInfo("[servgrp_monitoritem][monStr:{$monStr}]");
            $monitorArr[]=str_split($monStr);
            DebugInfo("[servgrp_monitoritem][monitorArr:".json_encode($monitorArr)."]",3);
        }
    } catch (Exception $e) {
        DebugInfo('[servgrp_monitoritem][get customize group monitoritem setting err]'.$e->getMessage());
    }
    foreach ($monitor_item_arr as $class => $monItemInfo) {
        DebugInfo("[servgrp_monitoritem][class:$class][monItemInfo:".json_encode($monItemInfo)."]",3);
        $mArr=array_shift($monitorArr);
        DebugInfo("[servgrp_monitoritem][class:$class][mArr:".json_encode($mArr)."]",3);
        $retArr[$class]=NULL;
        foreach ($monItemInfo as $item => $isMonitored) {
            $isMonitored=array_shift($mArr);
            DebugInfo("[servgrp_monitoritem][class:$class][item:$item][isMonitored:$isMonitored]",3);
            $retArr[$class][$item]=$isMonitored?'1':'0';
        }
    }
    return $retArr;
}
?>
