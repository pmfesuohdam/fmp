(function ($) {
    $.fn.fmp_confirm_dialog = function (options) {
    // opts 里面是默认参数
    var opts={ 
        title:'dialog_title',
        content:'dialog_content',
        height:180,
        callback:function(){}
    };
    $.extend(opts,options);

    myid=$(this).eq(0).attr('id');

    this.append('<div id="dialog-confirm" title="'+opts.title+'"><p>'+opts.content+'</p></div>');
    //////////////////////////////////////
    $( "#dialog-confirm" ).dialog({
      resizable: false,
      height:opts.height,
      modal: true,
      buttons: {
        "Delete ad account": function() {
          $(this).dialog("close").remove("#dialog-confirm")
        },
        Cancel: function() {
          $(this).dialog("close").remove("#dialog-confirm")
        }
      }
    });
    /////////////////////////////////////
    opts.callback();
    };
})(jQuery);
