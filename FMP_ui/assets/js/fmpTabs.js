(function($) {
  $.fn.fmpTabs = function(options) {
      var opts = $.extend({}, $.fn.fmpTabs.defaults, options);
      $this = $(this);
      var o = $.meta ? $.extend({}, opts, $this.data()) : opts;
//      $this.css({
//        backgroundColor: o.background,
//        color: o.foreground
//      });
//      var markup = $this.html();
//      markup = $.fn.fmpTabs.format(markup);
//      $this.html(markup);
    
//#dialog label, #dialog input { display:block; }
//#dialog label { margin-top: 0.5em; }
//#dialog input, #dialog textarea { width: 95%; }
//#tabs { margin-top: 1em; }
//#tabs li .ui-icon-close { float: left; margin: 0.4em 0.2em 0 0; cursor: pointer; }
//#add_tab { cursor: pointer; }
     $this
         .html("")
         .append('<ul><li><a href="#tabs-1">Nunc tincidunt</a><span class="ui-icon ui-icon-close" role="presentation">Remove Tab</span></li></ul><div id="tabs-1"><p></p></div>')
         .before('<div id="dialog" title="Tab data"><form onsubmit="return false;"><fieldset class="ui-helper-reset"><label for="tab_title">Title</label><input type="text" name="tab_title" id="tab_title" value="Tab Title" class="ui-widget-content ui-corner-all"><label for="tab_content">Content</label><textarea name="tab_content" id="tab_content" class="ui-widget-content ui-corner-all">Tab content</textarea></fieldset></form></div><button id="add_tab">Add Tab</button>')
  };
  $("#dialog label, #dialog input").css("display","block")
  $("#dialog label").css("margin-top","0.5em")
  $("#dialog input, #dialog textarea").css("width","95%")
  $("#tabs").css("margin-top","1em")
  $("#tabs li .ui-icon-close").css({float:"left",margin:"0.4em 0.2em 0 0",cursor:"pointer"})
  $("add_tab").css("cursor","pointer")

  $.fn.fmpTabs.format = function(txt) {
    return '<strong>' + txt + '</strong>';
  };
  //
  // plugin defaults
  //
  $.fn.fmpTabs.defaults = {
    foreground: 'red',
    background: 'yellow'
  };
})(jQuery);
