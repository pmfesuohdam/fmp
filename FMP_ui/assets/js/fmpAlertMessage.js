(function ($) {
    $.fn.fmp_alert_message = function (options) {
    // opts 里面是默认参数
    var opts={ 
        title:'dialog_title',
        content:'dialog_content',
        callback:function(){}
    };
    $.extend(opts,options);

    //this.append('<div id="dialog-confirm" title="'+opts.title+'"><p>'+opts.content+'</p></div>');
    opts.callback();
    };
})(jQuery);
