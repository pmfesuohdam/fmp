<?php
function buildNullArray($arr) {
    foreach ($arr as $value) {
        $return[]=null;
    }
    return $return;
}

function printf_array($format,$arr) {
    return call_user_func_array('printf', array_merge((array)$format,$arr));
}
function buildFormat($table_define) {
    $tag="~";
    $j=0;
    foreach ($table_define as $key=>$value) {
        $field_null[$j]=null;
        $field_name[$j]=$key;
        $field_length[$j++]=$value;
    }
    for($i=0;$i<$j;$i++) {
        if ($i==0) {
            $format_line.="+%'$tag".$field_length[$i]."s+%'$tag";
            $format_content.="|%-".$field_length[$i]."s|%-";
        } elseif ($i==($j-1)) {
            $format_line.=$field_length[$i]."s+\n";
            $format_content.=$field_length[$i]."s|\n";
        } else {
            $format_line.=$field_length[$i]."s+%'$tag";
            $format_content.=$field_length[$i]."s|%-";
        }
    }
    printf_array($format_line,$field_null);
    printf_array($format_content,$field_name);
    printf_array($format_line,$field_null);
    return Array($format_line,$format_content);
}

function tablePrint($format_line,$format_content,$array_content) {
    $array_null=buildNullArray($array_content);
    printf_array($format_content,$array_content);
    printf_array($format_line,$array_null);
}
?>
