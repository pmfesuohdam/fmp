<?php
/*
  +----------------------------------------------------------------------+
  | Name: userFun.m
  +----------------------------------------------------------------------+
  | Comment: 处理用户的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 13:53:45
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; //默认返回400 
header("Content-type: application/json; charset=utf-8");
$valid_key = array('realname', 'email', 'passwd', 'mailtype', 'desc');  //合法的POST的key 

switch ($GLOBALS['operation']) {
case(__OPERATION_CREATE): //创建一个新的用户组 
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'POST') { 
        if (!canAccess('create_user')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        /* 检查是否符合数据格式 */
        foreach ($valid_key as $user_key) {
            if (!in_array($user_key, array_keys($_POST))) { //对少传判断为非法 
                $err = true;
                DebugInfo("[$moduleName][create user][check input err]", 3);
            } else {
                $user_setting[$user_key] = $_POST[$user_key];
                DebugInfo("[$moduleName][create user][check input ok]", 3);
            }
        }
        /* {{{ 检查用户名是否存在
         */
        list($table_name,$start_row,$family) = array(__MDB_TAB_USER, '', array('info')); //从row的起点开始 
        try {
            $scanner = $GLOBALS['mdb_client']->scannerOpen($table_name, $start_row , $family);
            while (true) {
                $get_arr = $GLOBALS['mdb_client']->scannerGet($scanner);
                if ($get_arr == null) break;
                foreach ( $get_arr as $TRowResult ) {
                    $tmpArr = (array)$TRowResult->columns;
                    $user_arr[$TRowResult->row]['mail_type'] = $tmpArr['info:mailtype']->value; //获取全部用户的用户名 
                    $user_arr[$TRowResult->row]['email'] = $tmpArr['info:email']->value; 
                }
            }
            $GLOBALS['mdb_client']->scannerClose($scanner); //关闭scanner 
        } catch (Exception $e) {
            $err = true;
        }
        in_array($GLOBALS['rowKey'], array_keys($user_arr)) && $err = true; //用户名存在返回409
        $GLOBALS['httpStatus'] = __HTTPSTATUS_METHOD_CONFILICT;
        /* }}} */
        /* {{{ 如果不存在则添加
         */
        /* 用户名格式是数字字母下划线或者中划线 */
        $err = ereg("^[0-9a-zA-Z\_\-]*$", $GLOBALS['rowKey']) ?false :true;
        if (!$err) {
            $row_key = $GLOBALS['rowKey']; //以要创建的用户名为rowkey
            $mutations = array(
                new Mutation( array(
                    'column' => "info:realname", //列realname 
                    'value'  => $user_setting['realname'] 
                ) ),
                new Mutation( array(
                    'column' => "info:email", //列email 
                    'value'  => $user_setting['email'] 
                ) ),
                new Mutation( array(
                    'column' => "info:passwd", //列passwd 
                    'value'  => $user_setting['passwd'] 
                ) ),
                new Mutation( array(
                    'column' => "info:mailtype", //列mailtype 
                    'value'  => $user_setting['mailtype'] 
                ) ),
                new Mutation( array(
                    'column' => "info:desc", //列desc 
                    'value'  => $user_setting['desc'] 
                ) ),
                new Mutation( array(
                    'column' => "groupid:rd", //列group 
                    'value'  => __MONITOR_IS_MEMBER  //XXX 这里的列要修改 
                ) )
            );
            try { //thrift出错直接抛出异常需要捕获 
                $GLOBALS['mdb_client']->mutateRow($table_name, $row_key, $mutations);
            } catch(Exception $e) { //抛出异常返回400 
                $err = true;
            }
        }
        /* }}} */
        if (!$err) { //没错则返回200 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK;
            $user_arr[$GLOBALS['rowKey']]['mail_type'] = $user_setting['mailtype']; //加入user_arr 
            $user_arr[$GLOBALS['rowKey']]['email'] = $user_setting['email'];
            mdbUpdateUserSetting($user_arr); //更新MDB中相应的配置段落 
            mdbUpdateIni(); //更新MDB中的INI配置文本
        }
    }
    break;
case(__OPERATION_READ): //查询操作 
    if ( in_array($GLOBALS['selector'], array(__SELECTOR_MASS,__SELECTOR_MASSMEMBER)) && 
        $_SERVER['REQUEST_METHOD'] == 'GET') {  //查询全部 
        if ($GLOBALS['selector']==__SELECTOR_MASS && !canAccess('read_userList')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        /* {{{ 从MDB中获取全部用户
         */
        list($table_name,$start_row,$family) = array(__MDB_TAB_USER, '', array('info')); //从row的起点开始 
        try {
            $scanner = $GLOBALS['mdb_client']->scannerOpen($table_name, $start_row , $family);
            while (true) { //TODO 这里可能会发生超时，需要加时限 
                $get_arr = $GLOBALS['mdb_client']->scannerGet($scanner);
                if ($get_arr == null) break;
                foreach ( $get_arr as $TRowResult ) {
                    $user = $TRowResult->row; //以用户名为rowkey 
                    /* {{{ 取出实际用户名和电子邮件
                     */
                    $column = $TRowResult->columns;
                    foreach ($column as $family_column=>$Tcell) {
                        switch ($family_column) {
                        case('info:realname'):
                            $realname = $Tcell->value;
                            break;
                        case('info:email'):
                            $email = $Tcell->value;
                            break;
                        case('info:desc'):
                            $dsc = $Tcell->value;
                        }
                    }
                    $canEditAdminUser=0;
                    if ($_COOKIE['__CO_MMSUNAME']==__MONITOR_DEFAULT_USER) {
                        $canEditAdminUser=1;
                    }
                    $can_del = $user==__MONITOR_DEFAULT_USER ?$canEditAdminUser :1; //为1可以删除，为0默认用户不能删除 
                    $str[$user] = array($realname, $email, $dsc, $can_del); //组成用户名为key的数组 
                    uksort($str, 'default_admin_cmp');
                    /* }}} */
                }
            }
            $GLOBALS['mdb_client']->scannerClose($scanner); //关闭scanner 
        } catch (Exception $e) {
            $err = true;
        }
        /* }}} */
        if (!$err) { 
            echo json_encode($str); //返回json 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //查询成功返回200 
        }
    }
    elseif ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'GET') {  //查询单个 
        /* {{{ 从MDB中获取单个用户
         */
        list($table_name,$row_key) = array(__MDB_TAB_USER, $GLOBALS['rowKey']); //以用户名为rowkey 
        try {
            $res = $GLOBALS['mdb_client']->getRow($table_name, $row_key);
        } catch (Exception $e) {
            $err = true;
        }
        $res = (array)$res[0]; //得到二维数组下标为row和columns 
        if (empty($res)) {
            $err = true;
        } else {
            $str = array( //组织用户信息数据 
                "realname" => $res['columns']['info:realname']->value,
                "email"    => $res['columns']['info:email']->value,
                "passwd"   => $res['columns']['info:passwd']->value,
                "mailtype" => $res['columns']['info:mailtype']->value,
                "desc"     => $res['columns']['info:desc']->value
            );
        }
        /* }}} */
        if (!$err) {
            echo json_encode($str); //返回json 
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //查询成功返回200
        }
    }
    break;
case(__OPERATION_UPDATE): //更新单个用户操作 
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'POST') {
        if (!canAccess('update_user')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        /* 检查是否符合数据格式 */
        foreach ($valid_key as $user_key) {
            if (!in_array($user_key, array_keys($_POST))) { //对少传判断为非法 
                $err = true;
            } else {
                $user_setting[$user_key] = $_POST[$user_key];
            }
        }
        /* {{{ 检查用户名是否存在
         */
        list($table_name,$start_row,$family) = array(__MDB_TAB_USER, '', array('info')); //从row的起点开始 
        try {
            $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
            while (true) {
                $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                if ($get_arr == null) break;
                foreach ( $get_arr as $TRowResult ) {
                    $tmpArr = (array)$TRowResult->columns;
                    $user_arr[$TRowResult->row]['mail_type'] = $tmpArr['info:mailtype']->value; //获取全部用户的用户名 
                    $user_arr[$TRowResult->row]['email'] = $tmpArr['info:email']->value; 
                }
            }
        } catch (Exception $e) {
            $err = true;
        }
        $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
        !in_array($GLOBALS['rowKey'], array_keys($user_arr)) && $err = true; //用户名不存在返回错误
        /* }}} */
        /* {{{ 存在则更新用户数据
         */
        if (!$err) {
            $row_key = $GLOBALS['rowKey']; //以修改用户数据的用户名为rowkey
            $mutations = array(
                new Mutation( array(
                    'column' => "info:realname", //列realname 
                    'value'  => $user_setting['realname'] 
                ) ),
                new Mutation( array(
                    'column' => "info:email", //列email 
                    'value'  => $user_setting['email'] 
                ) ),
                new Mutation( array(
                    'column' => "info:passwd", //列passwd 
                    'value'  => $user_setting['passwd'] 
                ) ),
                new Mutation( array(
                    'column' => "info:mailtype", //列mailtype 
                    'value'  => $user_setting['mailtype'] 
                ) ),
                new Mutation( array(
                    'column' => "info:desc", //列desc 
                    'value'  => $user_setting['desc'] 
                ) ),
                new Mutation( array(
                    'column' => "groupid:rd", //列group  //XXX这里的列要修改 
                    'value'  => __MONITOR_IS_MEMBER 
                ) )
            );
            try { //thrift出错直接抛出异常需要捕获 
                $GLOBALS['mdb_client']->mutateRow( $table_name, $row_key, $mutations );
            } catch(Exception $e) { //抛出异常返回400 
                $err = true;
            }
        }
        /* }}} */
        if (!$err) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_RESET_CONTENT; //更新成功返回205
            $user_arr[$GLOBALS['rowKey']]['mail_type']=$user_setting['mailtype'];
            $user_arr[$GLOBALS['rowKey']]['email']=$user_setting['email'];
            mdbUpdateUserSetting($user_arr); //更新MDB中相应的配置段落 
            mdbUpdateIni(); //更新MDB中的INI配置文本
        }
    }
    break;
case(__OPERATION_DELETE): //删除一个用户 
    if ($GLOBALS['selector'] == __SELECTOR_SINGLE && $_SERVER['REQUEST_METHOD'] == 'GET') {
        if (!canAccess('delete_user')) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
            return;
        }
        /* {{{ 检查用户名是否存在
         */
        list($table_name,$start_row,$family) = array(__MDB_TAB_USER, '', array('info')); //从row的起点开始 
        try {
            $scanner = $GLOBALS['mdb_client']->scannerOpen( $table_name, $start_row , $family );
            while (true) {
                $get_arr = $GLOBALS['mdb_client']->scannerGet( $scanner );
                if ($get_arr == null) break;
                foreach ( $get_arr as $TRowResult ) {
                    $tmpArr = (array)$TRowResult->columns;
                    $user_arr[$TRowResult->row]['mail_type'] = $tmpArr['info:mailtype']->value; //获取全部用户的用户名 
                    $user_arr[$TRowResult->row]['email'] = $tmpArr['info:email']->value; 
                }
            }
            $GLOBALS['mdb_client']->scannerClose( $scanner ); //关闭scanner 
        } catch (Exception $e) {
            $err = true;
        }
        (!in_array($GLOBALS['rowKey'], array_keys($user_arr)) || $GLOBALS['rowKey']==__MONITOR_DEFAULT_USER) && $err = true; //用户名不存在获取要删除默认管理员则返回错误
        /* }}} */
        /* {{{ 存在则删除该用户
         */
        try {
            $GLOBALS['mdb_client']->deleteAllRow($table_name, $GLOBALS['rowKey']);
        } catch (Exception $e) {
            $err = true;
        }
        /* }}} */
        /* {{{ 删除用户组中已经删除掉了的成员用户
         */
        /* 扫描全部用户组存入usergroup_arr数组 */
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
        /* 得到每组的成员存入usergroup_arr2数组 */
        if (!$err) {
            foreach ((array)$usergroup_arr as $group_name) {
                $tmpArr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_USERGROUP, $group_name, array('member:'));
                $tmpArr = $tmpArr[0]->columns;
                foreach ((array)array_keys($tmpArr) as $tmpMemberName) {
                    list(,$mb) = explode(':', $tmpMemberName);
                    if (!empty($mb)) {
                        $usergroup_arr2[$group_name][] = $mb; //得到全部组和成员用户的数组 
                    }
                }
            }
        }
        /* 最后删除组内该用户 */
        foreach ($usergroup_arr2 as $group => $members) {
            if (in_array($GLOBALS['rowKey'], $members)) {
                //先将成员用户全部删除
                $GLOBALS['mdb_client']->deleteAll(__MDB_TAB_USERGROUP, $group, "member:{$GLOBALS['rowKey']}" ); 
            }
        }
        /* }}} */
        if (!$err) {
            $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //删除成功返回200
            unset($user_arr[$GLOBALS['rowKey']]); //从user_arr移除该用户 
            mdbUpdateUserSetting($user_arr); //更新MDB中相应的配置段落 
            mdbUpdateIni(); //更新MDB中的INI配置文本
        }
    }
    break;
}
?>
