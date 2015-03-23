(function ($) {
    $.fn.fmp_alert_message = function (options) {
    // opts 里面是默认参数
    var opts={ 
        title:'dialog_title',
        content:'dialog_content',
        height:180,
        callback:function(){}
    };
    $.extend(opts,options);

    this
        .empty()
        .append("<div class=\"alert alert-success\"><a href=\"#\" class=\"close\" data-dismiss=\"alert\">&times;</a><strong>Success!</strong> We are deleting the selected account, it could take some time.</div>")
        .css("display","none")
        .fadeIn()
    opts.callback();
    };
})(jQuery);
