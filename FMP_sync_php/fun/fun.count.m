<?php
function tdbDefine($carrier_define,$system_define) {
    foreach ($system_define as $system=>$array_sdf) {
        foreach ($carrier_define as $carrier=>$array_province) {
            $min_offset=0; $half_offset=0; $daily_offset=0;
            $min_define=str_pad(null,__TDB_DEF_LS-__TDB_LF_SIZE,'0').__TDB_LF;
            $half_define=str_pad(null,__TDB_DEF_LS-__TDB_LF_SIZE,'0').__TDB_LF;
            $daily_define=str_pad(null,__TDB_DEF_LS-__TDB_LF_SIZE,'0').__TDB_LF;
            foreach ($array_province as $province=>$array_collen) {
                //min province define
                $min_imp_len=($array_sdf[__DEF_IMP_POS]===true)?$array_collen[__DEF_MIN_IMP_POS]:0;
                $min_cli_len=($array_sdf[__DEF_CLI_POS]===true)?$array_collen[__DEF_MIN_CLI_POS]:0;
                $min_offset+=$min_imp_len+$min_cli_len;
                //half province define
                $half_imp_len=($array_sdf[__DEF_IMP_POS]===true)?$array_collen[__DEF_HALF_IMP_POS]:0;
                $half_cli_len=($array_sdf[__DEF_CLI_POS]===true)?$array_collen[__DEF_HALF_CLI_POS]:0;
                $half_offset+=$half_imp_len+$half_cli_len;
                //daily province define
                $daily_imp_len=($array_sdf[__DEF_IMP_POS]===true)?$array_collen[__DEF_DAILY_IMP_POS]:0;
                $daily_cli_len=($array_sdf[__DEF_CLI_POS]===true)?$array_collen[__DEF_DAILY_CLI_POS]:0;
                $daily_offset+=$daily_imp_len+$daily_cli_len;

                //build define string
                $define_pos=$_SERVER['province_position'][$province]*2;
                $min_define[$define_pos]=dechex($min_imp_len);
                $min_define[$define_pos+1]=dechex($min_cli_len);
                $half_define[$define_pos]=dechex($half_imp_len);
                $half_define[$define_pos+1]=dechex($half_cli_len);
                $daily_define[$define_pos]=dechex($daily_imp_len);
                $daily_define[$define_pos+1]=dechex($daily_cli_len);
            }
            $return[$system][$carrier][__MIN_TAG][__DE_TAG]=$min_define;
            $return[$system][$carrier][__MIN_TAG][__LS_TAG]=$min_offset+__TDB_LF_SIZE;

            $return[$system][$carrier][__HALF_TAG][__DE_TAG]=$half_define;
            $return[$system][$carrier][__HALF_TAG][__LS_TAG]=$half_offset+__TDB_LF_SIZE;

            $return[$system][$carrier][__DAILY_TAG][__DE_TAG]=$daily_define;
            $return[$system][$carrier][__DAILY_TAG][__LS_TAG]=$daily_offset+__TDB_LF_SIZE;
        }
    }
    return $return;
}

function readTdbDefine($dstring) {
    global $debug_level;
    if (!empty($dstring)) {
        $linesize=0;
        foreach ($_SERVER['province_position'] as $province=>$position) {
            $p_offset=$position*2;
            $imp_len=hexdec($dstring[$p_offset]);
            $cli_len=hexdec($dstring[$p_offset+1]);
            if (0<$imp_len || 0<$cli_len) {
                $return[$province][__OFFSET_POS]=$linesize;
                $return[$province][__IMPLEN_POS]=$imp_len;
                $return[$province][__CLILEN_POS]=$cli_len;
                DebugInfo(3,$debug_level,"[fun.readTdbDefine]-[positon:$position]-[province:$province]-[offset:$linesize]-[imp_len:$imp_len]-[cli_len:$cli_len]");
                $linesize+=($imp_len+$cli_len);
            }
        }
        $return[__LS_TAG]=$linesize+__TDB_LF_SIZE;
        $return[__DE_TAG]=$dstring;
    } else {
        $return=false;
    }
    return $return;
}

function openSingleDB($source,$carrier,$timestamp,$db_root,$dbtype,$tdb_info=null) {
    global $debug_level;
    $db=$db_root.'/'.$source.'/'.$carrier.'/'.date($_SERVER['db_file'][$dbtype],$timestamp);
    if ($dbtype==__MIN_TAG) {
        $total_lines=1440;
    } elseif ($dbtype==__HALF_TAG) {
        $total_lines=48*date('t',$timestamp);
    } elseif ($dbtype==__DAILY_TAG) {
        $total_lines=(date('y',$timestamp)%4===0)?366:365;
    }
    DebugInfo(2,$debug_level,"[fun.openSingleDB][db:$db]-[will_open_it]");
    if (!empty($tdb_info) && !file_exists($db)) {
        $dbsize=__TDB_DEF_LS+$tdb_info[$dbtype][__LS_TAG]*$total_lines;
        DebugInfo(3,$debug_level,"[fun.openSingleDB][db:$db]-[linesize:".$tdb_info[$dbtype][__LS_TAG]."]-[line:$total_lines]-[size:$dbsize]-[create_it]-[$debug_level]");
        makeDir($db,"0755",0,'f');
        system("/bin/dd if=/dev/zero of=$db bs=$dbsize count=1 2>> /dev/null",$create);
        if ($create==0 && $db_handle=@fopen($db,"r+")) {
            DebugInfo(1,$debug_level,"[fun.openSingleDB][db:$db]-[created!]");
            $dinfo=readTdbDefine(trim($tdb_info[$dbtype][__DE_TAG]));
            fwrite($db_handle,$tdb_info[$dbtype][__DE_TAG]);
            return Array(__HANDLE_TAG=>$db_handle,__INFO_TAG=>$dinfo);
        } else {
            DebugInfo(3,$debug_level,"[fun.openSingleDB][db:$db]-[open_error!]");
            return false;
        }
    } elseif (file_exists($db) && $db_handle=@fopen($db,"r+")) {
        $dstring=fread($db_handle,__TDB_DEF_LS-__TDB_LF_SIZE);
        DebugInfo(3,$debug_level,"[fun.openSingleDB][db:$db]-[line:$total_lines]-[dstring:$dstring]-[exists]-[$debug_level]");
        $dinfo=readTdbDefine($dstring);
        return Array(__HANDLE_TAG=>$db_handle,__INFO_TAG=>$dinfo);
    } else {
        DebugInfo(1,$debug_level,"[fun.openSingleDB][db:$db]-[open_error!]");
        return false;
    }
}

function readTrafficDB($carrier,$province,$timestamp,$handle,$tdb_info,$dbtype) {
    global $debug_level;
    if ($handle) {
        if ($dbtype==__MIN_TAG) {
            $line=(int)date('H',$timestamp)*60+(int)date('i',$timestamp);
        } elseif ($dbtype==__HALF_TAG) {
            $line=48*((int)date('j',$timestamp)-1)+(int)date('H',$timestamp)*2+floor((int)date('i',$timestamp)/30);
        } elseif ($dbtype==__DAILY_TAG) {
            $line=(int)date("z",$timestamp);
        }
        $imp_len=$tdb_info[$dbtype][$province][__IMPLEN_POS];
        $cli_len=$tdb_info[$dbtype][$province][__CLILEN_POS];
        $total_imp_len=$tdb_info[$dbtype][__TOTAL_TAG][__IMPLEN_POS];
        $total_cli_len=$tdb_info[$dbtype][__TOTAL_TAG][__CLILEN_POS];

        $offset=__TDB_DEF_LS+$tdb_info[$dbtype][__LS_TAG]*$line;
        $imp_offset=$offset+$tdb_info[$dbtype][$province][__OFFSET_POS];
        $total_offset=$offset+$tdb_info[$dbtype][__TOTAL_TAG][__OFFSET_POS];
        DebugInfo(3,$debug_level,"[fun.readTrafficDB]-[carrier:$carrier]-[province:$province]-[imp_len:$imp_len]-[cli_len:$cli_len]-[total_imp_len:$total_imp_len]-[total_cli_len:$total_cli_len]-[line:$line]-[linesize:".$tdb_info[$dbtype][__LS_TAG]."]-[province:$province]-[province_offset:$imp_offset]-[total_offset:$total_offset]");

        //begin read
        fseek($handle,$imp_offset);
        if ($imp_len>0) $p_imp=(int)trim(fread($handle,$imp_len));
        else $p_imp=0;
        if ($cli_len>0) $p_cli=(int)trim(fread($handle,$cli_len));
        else $p_cli=0;

        fseek($handle,$total_offset);
        if ($total_imp_len>0) $total_imp=(int)trim(fread($handle,$total_imp_len));
        else $total_imp=0;
        if ($total_cli_len>0) $total_cli=(int)trim(fread($handle,$total_cli_len));
        else $total_cli=0;
        DebugInfo(3,$debug_level,"[fun.readTrafficDB]-[carrier:$carrier]-[province:$province]-[p_imp:$p_imp]-[p_cli:$p_cli]-[total_imp:$total_imp]-[total_cli:$total_cli]");

        $array_return[0]=$p_imp;
        $array_return[1]=$p_cli;
        $array_return[2]=$total_imp;
        $array_return[3]=$total_cli;
        return $array_return;
    } else {
        return false;
    }
}

function writeTrafficDB($carrier,$province,$timestamp,$handle,$p_imp,$p_cli,$total_imp,$total_cli,$tdb_info,$dbtype) {
    global $debug_level;
    if ($handle) {
        if ($dbtype==__MIN_TAG) {
            $line=(int)date('H',$timestamp)*60+(int)date('i',$timestamp);
        } elseif ($dbtype==__HALF_TAG) {
            $line=48*((int)date('j',$timestamp)-1)+(int)date('H',$timestamp)*2+floor((int)date('i',$timestamp)/30);
        } elseif ($dbtype==__DAILY_TAG) {
            $line=(int)date("z",$timestamp);
        }
        $imp_len=$tdb_info[$dbtype][$province][__IMPLEN_POS];
        $cli_len=$tdb_info[$dbtype][$province][__CLILEN_POS];
        $total_imp_len=$tdb_info[$dbtype][__TOTAL_TAG][__IMPLEN_POS];
        $total_cli_len=$tdb_info[$dbtype][__TOTAL_TAG][__CLILEN_POS];

        $offset=__TDB_DEF_LS+$tdb_info[$dbtype][__LS_TAG]*$line;
        $imp_offset=$offset+$tdb_info[$dbtype][$province][__OFFSET_POS];
        $total_offset=$offset+$tdb_info[$dbtype][__TOTAL_TAG][__OFFSET_POS];
        DebugInfo(3,$debug_level,"[fun.writeTrafficDB]-[carrier:$carrier]-[province:$province]-[imp_len:$imp_len]-[cli_len:$cli_len]-[total_imp_len:$total_imp_len]-[total_cli_len:$total_cli_len]-[line:$line]-[linesize:".$tdb_info[$dbtype][__LS_TAG]."]-[province:$province]-[p_imp:$p_imp]-[p_cli:$p_cli]-[total_imp:$total_imp]-[total_cli:$total_cli]-[province_offset:$imp_offset]-[total_offset:$total_offset]");

        if ($imp_len>0) {
            if (strlen($p_imp)>$imp_len) {
                //warning
                DebugInfo(1,$debug_leveil,"[warning!!]-[carrier:$carrier]-[province:$province]-[type:$dbtype]-[imp_len:$imp_len]-[imp:$p_imp]-[over_define_len]");
            }
            $p_string.=str_pad($p_imp,$imp_len,' ');
        }
        if ($cli_len>0) {
            if (strlen($p_cli)>$cli_len) {
                //warning
                DebugInfo(1,$debug_level,"[warning!!]-[carrier:$carrier]-[province:$province]-[type:$dbtype]-[cli_len:$cli_len]-[cli:$p_cli]-[over_define_len]");
            }
            $p_string.=str_pad($p_cli,$cli_len,' ');
        }
        if ($total_imp_len>0) {
            if (strlen($total_imp)>$total_imp_len) {
                //warning
                DebugInfo(1,$debug_level,"[warning!!]-[carrier:$carrier]-[province:$province]-[type:$dbtype]-[total_imp_len:$total_imp_len]-[imp:$total_imp]-[over_define_len]");
            }
            $total_string.=str_pad($total_imp,$total_imp_len,' ');
        }
        if ($total_cli_len>0) {
            if (strlen($total_cli)>$total_cli_len) {
                //warning
                DebugInfo(1,$debug_level,"[warning!!]-[carrier:$carrier]-[province:$province]-[total_cli_len:$total_cli_len]-[cli:$total_cli]-[over_define_len]");
            }
            $total_string.=str_pad($total_cli,$total_cli_len,' ');
        }
        $total_string.=__TDB_LF;
        DebugInfo(3,$debug_level,"[fun.writeTrafficDB]-[carrier:$carrier]-[p_string:$p_string]-[total_string:$total_string]");

        fseek($handle,$imp_offset);
        fwrite($handle,$p_string);
        fseek($handle,$total_offset);
        fwrite($handle,$total_string);
    } else {
        return false;
    }
}

function openTrafficDB($source,$carrier,$timestamp,$db_root,$tdb_info) {
    $array_min=openSingleDB($source,$carrier,$timestamp,$db_root,__MIN_TAG,$tdb_info);
    $array_half=openSingleDB($source,$carrier,$timestamp,$db_root,__HALF_TAG,$tdb_info);
    $array_daily=openSingleDB($source,$carrier,$timestamp,$db_root,__DAILY_TAG,$tdb_info);
    $array_return[__HANDLE_TAG][__MIN_TAG]=$array_min[__HANDLE_TAG];
    $array_return[__HANDLE_TAG][__HALF_TAG]=$array_half[__HANDLE_TAG];
    $array_return[__HANDLE_TAG][__DAILY_TAG]=$array_daily[__HANDLE_TAG];
    $array_return[__INFO_TAG][__MIN_TAG]=$array_min[__INFO_TAG];
    $array_return[__INFO_TAG][__HALF_TAG]=$array_half[__INFO_TAG];
    $array_return[__INFO_TAG][__DAILY_TAG]=$array_daily[__INFO_TAG];
    return $array_return;
}

function closeTrafficDB($sourcehandles) {
    global $debug_level;
    foreach ($sourcehandles as $source=>$carrierhandles) {
        if (is_array($carrierhandles)) {
            foreach ($carrierhandles as $carrier=>$timehandles) {
                foreach ($timehandles as $date=>$infos) {
                    foreach ($infos[__HANDLE_TAG] as $key=>$value) {
                        if (is_resource($value)) {
                            DebugInfo(4,$debug_level,"[fun.closeTrafficDB]-[source:$source]-[carrier:$carrier]-[date:$date]-[db:$key]-[close]");
                            fclose($value);
                        } else {
                            DebugInfo(4,$debug_level,"[fun.closeTrafficDB]-[source:$source]-[carrier:$carrier]-[date:$date]-[db:$key]-[close_error]");
                        }
                    }
                }
            }
        } else {
            return false;
        }
    }
}

function updateTrafficDB($province,$source_timestamp,$imp,$cli,$dbhandles,$source,$carrier,$tdb_root,$tdb_info) {
    global $debug_level;
    if (!is_resource($dbhandles[__MIN_TAG])) {
        DebugInfo(2,$debug_level,"[fun.updateTrafficDB]::[$source]-[$carrier]-[$province]-[lose_handle]-[min]");
        $min_info=openSingleDB($source,$carrier,$timestamp,$db_root,__MIN_TAG,$tdb_info);
        $min_handle=$min_info[__HANDLE_TAG];
    } else {
        $min_handle=$dbhandles[__MIN_TAG];
    }
    if (!is_resource($dbhandles[__HALF_TAG])) {
        DebugInfo(2,$debug_level,"[fun.updateTrafficDB]::[$source]-[$carrier]-[$province]-[lose_handle]-[half]");
        $half_info=openSingleDB($source,$carrier,$timestamp,$db_root,__HALF_TAG,$tdb_info);
        $half_handle=$half_info[__HANDLE_TAG];
    } else {
        $half_handle=$dbhandles[__HALF_TAG];
    }
    if (!is_resource($dbhandles[__DAILY_TAG])) {
        DebugInfo(2,$debug_level,"[fun.updateTrafficDB]::[$source]-[$carrier]-[$province]-[lose_handle]-[daily]");
        $daily_info=openSingleDB($source,$carrier,$timestamp,$db_root,__DAILY_TAG,$tdb_info);
        $daily_handle=$daily_info[__HANDLE_TAG];
    } else {
        $daily_handle=$dbhandles[__DAILY_TAG];
    }
    //deal min
    $array_min=readTrafficDB($carrier,$province,$source_timestamp,$min_handle,$tdb_info,__MIN_TAG);
    DebugInfo(3,$debug_level,"[fun.updateTrafficDB]::[$source]-[$carrier]-[$province]-[imp:{$array_min[0]}+$imp]-[cli:{$array_min[1]}+$cli]-[timp:{$array_min[2]}+$imp]-[tcli:{$array_min[3]}+$cli]-[min]");
    writeTrafficDB($carrier,$province,$source_timestamp,$min_handle,$array_min[0]+$imp,$array_min[1]+$cli,$array_min[2]+$imp,$array_min[3]+$cli,$tdb_info,__MIN_TAG);
    //deal half
    $array_half=readTrafficDB($carrier,$province,$source_timestamp,$half_handle,$tdb_info,__HALF_TAG);
    DebugInfo(3,$debug_level,"[fun.updateTrafficDB]::[$source]-[$carrier]-[$province]-[imp:{$array_half[0]}+$imp]-[cli:{$array_half[1]}+$cli]-[timp:{$array_half[2]}+$imp]-[tcli:{$array_half[3]}+$cli]-[half]");
    writeTrafficDB($carrier,$province,$source_timestamp,$half_handle,$array_half[0]+$imp,$array_half[1]+$cli,$array_half[2]+$imp,$array_half[3]+$cli,$tdb_info,__HALF_TAG);
    //deal half
    $array_daily=readTrafficDB($carrier,$province,$source_timestamp,$daily_handle,$tdb_info,__DAILY_TAG);
    DebugInfo(3,$debug_level,"[fun.updateTrafficDB]::[$source]-[$carrier]-[$province]-[imp:{$array_daily[0]}+$imp]-[cli:{$array_daily[1]}+$cli]-[timp:{$array_daily[2]}+$imp]-[tcli:{$array_daily[3]}+$cli]-[daily]");
    writeTrafficDB($carrier,$province,$source_timestamp,$daily_handle,$array_daily[0]+$imp,$array_daily[1]+$cli,$array_daily[2]+$imp,$array_daily[3]+$cli,$tdb_info,__DAILY_TAG);
}

function getTraffic($source,$carrier,$province,$timestamp,$tdb_root,$dbtype) {
    $info=openSingleDB($source,$carrier,$timestamp,$tdb_root,$dbtype);
    $handle=$info[__HANDLE_TAG];
    $tdb_info[$dbtype]=$info[__INFO_TAG];
    $traffic=readTrafficDB($carrier,$province,$timestamp,$handle,$tdb_info,$dbtype);
    $p_imp=$traffic[0];
    $p_cli=$traffic[1];
    $imp=$traffic[2];
    $cli=$traffic[3];
    fclose($handle);
    return Array($imp,$cli,$p_imp,$p_cli);
}

function getSource($source,$province,$timestamp,$tdb_root,$dbtype) {
    $array_unicom=getTraffic($source,__UNICOM_TAG,$province,$timestamp,$tdb_root,$dbtype);
    $array_cmwap=getTraffic($source,__CMWAP_TAG,$province,$timestamp,$tdb_root,$dbtype);
    $array_cmnet=getTraffic($source,__CMNET_TAG,$province,$timestamp,$tdb_root,$dbtype);
    $array_www=getTraffic($source,__WWW_TAG,$province,$timestamp,$tdb_root,$dbtype);
    return Array(__UNICOM_TAG=>$array_unicom,__CMWAP_TAG=>$array_cmwap,__CMNET_TAG=>$array_cmnet,__WWW_TAG=>$array_www);
}
?>
