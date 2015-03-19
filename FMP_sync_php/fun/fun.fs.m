<?php
function makeDir($path,$mode="0755",$depth=0,$type='d') {
    $input_type=empty($type)?'d':strtolower($type);
    $path=($input_type==='d')?$path:dirname($path);
    $depth--;
    $subpath=dirname($path);
    if (!file_exists($path)) {
        if ($depth>0 && (!empty($subpath) || $subpath!='.')) {
            makeDir($subpath,$mode,$depth);
        }
        exec("/bin/mkdir -p -m $mode $path");
    } elseif (is_dir($path)) {
        return true;
    } else {
        return false;
    }
}
function readInfo($last_ustamp=0,$last_offset=null,$last_inode=null,$now,$log_file='counter.log',$log_path='/services/serving_log',$rotate_type=null,$max_duration=86400,$roll_back=true) {
    global $process_name;
    global $debug_level;
    $access_log_file=$log_path.'/'.$log_file;
    if (file_exists($access_log_file)) {
        $read_stat=true;
        $cur_inode=fileinode($access_log_file);
        $cur_fsize=filesize($access_log_file);
        $last_inode=empty($last_inode)?$cur_inode:$last_inode;
        if ($last_inode==$cur_inode) {
            $sys_data="[$process_name]::[last_inode:$last_inode]-[cur_inode:$cur_inode]-[same]";
            DebugInfo(3,$debug_level,$sys_data);
            if ($last_offset<$cur_fsize) {
                $sys_data="[$process_name]::[last:$last_offset]-[now:$cur_fsize]-[has_new_log]";
                DebugInfo(3,$debug_level,$sys_data);
                $read_log_file=$access_log_file;
                $read_offset=$last_offset;
            } elseif ($last_offset==$cur_fsize) {
                $sys_data="[$process_name]::[last:$last_offset]-[now:$cur_fsize]-[no_new_log]";
                DebugInfo(3,$debug_level,$sys_data);
                $read_stat=false;
            } else {
                $sys_data="[$process_name]::[last:$last_offset]-[now:$cur_fsize]-[error]";
                DebugInfo(0,$debug_level,$sys_data);
                return false;
            }
        } elseif ($roll_back) {
            $sys_data="[$process_name]::[last_inode:$last_inode]-[cur_inode:$cur_inode]-[diff]";
            DebugInfo(3,$debug_level,$sys_data);
            $read_duration=abs($now-$last_ustamp);
            if ($read_duration<=$max_duration) {
                $sys_data="[$process_name]::[rotate_type:$rotate_type]";
                DebugInfo(3,$debug_level,$sys_data);
                if (empty($rotate_type)) {
                    $last_access_log_file=$log_path.'/'.$log_file.'.0';
                    $last_access_inode=fileinode($last_access_log_file);
                    if ($last_inode==$last_access_inode && $last_offset<filesize($last_access_log_file)) {
                        $read_log_file=$last_access_log_file;
                        $read_offset=$last_offset;
                    } else {
                        $read_log_file=$access_log_file;
                        $read_offset=0;
                    }
                } else {
                    $last_access_log_name=$log_file.'.0';
                    $last_access_log_ball=($rotate_type=='Z')?"$log_file.0.gz":"$log_file.0.bz2";
                    $last_access_log_fp="$log_path/$last_access_log_ball";
                    $last_access_log_file=$log_file.'.'.fileinode($last_access_log_fp);
                    $sys_data="[$process_name]::[fp:$last_access_log_fp]-[file:$last_access_log_file]-[ball:$last_access_log_ball]";
                    DebugInfo(3,$debug_level,$sys_data);
                    if (file_exists($last_access_log_fp) && !file_exists($last_access_log_file)) {
                        system('/bin/cp '.$last_access_log_fp.' .',$cp_stat);
                        if ($cp_stat==0) {
                            if ($rotate_type=='Z') system("/usr/bin/gzip -df ".$last_access_log_ball,$up_stat);
                            else system("/usr/bin/bzip2 -df ".$last_access_log_ball,$up_stat);
                            if ($up_stat==0 && file_exists($last_access_log_name)) {
                                /** rename **/
                                exec('/bin/mv '.$last_access_log_name.' '.$last_access_log_file);
                            }
                        }
                    } elseif (!file_exists($last_access_log_fp)) {
                        $sys_data="[$process_name]::[old_log_fp:$last_access_log_fp]-[not_exists]-[exit]";
                        DebugInfo(0,$debug_level,$sys_data);
                        return false;
                    }
                    if (file_exists($last_access_log_file)) {
                        $last_access_log_size=filesize($last_access_log_file);
                        $sys_data="[$process_name]::[last_off:$last_offset]-[old_log_size:$last_access_log_size]";
                        DebugInfo(3,$debug_level,$sys_data);
                        if ($last_offset<$last_access_log_size) {
                            /** new content **/
                            $sys_data="[$process_name]::[old_file_in_work_dir:$last_access_log_file]-[has_new_content]-[read]";
                            DebugInfo(3,$debug_level,$sys_data);
                            $read_log_file=$last_access_log_file;
                            $read_offset=$last_offset;
                        } else {
                            /** no new content,clear work path **/
                            $sys_data="[$process_name]::[old_file_in_work_dir:$last_access_log_file]-[no_new_content]-[delete]";
                            DebugInfo(3,$debug_level,$sys_data);
                            exec("/bin/rm -rf ".$last_access_log_file);
                            $read_log_file=$access_log_file;
                            $read_offset=0;
                        }
                    } else {
                        $sys_data="[$process_name]::[file:$last_access_log_file]-[not_exists]-[exit]";
                        DebugInfo(0,$debug_level,$sys_data);
                        return false;
                    }
                }
            } else {
                $sys_data="[$process_name]::[read_duration:$read_duration]-[max_duration:$max_duration]-[too_log]";
                DebugInfo(0,$debug_level,$sys_data);
                $read_log_file=$access_log_file;
                $read_offset=0;
            }
        } else {
            $read_log_file=$access_log_file;
            $read_offset=0;
        }
        $readinfo['file']=empty($read_log_file)?$access_log_file:$read_log_file;
        $readinfo['read']=$read_stat;
        $readinfo['offset']=$read_offset;
        return $readinfo;
    } else {
        return false;
    }
}

if (!function_exists('file_put_contents')) {
    function file_put_contents($file,$content) {
        $fh = fopen($file, "wb");
        fwrite($fh, $content);
        fclose($fh);
    }
}
?>
