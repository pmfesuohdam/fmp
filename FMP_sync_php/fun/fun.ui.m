<?php
function getPhoneid($ua_id,$phoneid_idx_handle) {
    $offset=($ua_id-1)*__PHONEID_SIZE;
    if ($phoneid_idx_handle) {
        fseek($phoneid_idx_handle,$offset);
        $phoneline=trim(fread($phoneid_idx_handle,__PHONEID_SIZE));
        $phonelinelen=strlen($phoneline);
        $phone_id=base_convert(substr($phoneline,0,$phonelinelen-1),36,10);
        $vtag=substr($phoneline,-1,1);
    }
    return (empty($phone_id))?false:array($phone_id,$vtag);
}

function getPhoneBrand($phone_id,$phonebrand_idx_handle) {
    $offset=($phone_id-1)*32;
    if ($phonebrand_idx_handle) {
        fseek($phonebrand_idx_handle,$offset);
        $brand=trim(fread($phonebrand_idx_handle,32));
    }
    return (empty($phone_id))?false:$brand;
}

function openUiidx($idx) {
    if (!file_exists($idx)) {
        $handle=@fopen($idx,"w");
    } else {
        $handle=@fopen($idx,"r+");
    }
    return $handle;
}

function updateUiinfo($array_string,$ui_idx_handle,$ui_idx_size) {
    $idx_minszie=__UIINFO_LINESIZE*__UIINFO_MINLINE;
    $idx_maxsize=__UIINFO_LINESIZE*__UIINFO_MAXLINE;

    $input_string=implode("\n",$array_string)."\n";
    $input_size=strlen($input_string);

    if ($input_size>$idx_minszie) {
        fwrite($ui_idx_handle,$input_string);
        ftruncate($ui_idx_handle,$input_size);
    } elseif ($ui_idx_size<=$idx_maxsize) {
        fseek($ui_idx_handle,$ui_idx_size);
        fwrite($ui_idx_handle,$input_string);
    } elseif ($ui_idx_size>$idx_maxsize) {
        fwrite($ui_idx_handle,$input_string);
        ftruncate($ui_idx_handle,$idx_minszie);
    }
}
?>
