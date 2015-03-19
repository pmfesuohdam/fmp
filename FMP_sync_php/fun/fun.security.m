<?php
/*
  +----------------------------------------------------------------------+
  | Name:安全函数
  +----------------------------------------------------------------------+
  | Comment:
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:2011年11月21日 星期一 14时36分07秒 CST 
  +----------------------------------------------------------------------+
  | Last Modified:2011-11-21 14:36:39
  +----------------------------------------------------------------------+
 */

/**
 *@brief 从文件内读取指定行
 */
function readLine($linenum,$fh) {
    global $debug_level,$process_name,$module_name;
    DebugInfo(5,$debug_level,"[$process_name][$module_name]::[in readLine]");
    $line = fgets($fh, 4096);
    $pos = -1;
    $i = 0;
    $time = time();
    while (!feof($fh) && $i<($linenum-1)) {
        if (time()-$time>3) { // 因为某种原因处理太慢则跳过 
            $i ++;
        }
        DebugInfo(6,$debug_level,"[$process_name][$module_name]::[i:$i][linenum:$linenum]");
        $char = fgetc($fh);
        if ($char != "\n" && $char != "\r") {
            fseek($fh, $pos, SEEK_SET);
            $pos++;
        }
        else $i++; 
    }
    $line = fgets($fh);
    return $line;
}

/**
 *@brief 对于编译不支持直接array_filter的变通方案
 */
function notEmpty($a) {
    $return = empty($a) ?false :true;
    return $return;
}

/**
 *@brief 检查文件是否为二进制
 *@return 是二进制返回true，否则返回false
 */
function isBinaryFile($file) {
    $x = file_get_contents($file);
    $len = strlen($x);
    for ($i=0;$i<$len;$i++) {
        if (ord($x{$i})<32 && ord($x{$i}) != 9 && ord($x{$i}) != 10 && ord($x{$i}) != 13) {
            echo $x{$i};
            $isBinary = true;
            break;
        }
    }
    return $isBinary;
}

/**
 *@brief 获取文件的umask
 *@param $fname 文件名
 *@return 文件存在则返回文件的umask，不存在返回false
 */
function getUmask($fname) {
    global $debug_level,$process_name,$module_name;
    if (!is_file($fname)) {
        return false;
    }
    $ret = substr(sprintf('%o', fileperms($fname)), -4);
    DebugInfo(6,$debug_level,"[$process_name][$module_name]::[i:$i][$fname:$ret]");
    return $ret;
}

/**
 *@brief 判断用户是否已经被禁用,该用户还持有shell
 *param $m /etc/passwd的内容
 *@return 禁用返回true,否则返回false 
 */
function userLockHasShell($m) {
    global $debug_level,$process_name,$module_name;
    $arr = explode("\n", $m);
    foreach ($arr as $line) {
        if (false!=strstr($line,'*LOCKED*')) {
            $arr = explode(':',$line);
            $shell=end($arr);
            DebugInfo(5,$debug_level,"[$process_name][$module_name]::[shellname:$shell]");
            return true;
        }
    }
    return false;
}
?>
