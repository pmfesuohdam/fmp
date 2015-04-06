(function ($) {
    $.fn.fmp_alert_message = function (options) {
    // opts 里面是默认参数
    var opts={ 
        type:1,
        strong:'alert!',
        content:'alert content',
        callback:function(){}
    };
    $.extend(opts,options);

    this.empty()
    appendStr=""
    switch(opts.type) {
      case(0):
      appendStr="<div class=\"alert alert-danger alert-error\">";
      break;
      case(1):
      appendStr="<div class=\"alert alert-success\">";
      break;
    }
    this
        .append(appendStr+"<a href=\"#\" class=\"close\" data-dismiss=\"alert\">&times;</a><strong>"+opts.strong+"</strong> "+opts.content+"</div>")
        .css("display","none")
        .fadeIn()
     //   .delay( 12000 )
     //   .slideUp( 1000 )
    opts.callback();
    };
})(jQuery);
