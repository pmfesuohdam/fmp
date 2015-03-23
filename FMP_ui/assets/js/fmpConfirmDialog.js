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

    this.append('<div id="dialog-confirm" title="'+opts.title+'"><p>'+opts.content+'</p></div>');
    //////////////////////////////////////
    $( "#dialog-confirm" ).dialog({
      resizable: false,
      height:180,
      modal: true,
      buttons: {
        "Delete ad account": function() {
          $( this ).dialog( "close" );
        },
        Cancel: function() {
          $( this ).dialog( "close" );
        }
      }
    });
    /////////////////////////////////////
    opts.callback();
    };
})(jQuery);
