<?php
/*
  +----------------------------------------------------------------------+
  | Name: fun/usergroupFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理用户组的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 15:47:33
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");

switch ($GLOBALS['operation']) {
case(__OPERATION_CREATE):
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'POST') { 
        if (!canAccess('create_usergroup')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        $valid_key = array('desc', 'privilege', 'member'); //合法的POST的key
        $valid_privilege_key = array_keys($privilege_item_arr);
        /* {{{ 上传数据检查 
         */
        /* 检查是否符合数据格式 */
        foreach ($valid_key as $usergroup_key) {
            if (!in_array($usergroup_key, array_keys($_POST))) { //检查参数是否传满，对少传判断为非法 
                $err = true;
            } else {
                $usergroup_setting[$usergroup_key] = $_POST[$usergroup_key];
            }
        }
        DebugInfo("[$moduleName][create servergroup]", 3);
        $GLOBALS['rowKey'] = urldecode($GLOBALS['rowKey']);
        /* 组名格式是数字字母下划线或者中划线 */
        $err = ereg("^[0-9a-zA-Z\_\-]*$", $GLOBALS['rowKey']) ?false :true;
        /* 组名不为空且不为默认用户组名 */
        $err = $err==false? (!empty($GLOBALS['rowKey']) && $GLOBALS['rowKey']!=__MONITOR_DEFAULT_USERGROUP?false: true): true; 
        /* 组名不超过100个英文字母,描述不超过200个英文字母 */
        $err = $err==false? ((strlen($usergroup_setting['desc'])<=200 && strlen($GLOBALS['rowKey'])<=100)?false: true): true; 
        /* 判断权限字符串*/
        if (!$err) {
            $arr = explode('|', $usergroup_setting['privilege']);
            foreach ($arr as $privilege_item) {
                list($tmp_privilege_key, $tmp_privilege_val) = explode('#', $privilege_item);
                //检查权限CRUD范围
                $err = in_array($tmp_privilege_val, range(__MONITOR_PRIVILEGE_OPERATION_MINNUM,__MONITOR_PRIVILEGE_OPERATION_MAXNUM))?false :true;
                $privileges[$tmp_privilege_key] = $tmp_privilege_val; //获取全部上传权限项 
            }
            foreach ($valid_privilege_key as $needed) {
                if (!in_array($needed, array_keys($privileges))) { //检查权限项是否传满 
                    $err = true;
                }
            }
        }
        /* {{{ 检查用户组名是否存在
         */
        if (!$err) {
            list($table_name,$start_row,$family) = array(__MDB_TAB_USERGROUP, '', array('info')); //从row的起点开始 
            try {
                $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
                while (true) {
                    $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                    if ($get_arr == null) break;
                    foreach ( $get_arr as $TRowResult ) {
                        $usergroup_arr[] = $TRowResult->row; //获取全部用户组的组名 
                    }
                }
                $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
            } catch (Exception $e) {
                $err = true;
            }
            in_array($GLOBALS['rowKey'], $usergroup_arr) && $err = true; //用户组名存在返回409
            $GLOBALS['httpStatus'] = __HTTPSTATUS_METHOD_CONFILICT;
        }
        /* }}} */
        /* {{{ 扫描每组的成员存入usergroup_arr2数组
         */
        foreach ((array)$usergroup_arr as $group_name) {
            $tmpArr = $GLOBALS['mdb_client']->getRowWithColumns($table_name, $group_name, array('member:'));
            $tmpArr = $tmpArr[0]->columns;
            foreach ((array)array_keys($tmpArr) as $tmpMemberName) {
                list(,$mb) = explode(':', $tmpMemberName);
                if (!empty($mb)) {
                    $usergroup_arr2[$group_name][]=$mb; //得到全部组和成员用户的数组 
                }
            }
        }
        /* }}} */
        /* 是否存在该成员用户 */
        $input_member_arr = array_filter(explode('|', $usergroup_setting['member']));
        if (!$err && !empty($input_member_arr)) {
            /*  {{{ 检查用户名是否存在
             */
            list($table_name,$start_row,$family) = array(__MDB_TAB_USER, '', array('info')); //从row的起点开始 
            try {
                $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
                while (true) {
                    $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                    if (array_filter($get_arr) == null) break;
                    foreach ( $get_arr as $TRowResult ) {
                        $user_arr[] = $TRowResult->row; //获取全部用户的用户名 
                    }
                }
                $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
            } catch (Exception $e) {
                $err = true;
            }
            foreach ($input_member_arr as $member) {
                if (!in_array($member, $user_arr)) {
                    $err = true;
                }
            }
            /*  }}} */
        }
        /* }}} */
        /* {{{ 添加用户组到mdb 
         */
        if (!$err) {
            $table_name = __MDB_TAB_USERGROUP;
            $row_key = $GLOBALS['rowKey']; //以要创建的用户名为rowkey
            $mutations = array(
                new Mutation( array(
                    'column' => "info:desc", //列desc 
                    'value'  => $usergroup_setting['desc'] 
                ) ),
                new Mutation( array(
                    'column' => "info:privilege", //列privilege 
                    'value'  => $usergroup_setting['privilege'] 
                ) )
            );
            //成员组成列，加到mutations
            foreach ($input_member_arr as $member) {
                $mutations[] = new Mutation( array(
                    'column' => "member:$member", //列member:所属的组id  TODO 删除用户名这里对应的列也要维护
                    'value'  => __MONITOR_IS_MEMBER 
                ) );
            }
            try { //thrift出错直接抛出异常需要捕获 
                $GLOBALS['mdb_client']->mutateRow( $table_name, $row_key, $mutations );
            } catch(Exception $e) { //抛出异常返回400 
                echo $e;
                $err = true;
            }
        }
        if (!$err) { //没错则返回200 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
            $usergroup_arr2[$GLOBALS['rowKey']]=$input_member_arr; //新增的加入usergroup_arr2 
            mdbUpdateUserGroupSetting($usergroup_arr2); //更新MDB中相应的配置段落 
            mdbUpdateIni(); //更新MDB中的INI配置文本
        }
        /* }}} */
    }
    break;
case(__OPERATION_READ): //查询操作 
    if ($_SERVER['REQUEST_METHOD'] == 'GET') { 
        if (!canAccess('read_usergroupList')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        switch ($GLOBALS['selector']) {
            /* {{{ get all 获取全部用户组列表 
             */
        case(__SELECTOR_MASS):
            list($table_name,$start_row,$family) = array(__MDB_TAB_USERGROUP, '', array('info', 'member')); //从row的起点开始 
            try {
                $scanner = $GLOBALS['mdb_client']->scannerOpen($table_name, $start_row, $family);
                while (true) { //TODO 这里可能会发生超时，需要加时限 
                    $get_arr = $GLOBALS['mdb_client']->scannerGet($scanner);
                    if (array_filter($get_arr) == null) break;
                    foreach ( $get_arr as $TRowResult ) {
                        $user_group = $TRowResult->row; //以用户组为rowkey 
                        /* {{{ 取出描述和成员用户
                         */
                        $column = $TRowResult->columns;
                        foreach ($column as $family_column=>$Tcell) {
                            $family = array_shift(explode(':', $family_column)); //取列族 
                            switch ($family) { //共2个列族，info和member 
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
                        $str[$user_group]=array($desc,(array)$member,$can_del); //组成用户组名为key的数组 
                        /* }}} */
                        unset($member);
                    }
                }
                $GLOBALS['mdb_client']->scannerClose($scanner); //关闭scanner 
            } catch (Exception $e) {
                $err = true;
            }
            if (!$err) {
                uksort($str, 'default_admin_cmp');
                echo json_encode($str);
                $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //查询成功返回200 
            }
            break;
            /* }}} */
            /* {{{ get single 获取单个用户组的设置
             */
        case(__SELECTOR_SINGLE):
            $GLOBALS['rowKey'] = urldecode($GLOBALS['rowKey']); 
            switch ($GLOBALS['rowKey']) {
                /* {{{ 查询单个用户组时GET
                 */
            default:
                list($table_name,$row_key) = array(__MDB_TAB_USERGROUP, $GLOBALS['rowKey']); //以用户组名为rowkey 
                try {
                    $res = $GLOBALS['mdb_client']->getRow($table_name, $row_key);
                } catch (Exception $e) {
                    $err = true;
                }
                $res = (array)$res[0]; //得到二维数组下标为row和columns 
                if (empty($res)) {
                    $err = true;
                } else {
                    $str = array( //组织用户组信息数据 
                        "desc"      => $res['columns']['info:desc']->value,
                        "privilege" => $res['columns']['info:privilege']->value
                    );
                }
                foreach (array_keys($res['columns']) as $column_name) {
                    $family = array_shift(explode(":", $column_name));
                    if ($family == 'member') {
                        $member[] = substr($column_name, strpos($column_name, ':')+1); //取得成员用户 
                    }
                }
                $tmp_user_pri=explode('|', $str['privilege']);
                foreach ($tmp_user_pri as $pri) {
                    $key = array_shift(explode('#', $pri));
                    $user_pri_arr[$key] = substr($pri, strpos($pri, '#')+1); //获取每个权限项目的数据 
                }
                foreach (array_keys($privilege_item_arr) as $privilege_item) { //遍历界面定义的权限 
                    $privilege_item_arr[$privilege_item]['current_privilege'] = $user_pri_arr[$privilege_item]; //获取当前选择权限 
                    $tmp_arr = array_values($privilege_item_arr[$privilege_item]); //构成描述、权限、成员用户的数组 
                    $tmp_arr[1] = join('|',$tmp_arr[1]); //对第二维(权限)传递给json时,对可选权限之间以|连接 
                    $last_pri_arr[$privilege_item] = $tmp_arr; //赋值给权限项 
                }

                list($table_name,$start_row,$family) = array(__MDB_TAB_USER, '', array('info')); //从row的起点开始 
                try {
                    $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
                    while (true) {
                        $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                        if (array_filter($get_arr) == null) break;
                        foreach ( $get_arr as $TRowResult ) {
                            $tmp_col = $TRowResult->columns;
                            $user_arr[$TRowResult->row] = $tmp_col['info:desc']->value; //获取全部用户的描述 
                        }
                    }
                    $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
                } catch (Exception $e) {
                    $err = true;
                }
                /* 构造成员用户数组 */
                foreach ($member as $user) {
                    if (in_array($user, array_keys($user_arr))) { //对属于成员用户的用户构成用户名=>描述的数组 
                        $res_member[$user]=$user_arr[$user];
                    }
                }
                $string = array($str['desc'], (array)$last_pri_arr,(array)$res_member);
                if (!$err) {
                    echo json_encode($string);
                    $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //查询成功返回200 
                }
                break;
                /* }}} */

            }
            break;
            /* }}} */
        }
    }
    break;
case(__OPERATION_UPDATE): //修改操作 
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'POST') { 
        if (!canAccess('update_usergroup')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        $valid_key = array('desc', 'privilege', 'member'); //合法的POST的key
        $valid_privilege_key = array_keys($privilege_item_arr);
        /* {{{ 上传数据检查 
         */
        /* 检查是否符合数据格式 */
        foreach ($valid_key as $usergroup_key) {
            if (!in_array($usergroup_key, array_keys($_POST))) { //检查参数是否传满，对少传判断为非法 
                $err = true;
            } else {
                $usergroup_setting[$usergroup_key] = $_POST[$usergroup_key];
            }
        }
        DebugInfo("[$moduleName][create servergroup]", 3);
        /* 组名不为空且不为默认用户组名 */
        $err = $err==false? (!empty($GLOBALS['rowKey']) && $GLOBALS['rowKey']!=__MONITOR_DEFAULT_USERGROUP?false: true): true; 
        /* 组名不超过100个英文字母,描述不超过200个英文字母 */
        $err = $err==false? ((strlen($usergroup_setting['desc'])<=200 && strlen($GLOBALS['rowKey'])<=100)?false: true): true; 
        /* 判断权限字符串*/
        if (!$err) {
            $arr = explode('|', $usergroup_setting['privilege']);
            foreach ($arr as $privilege_item) {
                list($tmp_privilege_key, $tmp_privilege_val) = explode('#', $privilege_item);
                //检查权限CRUD范围
                $err = in_array($tmp_privilege_val, range(__MONITOR_PRIVILEGE_OPERATION_MINNUM,__MONITOR_PRIVILEGE_OPERATION_MAXNUM))?false :true;
                $privileges[$tmp_privilege_key] = $tmp_privilege_val; //获取全部上传权限项 
            }
            foreach ($valid_privilege_key as $needed) {
                if (!in_array($needed, array_keys($privileges))) { //检查权限项是否传满 
                    $err = true;
                }
            }
        }
        /* 是否存在该成员用户 */
        $input_member_arr = array_filter(explode('|', $usergroup_setting['member']));
        if (!$err && !empty($input_member_arr)) {
            /*  {{{ 检查用户名是否存在
             */
            list($table_name,$start_row,$family) = array(__MDB_TAB_USER, '', array('info')); //从row的起点开始 
            try {
                $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
                while (true) {
                    $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                    if (array_filter($get_arr) == null) break;
                    foreach ( $get_arr as $TRowResult ) {
                        $user_arr[] = $TRowResult->row; //获取全部用户的用户名 
                    }
                }
                $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
            } catch (Exception $e) {
                $err = true;
            }
            foreach ($input_member_arr as $member) {
                if (!in_array($member, $user_arr)) {
                    $err = true;
                }
            }
            /*  }}} */
        }
        /* }}} */
        /* {{{ 扫描全部用户组存入usergroup_arr数组
         */
        if (!$err) {
            try {
                $scanner = $GLOBALS['mdb_client']->scannerOpen( __MDB_TAB_USERGROUP, "" , (array)"info" );
                while (true) {
                    $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                    if ($get_arr == null) break;
                    foreach ( $get_arr as $TRowResult ) {
                        $usergroup_arr[]=$TRowResult->row; //获取全部用户组的组名 
                    }
                }
                $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
            } catch (Exception $e) {
                $err = true;
            }
        }
        /* }}} */
        /* {{{ 得到每组的成员存入usergroup_arr2数组
         */
        if (!$err) {
            foreach ((array)$usergroup_arr as $group_name) {
                $tmpArr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_USERGROUP, $group_name, array('member:'));
                $tmpArr = $tmpArr[0]->columns;
                foreach ((array)array_keys($tmpArr) as $tmpMemberName) {
                    list(,$mb) = explode(':', $tmpMemberName);
                    if (!empty($mb)) {
                        $usergroup_arr2[$group_name][]=$mb; //得到全部组和成员用户的数组 
                    }
                }
            }
        }
        /* }}} */
        /* {{{ 修改mdb用户组 
         */
        if (!$err) {
            $table_name = __MDB_TAB_USERGROUP;
            $row_key = $GLOBALS['rowKey']; //以要创建的用户名为rowkey
            $mutations = array(
                new Mutation( array(
                    'column' => "info:desc", //列desc 
                    'value'  => $usergroup_setting['desc'] 
                ) ),
                new Mutation( array(
                    'column' => "info:privilege", //列privilege 
                    'value'  => $usergroup_setting['privilege'] 
                ) )
            );
            //先将成员用户全部删除
            foreach($usergroup_arr2[$GLOBALS['rowKey']] as $ug => $u) {
                $GLOBALS['mdb_client']->deleteAll(__MDB_TAB_USERGROUP, $GLOBALS['rowKey'], "member:{$g}" ); 
            }
            //成员组成列，重新加到mutations
            foreach ($input_member_arr as $member) {
                $mutations[] = new Mutation( array(
                    'column' => "member:$member", //列member:所属的组id  TODO 删除用户名这里对应的列也要维护
                    'value'  => __MONITOR_IS_MEMBER 
                ) );
            }
            try { //thrift出错直接抛出异常需要捕获 
                $GLOBALS['mdb_client']->mutateRow( $table_name, $row_key, $mutations );
            } catch(Exception $e) { //抛出异常返回400 
                echo $e;
                $err = true;
            }
        }
        if (!$err) { //没错则返回200 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
            $usergroup_arr2[$GLOBALS['rowKey']]=$input_member_arr; //修改的替换usergroup_arr2对应元素
            mdbUpdateUserGroupSetting($usergroup_arr2); //更新MDB中相应的配置段落 
            mdbUpdateIni(); //更新MDB中的INI配置文本
        }
        /* }}} */
    }
    break;
case(__OPERATION_DELETE): //删除操作 
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'GET') { 
        if (!canAccess('delete_usergroup')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        /* {{{ 检查用户组是否存在
         */
        $GLOBALS['rowKey'] = urldecode($GLOBALS['rowKey']);
        list($table_name,$start_row,$family) = array(__MDB_TAB_USERGROUP, '', array('info')); //从row的起点开始 
        try {
            $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
            while (true) {
                $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                if (array_filter($get_arr) == null) break;
                foreach ( $get_arr as $TRowResult ) {
                    $usergroup_arr[] = $TRowResult->row; //获取全部用户的用户组名 
                }
            }
            $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
        } catch (Exception $e) {
            $err = true;
        }
        (!in_array($GLOBALS['rowKey'], $usergroup_arr) || $GLOBALS['rowKey']==__MONITOR_DEFAULT_USERGROUP) && $err = true; //用户组名不存在获取要删除默认组则返回错误
        /* }}} */
        /* {{{ 扫描每组的成员存入usergroup_arr2数组
         */
        foreach ((array)$usergroup_arr as $group_name) {
            $tmpArr = $GLOBALS['mdb_client']->getRowWithColumns($table_name, $group_name, array('member:'));
            $tmpArr = $tmpArr[0]->columns;
            foreach ((array)array_keys($tmpArr) as $tmpMemberName) {
                list(,$mb) = explode(':', $tmpMemberName);
                if (!empty($mb)) {
                    $usergroup_arr2[$group_name][]=$mb; //得到全部组和成员用户的数组 
                }
            }
        }
        /* }}} */
        /* {{{ 存在则删除
         */
        try {
            $GLOBALS['mdb_client']->deleteAllRow($table_name, $GLOBALS['rowKey']);
        } catch (Exception $e) {
            $err = true;
        }
        if (!$err) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //删除成功返回200
            unset($usergroup_arr2[$GLOBALS['rowKey']]); //删除的用户组从usergroup_arr2减去 
            mdbUpdateUserGroupSetting($usergroup_arr2); //更新MDB中相应的配置段落 
            mdbUpdateIni(); //更新MDB中的INI配置文本
        }
        /* }}} */
    }
    break;
}
?>
