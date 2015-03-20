<?php
/*
  +----------------------------------------------------------------------------+
  | Name:sync.m
  +----------------------------------------------------------------------------+
  | Comment:同步fb数据到fmp
  +----------------------------------------------------------------------------+
  | Author:Yinjia
  +----------------------------------------------------------------------------+
  | Create:2015-03-19 17:23:10
  +----------------------------------------------------------------------------+
  | Last Modified: 2015-03-19 17:29:15
  +----------------------------------------------------------------------------+
 */
include_once('inc/inc.sync.m');
include_once('fun/fun.common.m');
include_once('fun/fun.fs.m');
include_once('fun/fun.mcd.m');
include_once('GPLlib/simple_html_dom.php');
list($process_name,$ext_name)=explode('.',basename(__FILE__));
include_once('modules/sync_init.m');

chdir($work_dir);
while ($run) {
    $now=time();

    /*** read status file***/
    if ($fp=@fopen($status_file,"rb")) {
        flock($fp,LOCK_SH);
        $last_status=trim(fread($fp,filesize($status_file)));
        list($last_ustamp,$last_offset,$last_inode)=explode('|',$last_status);
        fclose($fp);
        $debug_data="[$process_name]::[last_time:".date("Y-m-d H:i:s",$last_ustamp)."]-[last_offset:$last_offset]-[last_inode:$last_inode]";
        DebugInfo(1,$debug_level,$debug_data);
    }

    //build upload string
    $upload_str='';

    $query="select * from t_fb_account;";
    include(dirname(__FILE__).'/inc/conn.m');
    if ( !($result=$link->query($query)) ) {
        $debug_data="[$process_name]::[run query fail]";
        DebugInfo(1,$debug_level,$debug_data);
    }
    $rows=[];
    while ($row=mysqli_fetch_assoc($result)) {
        if ($row['want_sync']==1) {
            $rows[]=$row;
            $debug_data="[$process_name]::[found sync requirement]-[ad account id:{$row['ad_account_id']}]";
            DebugInfo(1,$debug_level,$debug_data);
        }
    }
    $businessidArr=[];
    foreach($rows as $syncRow){
        //已知一个广告帐号，通过对应access_token查询它的business，然后获取他的主页并保存下来
        $debug_data="[$process_name]::[sync]-[ad account id:{$syncRow['ad_account_id']}]-[acess token:{$syncRow['access_token']}]";
        DebugInfo(4,$debug_level,$debug_data);
        //根据access token查询
        $visit_fb_url=__FB_GRAPH."/me/businesses?access_token={$syncRow['access_token']}";
        $res=curlGet($visit_fb_url);
        if ($res['code']=='200') {
            $debug_data="[$process_name]::[sync]-[url:{$visit_fb_url}]-[visit ok]-[body:{$res['body']}]";
            $data=json_decode($res['body'],true);
            foreach($data['data'] as $businessInfo) {
                if ( !in_array($businessInfo['id'],$businessidArr) ) {
                    $businessidArr[]=$businessInfo['id'];
                    $debug_data="[$process_name]::[sync]-[business name:{$businessInfo['name']}]-[business id:{$businessInfo['id']}]-[added]";
                    DebugInfo(3,$debug_level,$debug_data);
                    //获取主页信息
                    if ( empty($businessInfo['id']) ) {
                        continue;
                    }
                    $visit_fb_url2=__FB_GRAPH."/{$businessInfo['id']}?fields=primary_page&access_token={$syncRow['access_token']}";
                    $res2=curlGet($visit_fb_url2);
                    if ($res2['code']=='200') {
                        $primary_page_info=json_decode($res2['body'],true);
                        $primary_page_info=$primary_page_info['primary_page'];
                        $res3=curlGet(__FB_GRAPH."/{$primary_page_info['id']}/picture",true);
                        $query="insert into t_fb_business(business_id,business_name,primary_page_category,primary_page_name,primary_page_id,profile_pic) values({$businessInfo['id']},'{$businessInfo['name']}','{$primary_page_info['category']}','{$primary_page_info['name']}',{$primary_page_info['id']},'".addslashes($res3['body'])."') on duplicate key update business_name='{$businessInfo['name']}',primary_page_category='{$primary_page_info['category']}',primary_page_name='{$primary_page_info['name']}',primary_page_id={$primary_page_info['id']},profile_pic='".addslashes($res3['body'])."';";
                        if ($result!=$link->query($query)) {
                            $debug_data="[$process_name]::[sync]-[update business fail]-[cause:".mysqli_error($link)."]";
                            DebugInfo(2,$debug_level,$debug_data);
                        } else {
                            $debug_data="[$process_name]::[sync]-[update business ok]";
                            DebugInfo(3,$debug_level,$debug_data);
                        }
                    } else {
                        $debug_data="[$process_name]::[sync]-[visit fail]-[url:{$visit_fb_url2}]";
                        DebugInfo(2,$debug_level,$debug_data);
                    }
                } else {
                    $debug_data="[$process_name]::[sync]-[business name:{$businessInfo['name']}]-[business id:{$businessInfo['id']}]-[no need add]";
                    DebugInfo(3,$debug_level,$debug_data);
                }
            }
        } else {
            $debug_data="[$process_name]::[sync]-[visit fail]-[url:{$visit_fb_url}]";
            DebugInfo(2,$debug_level,$debug_data);
        }
    }
    @mysqli_close($link);

    //update status
    $tmp_status="$now|$cur_offset|$read_inode";
    if ($fp=@fopen($status_file,"wb")) {
        fputs($fp,$tmp_status);
        ftruncate($fp,strlen($tmp_status));
        fclose($fp);
    }

    //continue?
    if (!$daemon_stat || $proc_life<=($process_old=$now-$start_time)) {
        $run=false;
    } else {
        sleep($sleep);
    }
}
?>
