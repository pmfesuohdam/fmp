<?php
define(__SVNVER, '0001'); // SVN的版本号 
define(__VERSION,'0.0.0.'.__SVNVER);

//process setting
define(__PROC_ROOT,     '/services/sync_deal');
define(__RUN_SUBPATH,   'run');
define(__CONF_SUBPATH,  'conf');
define(__STATUS_SUBPATH,'status');
define(__WORK_SUBPATH,  'work');
define(__BAK_SUBPATH,   'source_bak');
define(__PROC_LIFE,     3600);
define(__SLEEP,         10);

define(__SOURCE_DEF_FILETYPE,'J');//J:bzip2, Z:gzip
define(__SOURCE_SPLIT_TAG1,  ':');
define(__SOURCE_SPLIT_TAG2,  '#');
define(__SOURCE_SPLIT_TAG3,  '|');
define(__SOURCE_SPLIT_TAG4,  ',');

//define(__LOGTAG_READ,    'MadRead');
//define(__LOGTAG_DELIVER, 'MadDeliver');
//define(__LOGTAG_PF,      'pf_monitor');
//define(__LOGTAG_LOG,     'access_monitor');

$array_conf=Array(
    'proc_life'     => __PROC_LIFE,
    'sleep'         => __SLEEP
);

