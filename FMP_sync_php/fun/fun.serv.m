<?php
function uaOffset($crc) {
    $linesize=16;
    $zone_lines=30;
    $length=strlen($crc);
    $section=substr($crc,$length-2);     //9-10 section
    $zone=substr($crc,$length-4,2);      //7-8  zone
    $lnumber=substr($crc,$length-5,1);  //6    position
    $mnumber=substr($crc,$length-6,1);   //5    magic number
    $line=($mnumber>=5)?($lnumber+10):$lnumber;
    $zone_offset=($section*100*$zone_lines+$zone*$zone_lines)*$linesize;
    $ua_offset=$zone_offset+$line*$linesize;
    return array($ua_offset,$zone_offset);
}

function findOffset($fp,$offset,$count=0,$zone_offset=0) {
    global $debug_level;
    $linesize=16;
    if ($fp && $count<=10) {  //最多进行11次检查
        fseek($fp,$offset);
        $info=fread($fp,4);
        $taginfo=unpack("N",$info);
        $tag=$taginfo[1];
        if ($tag===0) {
            //此行为空,返回
            DebugInfo(3,$debug_level,"[fun.findOffset]::[offset:$offset]-[count:$count]-[return]");
            return array($offset,$count);
        } elseif ($count==0) {
            //第一次检查不符合,在该zone第21行进行第二次匹配
            $offset=$zone_offset+20*$linesize;
            DebugInfo(3,$debug_level,"[fun.findOffset]::[offset:$offset]-[count:$count]-[continue]");
            return findOffset($fp,$offset,++$count);
        } else {
            //第n(n<10)次检查不符合,下一行
            $offset+=$linesize;
            DebugInfo(3,$debug_level,"[fun.findOffset]::[offset:$offset]-[count:$count]-[continue]");
            return findOffset($fp,$offset,++$count);
        }
    } else {
        DebugInfo(3,$debug_level,"[fun.findOffset]::[offset:$offset]-[count:$count]-[tag:$tag]-[error]");
        return false;
    }
}
function findUaInfo($tag,$fp,$offset,$zone_offset,$count=0) {
    $linesize=16;
    if ($fp && $count<=10) {
        fseek($fp,$offset);
        $info=fread($fp,$linesize);
        $uninfo=unpack("N*",$info);
        $ua_id=$uninfo[1];$phone_id=$uninfo[2];$uasize=$uninfo[3];$crc_piece=$uninfo[4];
        if ($crc_piece==$tag) {
            return array($ua_id,$phone_id,$uasize,$count);
        } elseif ($count==0) {
            //第一次检查不匹配,都在第20行进行第二次匹配
            $offset=$zone_offset+20*$linesize;
            return findUaInfo($tag,$fp,$offset,$zone,++$count);
        } elseif ($ua_id>0) {
            //该行不为空,但是不匹配,取下一行进行匹配
            $offset+=$linesize;
            return findUaInfo($tag,$fp,$offset,$zone,++$count);
        } else {
            //找不到ua信息
            return false;
        }
    } else {
        return false;
    }
}

function readUaId($ua,$ua_crc=null) {
    if (!empty($ua) || !empty($ua_crc)) {
        $linesize=16;
        $index="/services/serving/2009/wua.idx";
        $ua_crc=empty($ua_crc)?sprintf("%010s",sprintf("%u",crc32(strtolower($ua)))):$ua_crc;
        $tag=substr($ua_crc,0,5);

        $fp=@fopen($index,"r");
        $offset_info=uaOffset($ua_crc);
        $start_offset=$offset_info[0];
        $zone_offset=$offset_info[1];
        echo "[$start_offset]-[$zone_offset]\n";
        $array_return=findUaInfo($tag,$fp,$start_offset,$zone_offset);
        fclose($fp);
    }
    return empty($array_return[0])?0:$array_return[0];
}

function GetUaId($ua_i,$ua_crc_i=null,$tdb_root=__TDB_ROOT_PATH,$sua_subpath=__SUA_ROOT_SUBPATH) {
    if (!empty($ua_i) || !empty($ua_crc_i)) {
        $ua_crc_str=empty($ua_i)?$ua_crc_i:sprintf("%010s",sprintf("%u",crc32(trim($ua_i))));
        $md5checksum=md5($ua_crc_str);
        $head=sprintf("%04s",hexdec(substr($md5checksum, 0, 4)));
        $file_name=substr($head,-2);
        $ua_fullpath=$tdb_root.'/'.$sua_subpath.'/'.$file_name.__TDB_UA_EXT;
        if (file_exists($ua_fullpath) && $fp=@fopen($ua_fullpath,"rb")) {
            flock($fp,LOCK_SH);
            $content=fread($fp,filesize($ua_fullpath));
            $offset=strpos($content,$ua_crc_str);
            if ($offset!==false) {
                fseek($fp,$offset+11);
                $ua_info=fread($fp,__UA_LINSIZE-11);
                if (!empty($ua_info)) {
                    list($ua_id_i,$phone_id_i,$ua_size_i)=explode('|',trim($ua_info));
                }
                unset($ua_info);
            }
            fclose($fp);unset($fp);
        }
    }
    return empty($ua_id_i)?0:$ua_id_i;
}

function ua_modify($ua_m) {
    $patterns[0] = "/\/\*(\w+) /";
    $patterns[1] = "/\*(\w+) /";
    $patterns[2] = "/\*(\w+)/";
    $patterns[3] = "/\/SN(\w+) /";
    $replacements[3] = " ";
    $replacements[2] = " ";
    $replacements[1] = " ";
    $replacements[0] = " ";
    $ua_a = preg_replace($patterns, $replacements, $ua_m);
    return $ua_a;
}

function findSkey($num) {
    $file=__TDB_ROOT_PATH.'/'.__SKEY_INDEX;
    $keylen=strlen('ql4awbums');
    $offset=($num-1)*$keylen;
    if (file_exists($file) && $fp=@fopen($file,"r")) {
        fseek($fp,$offset);
        $key=fread($fp,$keylen);
        fclose($fp);
    }
    return (empty($key))?false:$key;
}

function Authentication($stag_base,$logstamp,$expire=300) {
    global $debug_level;
    if (!empty($stag_base)) {
        $min=substr($stag_base,-1);
        $num=substr($stag_base,0,5);
        $check_str=substr($stag_base,-4,3);
         for ($i=0;$i<=$expire;$i+=60) {
            $time_tmp=$logstamp-$i;
            $min_tmp=date('i',$time_tmp);
            $min_tmp_tail=date('i',$time_tmp)%10;
            if ($min_tmp_tail==$min) {
                $c_min=date('H',$time_tmp)*60+$min_tmp;
                break;
            }
        }
        if (empty($c_min)) {
            DebugInfo(3,$debug_level,"[func.Authentication][$stag_base]::[check_min_error]");
            return false;
        } else {
            $c_key=findSkey($c_min);
            $key_str=substr(md5($num.$c_key),0,3);
            DebugInfo(3,$debug_level,"[func.Authentication][$stag_base]::[check_min:$c_min]-[check_key:$c_key]-[stag_str:$check_str]-[key_str:$key_str]");
            return ($check_str==$key_str)?true:false;
        }
    } else {
        return false;
    }
}

function cmUi($ua,$query_path,$cm_ui_count,$stamp,$dsource) {
    global $debug_level;
    $ua=ua_modify(str_replace('"','',$ua));
    $ua_id=readUaId($ua);
    parse_str($query_path,$mad_query);
    DebugInfo(3,$debug_level,"[func.cmUi]-[".$mad_query[__Q_MSISDN]."]-[".$mad_query[__Q_MID]."]");
    $ui=empty($mad_query[__Q_MSISDN])?$mad_query[__Q_MID]:$mad_query[__Q_MSISDN];
    if (!empty($ua_id) && !empty($ui)) {
        $uinfo_data=__MONITOR_UITAG.'|'.__CARRIER_CM.'|'.$dsource.'|'.$ui.'|'.$ua_id.'|'.$stamp;
        SaveSysLog($uinfo_data);
        return ++$cm_ui_count;
    } else {
        return $cm_ui_count;
    }
}

function getReqUi($ua,$id,$imsi,$ui_count,$stamp,$dsource,$carrier) {
    $ua=ua_modify(str_replace('"','',$ua));
    $ua_id=readUaId($ua);
    $ui=($id==__HTTP_BLANK_TAG)?(empty($imsi)?null:str_replace('"','',$imsi)):str_replace('"','',$id);
    if (!empty($ua_id)) {
        $uinfo_data=__MONITOR_UITAG.'|'.$carrier.'|'.$dsource.'|'.$ui.'|'.$ua_id.'|'.$stamp;
        SaveSysLog($uinfo_data);
        return ++$ui_count;
    } else {
        return $ui_count;
    }
}

function ServUnencrypt($istrings,$offset=0){
    if (!empty($istrings)) {
        $parts_count=base_convert(substr($istrings,$offset++,1),36,10);
        $strings=substr($istrings,$offset);
        if ($parts_count>0 && !empty($strings)) {
            $offset=0;
            for($i=1;$i<=$parts_count;$i++){
                $slen=base_convert(substr($strings,$offset,1),36,10);
                $olen=base_convert(substr($strings,$offset+1,1),36,10);
                $ret[]=sprintf("%0".$olen."s",base_convert(substr($strings,$offset+2,$slen-2),36,10));
                $offset+=$slen;
            }
            return $ret;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

function GetPath($key) {
    $md5checksum=md5($key);
    $head=sprintf("%04s",hexdec(substr($md5checksum, 0, 4)));
    $tail=sprintf("%04s",hexdec(substr($md5checksum, -4)));
    $path=substr($head, -2).'/'.substr($tail, -2);
    return $path;
}

function UpdateTdb($file_fullpath,$file_content) {
    if($fp=@fopen($file_fullpath,"wb")){
        fputs($fp,$file_content);
        ftruncate($fp,strlen($file_content));
        fclose($fp);
        return TRUE;
    } else {
        return FALSE;
    }
}

function GetTDBDetail($fp_t,$linesize_t) {
    flock($fp_t,LOCK_SH);
    $content_t=fread($fp_t,$linesize_t);
    fclose($fp_t);
    if (FALSE!=($str_pos=strpos($content_t,__TDB_SPLIT_TAG_1))) {
        $info_t=substr($content_t,0,$str_pos);
        $detail_t=explode(__TDB_SPLIT_TAG_2,$info_t);
        return $detail_t;
    } else {
        return FALSE;
    }
}

function GetTDBDetail_a($fp_t,$linesize_t,$split_tag1='<|>',$split_tag2='<.>') {
    flock($fp_t,LOCK_SH);
    $content_t=fread($fp_t,$linesize_t);
    fclose($fp_t);
    if (FALSE!=($str_pos=strpos($content_t,$split_tag1))) {
        $info_t=substr($content_t,0,$str_pos);
        $info_d=substr($content_t,$str_pos+strlen($split_tag1));
        $detail_t[]=explode($split_tag2, $info_t);
        $detail_t[]=explode($split_tag2, $info_d);
        return $detail_t;
    } else {
        return false;
    }
}

function logSelect($server_type,$rotate_type,$log_path,$log_file=null,$log_ext,$last_offset,$last_ustamp,$now) {
    /* upload log */
    $last_offset=empty($last_offset)?0:$last_offset;
    $read_offset=0;
    if ($server_type==__SERVER_APACHE || $server_type==__SERVER_LIGHTTPD) {
        $rotate_tag="d";
        $time_duration=86400;
        $log_file_cur=$log_path.date($rotate_type,$now).'.'.$log_ext;
        $log_file_las=$log_path.date($rotate_type,($now-86400)).'.'.$log_ext; //apache log rotate daily
    } elseif ($server_type==__SERVER_NGINX) {
        $rotate_tag="H";
        $time_duration=3600;
        $log_file_cur=$log_file;
        $log_file_las=$log_path.date($rotate_type,($now-3600)).'.'.$log_ext; //apache log rotate hourly 
    }
    if (date($rotate_tag,$last_ustamp)<date($rotate_tag,$now) && abs($now-$last_ustamp)<=$time_duration && file_exists($log_file_las)) {
        //last log file
        $tmp_size=@filesize($log_file_las);
        if ($last_offset<$tmp_size) {
            /** new content **/
            $read_log_file=$log_file_las;
            $read_offset=$last_offset;
        } elseif (file_exists($log_file_cur)) {
            /** no new content **/
            $read_log_file=$log_file_cur;
        }
    } elseif (file_exists($log_file_cur)) {
        $read_log_file=$log_file_cur;
        $file_size=@filesize($read_log_file);
        if ($last_offset<$file_size) {
            $read_offset=$last_offset;
        } elseif ($last_offset==$file_size) {
            $read_offset=false;
        }
    }
    return array($read_log_file,$read_offset);
}

function seleServer($sele_key,$array_sele,$seed_offset=0,$seed_len=4) {
    $sele_base=md5($sele_key);
    $sele_sum=count($array_sele);
    $sele_num=hexdec(substr($sele_base,$seed_offset,$seed_len))%$sele_sum;
    return empty($array_sele[$sele_num])?false:$array_sele[$sele_num];
}

/* 获取缓存信息 */
function getCacheInfo($cachekey,$array_server,$connect='tcp') {
    global $debug_level;

    $cache_server=seleServer($cache_key,$array_server);
    $cache=false;
    $tried=0;
    while($cache===false && $tried<=1) {
        //重连机制
        $cache_socket=_get_socket($cache_server,$connect);
        $cache=mcd_query(__METHOD_GET,$cache_socket,$cachekey,null,null,$connect);
        fclose($cache_socket);
        $tried++;
    }

    DebugInfo(4,$debug_level,"[fun.getCacheInfo]::[key:$cachekey]-[cache:$cache]-[server:$cache_server]-[try:$tried]");
    return $cache;
}
function saveCacheInfo($cachekey,$cache_data,$exptime,$array_server,$connect='tcp') {
    global $debug_level;

    $cache_server=seleServer($cache_key,$array_server);
    $saved=false;
    $tried=0;
    while($saved===false && $tried<=1) {
        $cache_socket=_get_socket($cache_server,$connect);
        $saved=mcd_query(__METHOD_SET,$cache_socket,$cachekey,$cache_data,$exptime,$connect);
        fclose($cache_socket);
        $tried++;
    }
    DebugInfo(3,$debug_level,"[fun.saveCacheInfo]::[key:$cachekey]-[cache:$cache_data]-[exptime:$exptime]-[save:$cache_server]-[tried:$tried]");
    return $saved;
}

function deleteCache($cachekey,$array_server,$connect='tcp') {
    global $debug_level;

    $cache_server=seleServer($cache_key,$array_server);
    $deleted=false;
    $tried=0;
    while($deleted===false && $tried<=1) {
        $cache_socket=_get_socket($cache_server,$connect);
        $saved=mcd_query(__METHOD_DELETE,$cache_socket,$cachekey,null,null,$connect);
        fclose($cache_socket);
        $tried++;
    }
    DebugInfo(3,$debug_level,"[fun.deleteCache]::[key:$cachekey]-[delete:$cache_server]-[tried:$tried]");
    return $deleted;
}

function incrCounter($counterkey,$step,$exptime,$array_server,$connect='tcp') {
    global $debug_level;

    $counter_server=seleServer($counter_key,$array_server);
    $count=false;
    $tried=0;
    while($count===false && $tried<=1) {
        $counter_socket=_get_socket($counter_server,$connect);
        $count=mcd_query(__METHOD_INCR,$counter_socket,$counterkey,$step,$exptime,$connect);
        fclose($counter_socket);
        $tried++;
    }
    DebugInfo(3,$debug_level,"[fun.incrCounter][$stag_base]::[key:$counterkey]-[step:$step]-[count:$count]-[exptime:$exptime]-[save:$counter_server]-[tried:$tried]");
    return $count;
}
?>
