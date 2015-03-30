<?php
/*
  +----------------------------------------------------------------------+
  | Name:graphFun.php
  +----------------------------------------------------------------------+
  | Comment:显示若干时间内趋势图的函数
  +----------------------------------------------------------------------+
  | Author:Evoup     evoex@126.com                                                     
  +----------------------------------------------------------------------+
  | Create:  
  +----------------------------------------------------------------------+
  | Last-Modified: 2012-01-12 16:05:20
  +----------------------------------------------------------------------+
*/
$GLOBALS['httpStatus'] = __HTTPSTATUS_BAD_REQUEST; // 默认返回400 
header("Content-type: application/json; charset=utf-8");

        $GLOBALS['httpStatus'] = __HTTPSTATUS_OK; //读取返回200 

        header('Content-type: image/png');
        //imagepng($im);
        $FlowColorOut=array(78/255,165/255,71/255);
        $FlowColorIn=array(91/255,227/255,81/255);
        $AxisColorOut=array(157/255, 157/255, 157/255);
        $s = new CairoImageSurface(CairoFormat::ARGB32, 511, 270);
        $c = new CairoContext($s);
        $c->setAntialias(1);

        $c->setSourceRgb(241/255, 241/255, 241/255); // 底色 
        $c->paint();

        $c->rectangle(49, 24, 431, 180); // 白框 
        //$c->setSourceRGBA(1, 1, 1, 0.2);
        $c->setSourceRgb(1, 1, 1);
        //$c->paintWithAlpha(0.2);
        $c->fill();
        $c->stroke();

        // axis
        $c->moveTo(48, 204);
        $c->lineTo(48, 20);
        $c->setLineWidth(1);
        $c->setSourceRgb($AxisColorOut[0], $AxisColorOut[1], $AxisColorOut[2]);
        $c->stroke();
        $c->moveTo(48, 204);
        $c->lineTo(485, 204);
        $c->setSourceRgb($AxisColorOut[0], $AxisColorOut[1], $AxisColorOut[2]);
        $c->stroke();
        $c->setAntialias(0);


/*{{{*/
        try {
            $res=$GLOBALS['mdb_client']->getRowWithColumns('monitor_server', 'smartmadBeta', array('info:generic_summary_load120117'));
        } catch (Exception $e) {
            DebugInfo("[catch a generate err]$e", 3);
            die;
        }
        DebugInfo("[wwww".serialize($res)."]", 3);
        //die;
/*}}}*/
        // flow外层
        //$c->moveTo(500, 200); //起始坐标  
        for ($i=-42; $i<394; $i+=4) {
            list($tmpX, $tmpY)=array($i+90, rand()%43+90);
            //DebugInfo("[drawing line point][X:$tmpX][Y:$tmpY]", 3);
            $allX[]=$tmpX;
            $allY[]=$tmpY;
            $c->lineTo($tmpX, $tmpY);
        }
        $c->setLineWidth(2);
        $c->setSourceRgb($FlowColorOut[0], $FlowColorOut[1], $FlowColorOut[2]);
        //$c->fill();
        $c->stroke();

        // flow内层alpha
        for ($i=0; $i<sizeof($allX); $i++) {
            $c->lineTo($allX[$i], $allY[$i]);
        }
        $c->lineTo(480,203);
        $c->lineTo(48,203);
        $c->setLineWidth(2);
        $c->setSourceRGBA($FlowColorIn[0], $FlowColorIn[1], $FlowColorIn[2],0.7);
        $c->fill();
        /*{{{*/
        $c->moveTo(138, 4);
        $c->setSourceRgb(0,0,0);
        /* Make a Pango layout, set the font, then set the layout size */
        $l = new PangoLayout($c);
        //$desc = new PangoFontDescription("Bitstream Charter 12");
        $desc = new PangoFontDescription("Serif 8");
        $l->setFontDescription($desc);
        //$l->setWidth(250 * PANGO_SCALE);
        $title=$GLOBALS['rowKey'].'`s '.$event_item_map_table[substr($GLOBALS['selector'],1,3)][__EVENT_LANG_ENG];
        $title=str_pad($title, 35, ' ', STR_PAD_LEFT); // 使定位居中 
        $l->setMarkup($title);
        $l->showLayout($c);
        $c->moveTo(38,255);
        $l->setMarkup("Last updated:".date('Y/m/d H:i:s', time()));
        /* Draw the layout on the surface */
        $l->showLayout($c);
        /*}}}*/
        $c->stroke();

        $s->writeToPng("php://output");
?>
