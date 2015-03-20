(function ($) {
    $.fn.fmp_tab = function (options) {
    // opts 里面是默认参数
    var opts={ 
        add_name:'Add Product',
        add_tab_name:'Product data',
        callback:function(){}
    };
    $.extend(opts,options);

myid=$(this).eq(0).attr('id');

this.before('<div id="dialog" title="'+opts.add_tab_name+'"><form><fieldset class="ui-helper-reset"><label for="tab_title">Product name</label><input type="text" name="tab_title" id="tab_title" value="" placeholder="Enter product name" class="ui-widget-content ui-corner-all"><textarea name="tab_content" id="tab_content" class="ui-widget-content ui-corner-all" style="display:none"></textarea></fieldset></form></div><button id="add_tab">'+opts.add_name+'</button>')
this.append('<ul><li><a href="#'+myid+'-1">product1</a> <span class="ui-icon ui-icon-close" role="presentation">Remove Product</span></li></ul><div id="'+myid+'-1"><p>content</p></div>');
//////////////////////////////////////
var tabTitle = $( "#tab_title" ),
tabContent = $( "#tab_content" ),
tabTemplate = "<li><a href='#{href}'>#{label}</a> <span class='ui-icon ui-icon-close' role='presentation'>Remove Product</span></li>",
tabCounter = 2;

var tabs = $( "#"+myid ).tabs();

// modal dialog init: custom buttons and a "close" callback resetting the form inside
var dialog = $( "#dialog" ).dialog({
    autoOpen: false,
    modal: true,
    buttons: {
        Add: function() {
            addTab();
            $( this ).dialog( "close" );
        },
        Cancel: function() {
            $( this ).dialog( "close" );
        }
    },
    close: function() {
        form[ 0 ].reset();
    }
});

// addTab form: calls addTab function on submit and closes the dialog
var form = dialog.find( "form" ).submit(function( event ) {
    addTab();
    dialog.dialog( "close" );
    event.preventDefault();
});

// actual addTab function: adds new tab using the input from the form above
function addTab() {
    var label = tabTitle.val() || "Product " + tabCounter,
    id = myid+"-" + tabCounter,
    li = $( tabTemplate.replace( /#\{href\}/g, "#" + id ).replace( /#\{label\}/g, label ) ),
    tabContentHtml = tabContent.val() || "Product " + tabCounter + " content.";

    tabs.find( ".ui-tabs-nav" ).append( li );
    tabs.append( "<div id='" + id + "'><p>" + tabContentHtml + "</p></div>" );
    tabs.tabs( "refresh" );
    tabCounter++;
}

// addTab button: just opens the dialog
$( "#add_tab" )
.button()
.click(function() {
    dialog.dialog( "open" );
});

// close icon: removing the tab on click
tabs.delegate( "span.ui-icon-close", "click", function() {
    var panelId = $( this ).closest( "li" ).remove().attr( "aria-controls" );
    $( "#" + panelId ).remove();
    tabs.tabs( "refresh" );
});

tabs.bind( "keyup", function( event ) {
    if ( event.altKey && event.keyCode === $.ui.keyCode.BACKSPACE ) {
        var panelId = tabs.find( ".ui-tabs-active" ).remove().attr( "aria-controls" );
        $( "#" + panelId ).remove();
        tabs.tabs( "refresh" );
    }
});

// css
$(".ui-dialog .ui-dialog-title").css({"color":"gray","font-weight":"lighter"})
$("#dialog label, #dialog input").css({"display":"block","font-size":"12px"})
$("#dialog label").css({"margin-top":"0.5em","font-size":"12px"})
$("#dialog input, #dialog textarea").css({"width":"95%","font-size":"12px"})
$("#tabs").css({"margin-top":"1em","font-size":"12px"})
$("#tabs li .ui-icon-close").css({float:"left",margin:"0.4em 0.2em 0 0",cursor:"pointe","font-size":"12px"})
$("#add_tab").css("cursor","pointer")
$(".ui-widget-header").css({border:"none",background:"none"})
/////////////////////////////////////
opts.callback();
};
})(jQuery);
