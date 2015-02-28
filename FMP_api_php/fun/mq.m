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

?>
