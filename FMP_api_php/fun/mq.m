<?php
/*
  +----------------------------------------------------------------------+
  | Name:mq.m
  +----------------------------------------------------------------------+
  | Comment:消息队列的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create: 2012年 7月26日 星期四 14时21分11秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-07-26 15:53:40
  +----------------------------------------------------------------------+
 */
/**
 *@brief 打开消息队列服务器连接
 */
function openMq() {
    // redis
    $single_redis_server = array(
        'host'     => __REDIS_HOST,
        'port'     => __REDIS_PORT,
        'database' => 15
    );
    try {
        $GLOBALS['redis_client'] = new Predis_Client($single_redis_server);
        $GLOBALS['redis_client']->select(__MQ_TABLE);
        DebugInfo("[openMq][host:{$single_redis_server['host']}][port:{$single_redis_server['port']}][table:".__MQ_TABLE."][ok]",3);
    } catch (Exception $e) {
        DebugInfo("[openMq][open redis got err][".$e->getMessage()."]",1);
        return false;
    }
}

/**
 *@brief 关闭消息队列服务器连接
 */
function closeMq() {
    try {
        $GLOBALS['redis_client']->quit();
        DebugInfo("[closeMdb][ok]",3);
    } catch (Exception $e) {
        DebugInfo("[closeMq][close redis error][".$e->getMessage()."]",1);
        return false;
    }
}

/**
 *@brief 保存内容到消息
 */
function saveMq($content) {
    try {
        $GLOBALS['redis_client']->select(__MQ_TABLE);
        $GLOBALS['redis_client']->rpush(__MQ_KEY, $content);
        DebugInfo("[saveMq][save redis queue ok][key:".__MQ_KEY."][value:{$content}]",3);
    } catch (Exception $e) {
        DebugInfo("[saveMq][save redis error][".$e->getMessage()."]",1);
        return false;
    }
}

/**
 *@brief 保存ProvideIp变化的消息
 *@param @server 服务器
 *@param @pip    未修改前的ip
 *@param @cip    当前设置的provideIP 
 *@param @location 地区
 *@param @carrier 运营商
 */
function saveProviceIpChangeMessage($server,$pip,$cip,$location,$carrier) {
     try {
         DebugInfo("[saveProviceIpChangeMessage][server:{$server}][prevIp:{$pip}][currentIp:{$cip}][location:{$location}][carrier:$carrier]", 3);
         if ($pip!=$cip) {
             // 获取服务器状态
             $arr = $GLOBALS['mdb_client']->get(__MDB_TAB_HOST,$server,'info:status');
             $serveralive = $arr[0]->value>0?1:0;
             DebugInfo("[saveProviceIpChangeMessage][server status:$serveralive]",3);
             // 获取load信息
             $arr = $GLOBALS['mdb_client']->getRowWithColumns(__MDB_TAB_SERVER,$server,array('info:'));
             $res = $arr[0]->columns;
             $serverload = $res['info:generic_summary_load']->value;
             openMq();
             //{opt}|edgesserver|provide_ip|serveralive|serverload|new_ip|carrier|location|timestamp
             saveMq("SC|{$server}|{$pip}|{$serveralive}|{$serverload}|{$cip}|{$carrier}|{$location}|".time());
             closeMq();
         }
     } catch (Exception $e) {
         DebugInfo("[saveProviceIpChangeMessage][err:".$e->getMessage()."]", 3);
         closeMq();
     }
} 
?>
