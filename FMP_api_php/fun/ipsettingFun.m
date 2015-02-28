<?php
/*
  +----------------------------------------------------------------------+
  | Name:ipsettingFun.m
  +----------------------------------------------------------------------+
  | Comment:IP设置搜索的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:2012年 4月13日 星期五 13时49分26秒 CST
  +----------------------------------------------------------------------+
  | Last-Modified: 2013-01-11 15:53:51
  +----------------------------------------------------------------------+
 */
header("Content-type: application/json; charset=utf-8");
define(__MDB_TABLE_IP, 'madhouse_serv_ip'); // HBASE的IP主表
define(__MDB_TABLE_LOCDIC, 'location_dic'); // HBASE的IP地区字典表
/* {{{ 运营商类型 
 */
define(_UNKNOWN,'00');
define(_CMWAP,  '01');
define(_CMNET,  '02');
define(_CTWAP,  '03');
define(_CTNET,  '04');
define(_UNIWAP, '05');
define(_UNINET, '06');
define(_WIFI,   '07');
define(_TRUST,  '97');  // 信任的IP
define(_MISC,   '98');  // MISC服务器IP或者白名单
define(_BLACKIP,'99');  // 黑名单
define(__USERTYPE_WIFI_CM,'08');
define(__USERTYPE_WIFI_CT,'09');
define(__USERTYPE_WIFI_UN,'10');
define(__USERTYPE_EDUNET,'11');   // 教育网的0和7里面的分

$_SERVER['carrier']=Array(
    _UNKNOWN => '未知',
    _CMWAP   => '移动WAP',
    _CMNET   => '移动',
    _CTWAP   => '电信WAP',
    _CTNET   => '电信',
    _UNIWAP  => '联通WAP',
    _UNINET  => '联通',
    _WIFI    => 'WIFI',
    _TRUST   => '白名单',
    _MISC    => 'MISC',
    _BLACKIP => '黑名单',
    __USERTYPE_WIFI_CM => '移动WIFI',
    __USERTYPE_WIFI_CT => '电信WIFI',  
    __USERTYPE_WIFI_UN => '联通WIFI',
    __USERTYPE_EDUNET  => '教育网'
);
/* }}} */

$_SERVER['province_code']=Array(
    '0000' => '未知',
    '0001' => '北京', '0002' => '上海', '0003' => '天津', '0004' => '重庆', '0005' => '黑龙江', '0006' => '吉林',
    '0007' => '辽宁', '0008' => '内蒙', '0009' => '河北', '0010' => '河南', '0011' => '广东', '0012' => '湖北',
    '0013' => '山东', '0014' => '浙江', '0015' => '安徽', '0016' => '江苏', '0017' => '江西', '0018' => '云南',
    '0019' => '宁夏', '0020' => '青海', '0021' => '山西', '0022' => '陕西', '0023' => '湖南', '0024' => '福建',
    '0025' => '甘肃', '0026' => '四川', '0027' => '广西', '0028' => '贵州', '0029' => '海南', '0030' => '西藏',
    '0031' => '新疆', '0032' => '香港', '0033' => '澳门', '0034' => '台湾'
);

$geoip_country_code_to_number = array(
    "" => 0, "ap" => 1, "eu" => 2, "ad" => 3, "ae" => 4, "af" => 5, 
    "ag" => 6, "ai" => 7, "al" => 8, "am" => 9, "an" => 10, "ao" => 11, 
    "aq" => 12, "ar" => 13, "as" => 14, "at" => 15, "au" => 16, "aw" => 17, 
    "az" => 18, "ba" => 19, "bb" => 20, "bd" => 21, "be" => 22, "bf" => 23, 
    "bg" => 24, "bh" => 25, "bi" => 26, "bj" => 27, "bm" => 28, "bn" => 29, 
    "bo" => 30, "br" => 31, "bs" => 32, "bt" => 33, "bv" => 34, "bw" => 35, 
    "by" => 36, "bz" => 37, "ca" => 38, "cc" => 39, "cd" => 40, "cf" => 41, 
    "cg" => 42, "ch" => 43, "ci" => 44, "ck" => 45, "cl" => 46, "cm" => 47, 
    "cn" => 48, "co" => 49, "cr" => 50, "cu" => 51, "cv" => 52, "cx" => 53, 
    "cy" => 54, "cz" => 55, "de" => 56, "dj" => 57, "dk" => 58, "dm" => 59, 
    "do" => 60, "dz" => 61, "ec" => 62, "ee" => 63, "eg" => 64, "eh" => 65, 
    "er" => 66, "es" => 67, "et" => 68, "fi" => 69, "fj" => 70, "fk" => 71, 
    "fm" => 72, "fo" => 73, "fr" => 74, "fx" => 75, "ga" => 76, "gb" => 77,
    "gd" => 78, "ge" => 79, "gf" => 80, "gh" => 81, "gi" => 82, "gl" => 83, 
    "gm" => 84, "gn" => 85, "gp" => 86, "gq" => 87, "gr" => 88, "gs" => 89, 
    "gt" => 90, "gu" => 91, "gw" => 92, "gy" => 93, "hk" => 94, "hm" => 95, 
    "hn" => 96, "hr" => 97, "ht" => 98, "hu" => 99, "id" => 100, "ie" => 101, 
    "il" => 102, "in" => 103, "io" => 104, "iq" => 105, "ir" => 106, "is" => 107, 
    "it" => 108, "jm" => 109, "jo" => 110, "jp" => 111, "ke" => 112, "kg" => 113, 
    "kh" => 114, "ki" => 115, "km" => 116, "kn" => 117, "kp" => 118, "kr" => 119, 
    "kw" => 120, "ky" => 121, "kz" => 122, "la" => 123, "lb" => 124, "lc" => 125, 
    "li" => 126, "lk" => 127, "lr" => 128, "ls" => 129, "lt" => 130, "lu" => 131, 
    "lv" => 132, "ly" => 133, "ma" => 134, "mc" => 135, "md" => 136, "mg" => 137, 
    "mh" => 138, "mk" => 139, "ml" => 140, "mm" => 141, "mn" => 142, "mo" => 143, 
    "mp" => 144, "mq" => 145, "mr" => 146, "ms" => 147, "mt" => 148, "mu" => 149, 
    "mv" => 150, "mw" => 151, "mx" => 152, "my" => 153, "mz" => 154, "na" => 155,
    "nc" => 156, "ne" => 157, "nf" => 158, "ng" => 159, "ni" => 160, "nl" => 161, 
    "no" => 162, "np" => 163, "nr" => 164, "nu" => 165, "nz" => 166, "om" => 167, 
    "pa" => 168, "pe" => 169, "pf" => 170, "pg" => 171, "ph" => 172, "pk" => 173, 
    "pl" => 174, "pm" => 175, "pn" => 176, "pr" => 177, "ps" => 178, "pt" => 179, 
    "pw" => 180, "py" => 181, "qa" => 182, "re" => 183, "ro" => 184, "ru" => 185, 
    "rw" => 186, "sa" => 187, "sb" => 188, "sc" => 189, "sd" => 190, "se" => 191, 
    "sg" => 192, "sh" => 193, "si" => 194, "sj" => 195, "sk" => 196, "sl" => 197, 
    "sm" => 198, "sn" => 199, "so" => 200, "sr" => 201, "st" => 202, "sv" => 203, 
    "sy" => 204, "sz" => 205, "tc" => 206, "td" => 207, "tf" => 208, "tg" => 209, 
    "th" => 210, "tj" => 211, "tk" => 212, "tm" => 213, "tn" => 214, "to" => 215, 
    "tl" => 216, "tr" => 217, "tt" => 218, "tv" => 219, "tw" => 220, "tz" => 221, 
    "ua" => 222, "ug" => 223, "um" => 224, "us" => 225, "uy" => 226, "uz" => 227, 
    "va" => 228, "vc" => 229, "ve" => 230, "vg" => 231, "vi" => 232, "vn" => 233,
    "vu" => 234, "wf" => 235, "ws" => 236, "ye" => 237, "yt" => 238, "rs" => 239, 
    "za" => 240, "zm" => 241, "me" => 242, "zw" => 243, "a1" => 244, "a2" => 245, 
    "o1" => 246, "ax" => 247, "gg" => 248, "im" => 249, "je" => 250, "bl" => 251,
    "mf" => 252
);
$GEOIP_COUNTRY_NAMES = array(
    "", "Asia/Pacific Region", "Europe", "Andorra", "United Arab Emirates",
    "Afghanistan", "Antigua and Barbuda", "Anguilla", "Albania", "Armenia",
    "Netherlands Antilles", "Angola", "Antarctica", "Argentina", "American Samoa",
    "Austria", "Australia", "Aruba", "Azerbaijan", "Bosnia and Herzegovina",
    "Barbados", "Bangladesh", "Belgium", "Burkina Faso", "Bulgaria", "Bahrain",
    "Burundi", "Benin", "Bermuda", "Brunei Darussalam", "Bolivia", "Brazil",
    "Bahamas", "Bhutan", "Bouvet Island", "Botswana", "Belarus", "Belize",
    "Canada", "Cocos (Keeling) Islands", "Congo, The Democratic Republic of the",
    "Central African Republic", "Congo", "Switzerland", "Cote D'Ivoire", "Cook Islands",
    "Chile", "Cameroon", "China", "Colombia", "Costa Rica", "Cuba", "Cape Verde",
    "Christmas Island", "Cyprus", "Czech Republic", "Germany", "Djibouti",
    "Denmark", "Dominica", "Dominican Republic", "Algeria", "Ecuador", "Estonia",
    "Egypt", "Western Sahara", "Eritrea", "Spain", "Ethiopia", "Finland", "Fiji",
    "Falkland Islands (Malvinas)", "Micronesia, Federated States of", "Faroe Islands",
    "France", "France, Metropolitan", "Gabon", "United Kingdom",
    "Grenada", "Georgia", "French Guiana", "Ghana", "Gibraltar", "Greenland",
    "Gambia", "Guinea", "Guadeloupe", "Equatorial Guinea", "Greece", "South Georgia and the South Sandwich Islands",
    "Guatemala", "Guam", "Guinea-Bissau",
    "Guyana", "Hong Kong", "Heard Island and McDonald Islands", "Honduras",
    "Croatia", "Haiti", "Hungary", "Indonesia", "Ireland", "Israel", "India",
    "British Indian Ocean Territory", "Iraq", "Iran, Islamic Republic of",
    "Iceland", "Italy", "Jamaica", "Jordan", "Japan", "Kenya", "Kyrgyzstan",
    "Cambodia", "Kiribati", "Comoros", "Saint Kitts and Nevis", "Korea, Democratic People's Republic of",
    "Korea, Republic of", "Kuwait", "Cayman Islands",
    "Kazakhstan", "Lao People's Democratic Republic", "Lebanon", "Saint Lucia",
    "Liechtenstein", "Sri Lanka", "Liberia", "Lesotho", "Lithuania", "Luxembourg",
    "Latvia", "Libyan Arab Jamahiriya", "Morocco", "Monaco", "Moldova, Republic of",
    "Madagascar", "Marshall Islands", "Macedonia",
    "Mali", "Myanmar", "Mongolia", "Macau", "Northern Mariana Islands",
    "Martinique", "Mauritania", "Montserrat", "Malta", "Mauritius", "Maldives",
    "Malawi", "Mexico", "Malaysia", "Mozambique", "Namibia", "New Caledonia",
    "Niger", "Norfolk Island", "Nigeria", "Nicaragua", "Netherlands", "Norway",
    "Nepal", "Nauru", "Niue", "New Zealand", "Oman", "Panama", "Peru", "French Polynesia",
    "Papua New Guinea", "Philippines", "Pakistan", "Poland", "Saint Pierre and Miquelon",
    "Pitcairn Islands", "Puerto Rico", "Palestinian Territory",
    "Portugal", "Palau", "Paraguay", "Qatar", "Reunion", "Romania",
    "Russian Federation", "Rwanda", "Saudi Arabia", "Solomon Islands",
    "Seychelles", "Sudan", "Sweden", "Singapore", "Saint Helena", "Slovenia",
    "Svalbard and Jan Mayen", "Slovakia", "Sierra Leone", "San Marino", "Senegal",
    "Somalia", "Suriname", "Sao Tome and Principe", "El Salvador", "Syrian Arab Republic",
    "Swaziland", "Turks and Caicos Islands", "Chad", "French Southern Territories",
    "Togo", "Thailand", "Tajikistan", "Tokelau", "Turkmenistan",
    "Tunisia", "Tonga", "Timor-Leste", "Turkey", "Trinidad and Tobago", "Tuvalu",
    "Taiwan", "Tanzania, United Republic of", "Ukraine",
    "Uganda", "United States Minor Outlying Islands", "United States", "Uruguay",
    "Uzbekistan", "Holy See (Vatican City State)", "Saint Vincent and the Grenadines",
    "Venezuela", "Virgin Islands, British", "Virgin Islands, U.S.",
    "Vietnam", "Vanuatu", "Wallis and Futuna", "Samoa", "Yemen", "Mayotte",
    "Serbia", "South Africa", "Zambia", "Montenegro", "Zimbabwe",
    "Anonymous Proxy","Satellite Provider","Other",
    "Aland Islands","Guernsey","Isle of Man","Jersey","Saint Barthelemy","Saint Martin"
);
header("Content-type: application/json; charset=utf-8");
$GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //读取返回200 

if (!canAccess('read_ipManagement')) {
    $GLOBALS['httpStatus'] = __HTTPSTATUS_FORBIDDEN;
    return;
}
switch ($GLOBALS['selector']) {
case(__SELECTOR_HOSTIP): //  返回请求IP 
    echo json_encode($_SERVER['REMOTE_ADDR']);
    break;
default: // 查询IP 
    $realIp=$GLOBALS['rowKey'];
    $realIpNetAddr=$realIp;
    $queryStart=microtime();
    $result=$GLOBALS['mdb_client']->scannerOpen(__MDB_TABLE_IP, str_pad(9999999999-$realIpNetAddr, 10, '0', STR_PAD_LEFT), (array)'info'); // 0.59.254.143 
    $get_arr = $GLOBALS['mdb_client']->scannerGetList($result, 1);
    foreach ( $get_arr as $TRowResult ) {
        $fixedIpstart=9999999999-$TRowResult->row;
        $fixedRealIpstart=long2ip(9999999999-$TRowResult->row);
        $column = $TRowResult->columns;
        foreach ($column as $family_column=>$Tcell) {
            switch($family_column) {
            case('info:country'):
                $countryCode=$Tcell->value;
                break;
            case('info:desc'):
                $desc=$Tcell->value;
                break;
            case('info:ipend'):
                $ipend=long2ip($Tcell->value);
                break;
            case('info:province'):
                $provinceCode=$Tcell->value;
                break;
            case('info:city'):
                $cityCode=$Tcell->value;
                break;
            case('info:carrier'):
                $carrierCode=$Tcell->value;
                break;
            }
        }
    }

    if (($countryNum=array_search(intval($countryCode),$geoip_country_code_to_number))) {
        $country=$GEOIP_COUNTRY_NAMES[intval($countryCode)].'('.$countryNum.')';
    } else {
        $country='未知';
    }
    if ($cityCode=='000000') {
        $city='未知';
    }
    $carrier=$_SERVER['carrier'][str_pad($carrierCode,2,'0',STR_PAD_LEFT)];
    if ($carrier=='未知') {
        $carrierCode='00';
    }

    $rowkey='ipdic';
    $ts=$cityCode+1;
    $arr=$GLOBALS['mdb_client']->getRowWithColumnsTs(__MDB_TABLE_LOCDIC, $rowkey, array('info:city'),$ts);
    $city=$arr[0]->columns['info:city']->value;

    $querySpeed=microtime()-$queryStart;
    $querySpeed=$querySpeed<0?0:$querySpeed;
    $outLine=array(
        'fixedIpstart'=>$fixedIpstart,
        'fixedRealIpstart'=>$fixedRealIpstart,
        'countryCode'=>$countryCode,
        'country'=>$country,
        'provinceCode'=>$provinceCode,
        'province'=>$_SERVER['province_code'][$provinceCode],
        'cityCode'=>$cityCode,
        'city'=>$city,
        'carrierCode'=>$carrierCode,
        'carrier'=>$carrier,
        'desc'=>join(' ', explode('|',$desc)),
        'ipend'=>$ipend,
        'iprange'=>$fixedRealIpstart.'~'.$ipend,
        'querySpeed'=>$querySpeed.'s'
    );
    echo json_encode($outLine);
    break;
}
closeMdb();
?>
