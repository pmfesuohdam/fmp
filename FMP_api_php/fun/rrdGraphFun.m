<?php
/*
  +----------------------------------------------------------------------+
  | Name:rrdGraphFun.php
  +----------------------------------------------------------------------+
  | Comment:显示若干时间内趋势图的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:  
  +----------------------------------------------------------------------+
  | Last-Modified: 2014-06-13 15:25:50
  +----------------------------------------------------------------------+
 */
$GLOBALS['httpStatus']=__HTTPSTATUS_OK;
header('Content-type: image/png');
$tmpfname = tempnam("/tmp", "MONITOR1_RRDGRAPH_");
$fontTitle="uming.ttf";
$fontAxis="uming.ttf";
$fontUnit="uming.ttf";
$fontLegend="uming.ttf";
$graphStyle=" -c SHADEA#DDDDDD -c SHADEB#808080 -c FRAME#006600 -c FONT#006699 -c ARROW#FF0000 -c AXIS#000000 -c BACK#FFFFFF ";
$rrdtool=is_file('/usr/bin/rrdtool')?'/usr/bin/rrdtool':'/usr/local/bin/rrdtool';
//$nominor="--no_minor";
$nominor="";
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $width=isset($_GET['width'])?(is_numeric($_GET['width'])?intval($_GET['width']):900):900;
    $height=isset($_GET['height'])?(is_numeric($_GET['height'])?intval($_GET['height']):300):300;
    $start=isset($_GET['start'])?(is_numeric($_GET['start'])?intval($_GET['start']):time()):time();
    $end=isset($_GET['end'])?(is_numeric($_GET['end'])?intval($_GET['end']):time()):time();
    if (!isset($_GET['start']) && !isset($_GET['end'])) { //默认没有输入则显示1小时
        $end=time();
        $start=$end-3600;
    }
    $legendFontSize=$width<500?7:9;
    $titleFontSize=$width<500?9:12;
    switch ($GLOBALS['selector']) {
    case(__SELECTOR_HTTPSTATUS_ALL):
        $graphShell=<<<EOT
{$rrdtool} graph {$tmpfname} --lazy --start {$start} --end {$end} --slope-mode {$nominor} --title "SmartMAD全部服务器Hive采集汇总 - HTTP状态码综合统计(请求数)" {$graphStyle} -v"http status code numbers" --font TITLE:{$titleFontSize}:{$fontTitle} --font AXIS:8:{$fontAxis} --font LEGEND:{$legendFontSize}:{$fontLegend} --font UNIT:8:{$fontUnit} --imgformat=PNG --rigid --width {$width} --height {$height} DEF:statusTotal=/services/rrds/httplog_status.rrd:statusTotal:AVERAGE LINE3:statusTotal#eaebf3:HTTP请求总数 GPRINT:statusTotal:LAST:" 当前\:%8.2lf %s"  GPRINT:statusTotal:AVERAGE:"平均\:%8.2lf %s" GPRINT:statusTotal:"MAX:""最大\:%8.2lf %s\\n"  DEF:status2xx=/services/rrds/httplog_status.rrd:status2xx:AVERAGE AREA:status2xx#7cb2ee:HTTP状态2xx GPRINT:status2xx:LAST:" 当前\:%8.2lf %s"  GPRINT:status2xx:AVERAGE:"平均\:%8.2lf %s" GPRINT:status2xx:"MAX:""最大\:%8.2lf %s\\n" DEF:status3xx=/services/rrds/httplog_status.rrd:status3xx:AVERAGE LINE:status3xx#8cf176:HTTP状态3xx GPRINT:status3xx:LAST:" 当前\:%8.2lf %s"  GPRINT:status3xx:AVERAGE:"平均\:%8.2lf %s" GPRINT:status3xx:"MAX:""最大\:%8.2lf %s\\n" DEF:status5xx=/services/rrds/httplog_status.rrd:status5xx:AVERAGE AREA:status5xx#f4a35c:HTTP状态5xx GPRINT:status5xx:LAST:" 当前\:%8.2lf %s" GPRINT:status5xx:AVERAGE:"平均\:%8.2lf %s" GPRINT:status5xx:"MAX:""最大\:%8.2lf %s\\n" DEF:status4xx=/services/rrds/httplog_status.rrd:status4xx:AVERAGE LINE:status4xx#434345:HTTP状态4xx GPRINT:status4xx:LAST:" 当前\:%8.2lf %s" GPRINT:status4xx:AVERAGE:"平均\:%8.2lf %s" GPRINT:status4xx:"MAX:""最大\:%8.2lf %s\\n"
EOT;
        exec($graphShell);
        echo file_get_contents($tmpfname);
        unlink($tmpfname);
        break;
    case(__SELECTOR_HTTPSTATUS_2XX):
        $graphShell=<<<EOT
{$rrdtool} graph {$tmpfname} --lazy --start {$start} --end {$end} --slope-mode {$nominor} --title "SmartMAD全部服务器Hive采集汇总 - HTTP状态码2XX综合统计(请求数)" {$graphStyle} -v"http status code numbers" --font TITLE:{$titleFontSize}:{$fontTitle} --font AXIS:8:{$fontAxis} --font LEGEND:{$legendFontSize}:{$fontLegend} --font UNIT:8:{$fontUnit} --imgformat=PNG --rigid --width {$width} --height {$height} DEF:statusTotal=/services/rrds/httplog_status.rrd:statusTotal:AVERAGE LINE3:statusTotal#eaebf3:HTTP请求总数 GPRINT:statusTotal:LAST:" 当前\:%8.2lf %s"  GPRINT:statusTotal:AVERAGE:"平均\:%8.2lf %s" GPRINT:statusTotal:"MAX:""最大\:%8.2lf %s\\n"  DEF:status2xx=/services/rrds/httplog_status.rrd:status2xx:AVERAGE AREA:status2xx#7cb2ee:HTTP状态2xx GPRINT:status2xx:LAST:" 当前\:%8.2lf %s"  GPRINT:status2xx:AVERAGE:"平均\:%8.2lf %s" GPRINT:status2xx:"MAX:""最大\:%8.2lf %s\\n"
EOT;
        exec($graphShell);
        echo file_get_contents($tmpfname);
        unlink($tmpfname);
        break;
    case(__SELECTOR_HTTPSTATUS_3XX):
        $graphShell=<<<EOT
{$rrdtool} graph {$tmpfname} --lazy --start {$start} --end {$end} --slope-mode {$nominor} --title "SmartMAD全部服务器Hive采集汇总 - HTTP状态码3XX综合统计(请求数)" {$graphStyle} -v"http status code numbers" --font TITLE:{$titleFontSize}:{$fontTitle} --font AXIS:8:{$fontAxis} --font LEGEND:{$legendFontSize}:{$fontLegend} --font UNIT:8:{$fontUnit} --imgformat=PNG --rigid --width {$width} --height {$height} DEF:statusTotal=/services/rrds/httplog_status.rrd:statusTotal:AVERAGE LINE3:statusTotal#eaebf3:HTTP请求总数 GPRINT:statusTotal:LAST:" 当前\:%8.2lf %s"  GPRINT:statusTotal:AVERAGE:"平均\:%8.2lf %s" GPRINT:statusTotal:"MAX:""最大\:%8.2lf %s\\n"  DEF:status3xx=/services/rrds/httplog_status.rrd:status3xx:AVERAGE AREA:status3xx#8cf176:HTTP状态3xx GPRINT:status3xx:LAST:" 当前\:%8.2lf %s"  GPRINT:status3xx:AVERAGE:"平均\:%8.2lf %s" GPRINT:status3xx:"MAX:""最大\:%8.2lf %s\\n"
EOT;
        exec($graphShell);
        echo file_get_contents($tmpfname);
        unlink($tmpfname);
        break;
    case(__SELECTOR_HTTPSTATUS_4XX):
        $graphShell=<<<EOT
{$rrdtool} graph {$tmpfname} --lazy --start {$start} --end {$end} --slope-mode {$nominor} --title "SmartMAD全部服务器Hive采集汇总 - HTTP状态码4XX综合统计(请求数)" {$graphStyle} -v"http status code numbers" --font TITLE:{$titleFontSize}:{$fontTitle} --font AXIS:8:{$fontAxis} --font LEGEND:{$legendFontSize}:{$fontLegend} --font UNIT:8:{$fontUnit} --imgformat=PNG --rigid --width {$width} --height {$height} DEF:statusTotal=/services/rrds/httplog_status.rrd:statusTotal:AVERAGE LINE3:statusTotal#eaebf3:HTTP请求总数 GPRINT:statusTotal:LAST:" 当前\:%8.2lf %s"  GPRINT:statusTotal:AVERAGE:"平均\:%8.2lf %s" GPRINT:statusTotal:"MAX:""最大\:%8.2lf %s\\n"  DEF:status4xx=/services/rrds/httplog_status.rrd:status4xx:AVERAGE AREA:status4xx#434345:HTTP状态4xx GPRINT:status4xx:LAST:" 当前\:%8.2lf %s"  GPRINT:status4xx:AVERAGE:"平均\:%8.2lf %s" GPRINT:status4xx:"MAX:""最大\:%8.2lf %s\\n"
EOT;
        exec($graphShell);
        echo file_get_contents($tmpfname);
        unlink($tmpfname);
        break;
    case(__SELECTOR_HTTPSTATUS_5XX):
        $graphShell=<<<EOT
{$rrdtool} graph {$tmpfname} --lazy --start {$start} --end {$end} --slope-mode {$nominor} --title "SmartMAD全部服务器Hive采集汇总 - HTTP状态码5XX综合统计(请求数)" {$graphStyle} -v"http status code numbers" --font TITLE:{$titleFontSize}:{$fontTitle} --font AXIS:8:{$fontAxis} --font LEGEND:{$legendFontSize}:{$fontLegend} --font UNIT:8:{$fontUnit} --imgformat=PNG --rigid --width {$width} --height {$height} DEF:statusTotal=/services/rrds/httplog_status.rrd:statusTotal:AVERAGE LINE3:statusTotal#eaebf3:HTTP请求总数 GPRINT:statusTotal:LAST:" 当前\:%8.2lf %s"  GPRINT:statusTotal:AVERAGE:"平均\:%8.2lf %s" GPRINT:statusTotal:"MAX:""最大\:%8.2lf %s\\n"  DEF:status5xx=/services/rrds/httplog_status.rrd:status5xx:AVERAGE AREA:status5xx#f4a35c:HTTP状态5xx GPRINT:status5xx:LAST:" 当前\:%8.2lf %s"  GPRINT:status5xx:AVERAGE:"平均\:%8.2lf %s" GPRINT:status5xx:"MAX:""最大\:%8.2lf %s\\n"
EOT;
        exec($graphShell);
        echo file_get_contents($tmpfname);
        unlink($tmpfname);
        break;
    }
} 
?>
