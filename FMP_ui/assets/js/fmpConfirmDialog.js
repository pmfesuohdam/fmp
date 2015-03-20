(function ($) {
    $.fn.fmp_confirm_dialog = function (options) {
    // opts 里面是默认参数
    var opts={ 
        title:'dialog title',
        content:'dialog content',
        callback:function(){}
    };
    $.extend(opts,options);

myid=$(this).eq(0).attr('id');

alert(myid)
this.append('<div id="dialog-confirm" title="'+title+'"><p>'+content+'</p></div>');
//////////////////////////////////////
/////////////////////////////////////
opts.callback();
};
})(jQuery);
