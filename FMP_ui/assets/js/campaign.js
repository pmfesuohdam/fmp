var cache = {
    '': $('.bbq-default')
};
$(document).ready(function() {
        loading()
        $.ajax({
            url: baseConf.api_prefix + "/get/login/@self",
            method: "GET",
            async: false,
            success: function(data) {
                if (data.status == "false") { //没有登录退出
                    location.href = "../"
                }
                var user = [{
                    UserName: data.username
                }]
                $("#headerTemplate").tmpl(user).appendTo('.header #user_profile_a');
            }
        })
        bind_logout_btn()
    })
    /** 根据url参数判断是第几步，下载模板和ajax数据动态构造编辑页面
     *  新的方法一次性下载全部模板
     *  gced:global campaign edit data
     */
var gced = {
    adaccounts: "",
    audience: "",
    spending: "",
    design: "",
    tpl_sidebar: "",
    tpl_step1: "",
    tpl_step2: "",
    tpl_step3: "",
    tpl_step4: "",
    tpl_step5: ""
};
$.when(
    // Get the all available ad accounts
    $.get(baseConf.api_prefix + "/get/campaign/@step1", function(data) {
        gced.adaccounts = data
    }),
    $.get(baseConf.api_prefix + "/get/campaign/@step3", function(data) {
        gced.audience = data
    }),
    $.get(baseConf.api_prefix + "/get/campaign/@step4", function(data) {
        gced.spending = data
    }),
    $.get(baseConf.api_prefix + "/get/campaign/@step5", function(data) {
        gced.design = data
    }),
    $.get(baseConf.domain + "/templates/camp.sidebar.htm?t=20150406005706", function(data) {
        gced.tpl_sidebar = data
    }),
    $.get(baseConf.domain + "/templates/camp_step1.htm?t=20150406005706", function(data) {
        gced.tpl_step1 = data
    }),
    $.get(baseConf.domain + "/templates/camp_step2.htm?t=20150406005706", function(data) {
        gced.tpl_step2 = data
    }),
    $.get(baseConf.domain + "/templates/camp_step3.htm?t=20150406005706", function(data) {
        gced.tpl_step3 = data
    }),
    $.get(baseConf.domain + "/templates/camp_step4.htm?t=20150406005706", function(data) {
        gced.tpl_step4 = data
    }),
    $.get(baseConf.domain + "/templates/camp_step5.htm?t=20150406005706", function(data) {
        gced.tpl_step5 = data
    })
).then(function() {
    $("#main-loading").remove()
    $.tmpl(gced.tpl_sidebar, null).appendTo('#sidebar-area');
    $(window).bind('hashchange', function(e) {
        var url = $.param.fragment();
        $('.bbq-content').children(':visible').hide();
        arr = url.split("/")
        stp = (arr.length < 2) ? 1 : arr[1]
        changeNav(stp)
        if (cache[url]) {
            cache[url].show()
        } else {
            switch (stp) {
                case ("1"):
                    cache[url] = $.tmpl(gced["tpl_step" + stp], gced.adaccounts).appendTo('#ad_edit_area');
                    break;
                case ("2"):
                    cache[url] = $.tmpl(gced["tpl_step" + stp], gced.adaccounts).appendTo('#ad_edit_area');
                    trackingProcess()
                    break;
                case ("3"):
                    cache[url] = $.tmpl(gced["tpl_step" + stp], gced.audience).appendTo('#ad_edit_area');
                    AudienceProcess()
                    break;
                case ("4"):
                    cache[url] = $.tmpl(gced["tpl_step" + stp], gced.spending).appendTo('#ad_edit_area');
                    spendingProcess()
                    break;
                case ("5"):
                    cache[url] = $.tmpl(gced["tpl_step" + stp], gced.design).appendTo('#ad_edit_area');
                    new DesignProcess().init()
                    break;
                default:
                    cache[url] = $.tmpl(gced["tpl_step" + stp], gced.adaccounts).appendTo('#ad_edit_area');
                    break;
            }
        }
        $("#fmp_leftmenu").height($("#ad_edit_area").height() < 500 ? 500 : $("#ad_edit_area").height())
    })
    $(window).trigger('hashchange');
    if ((($.param.fragment()).split("/")).length < 2) {
        cache[""] = $.tmpl(gced["tpl_step1"], gced.adaccounts).appendTo('#ad_edit_area');
    }
});

function loading() {
    $("#main-loading").remove()
    $('#main-area').append("<div id=\"main-loading\"><i class=\"fa fa-cog fa-spin fa-3x fa-fw margin-bottom\"></i>loading...</div>")
}

function bind_logout_btn() {
    $("#logout_btn").bind("click", function() {
        $.ajax({
            url: baseConf.api_prefix + "/delete/login/@self",
            type: "GET",
            success: function(data) {
                if (data.status == "true") {
                    location.href = "http://" + document.domain;
                }
            }
        })
    })
}

function changeNav(step) {
    for (i = 0; i < 6; i++) {
        $("#fmp_leftmenu > ul > li:nth-child(" + i + ")").attr('class', '')
    }
    $("#fmp_leftmenu > ul > li:nth-child(" + step + ")").attr('class', 'active')
    location.href = baseConf.domain + "/campaign/new/#step/" + step
}

function goStep(step) {
    switch (step) {
        case (step):
            current_step = step - 1
            d = $("#form_camp_step" + current_step).serialize()
            save_step = step - 1
            $.ajax({
                url: baseConf.api_prefix + "/update/campaign/@step" + save_step,
                type: "POST",
                data: d,
                success: function(data) {
                    var body = $("html, body")
                    body.animate({scrollTop:0}, '1000', 'swing', function() { 
                    })
                    $("code").html("")
                    if (data.status == "true") {
                        location.href = baseConf.domain + "/campaign/new/#step/" + step
                        changeNav(step)
                    } else {
                        err_msg = data.err_msg
                        for (i = 0; i < err_msg.length; i++) {
                            for (id in err_msg[i]) {
                                alert_dom_id = "label[for=" + id + "] code"
                                $(alert_dom_id).text(err_msg[i][id])
                            }
                        }
                    }
                }
            })
            break;
        default:
            changeNav(step)
            $("#ad_edit_area").html("")
            $.tmpl(gced["tpl_step" + step], null).appendTo('#ad_edit_area')
            break;
    }
}

function goStepPram(obj) {
    step = obj.step
    pram = obj.pram
    changeNav(step)
    $("#ad_edit_area").html("");
    $.tmpl(gced["tpl_step" + step], pram).appendTo('#ad_edit_area');
}

function routeCampUrlAct() {
    url = window.location.href
    n = url.indexOf("#step")
    if (n >= 0) { //执行指定的路由
        url_sub = url.substr(n)
        sp_arr = url_sub.split("#step/")
            //会调用第"+sp_arr[1]+"页的方法
        return parseInt(sp_arr[1])
    } else { //不然就是第一页
        return 1
    }
}

function trackingProcess() {
    function trackingInit() {
        //google analytics
        if ($("input[name='ga_enable']").is(":checked")) {
            for (i = 2; i < 5; i++) {
                $("#form_camp_step2 > div:nth-child(" + i + ")").css("display", "block")
            }
        } else {
            for (i = 2; i < 5; i++) {
                $("#form_camp_step2 > div:nth-child(" + i + ")").css("display", "none")
            }
        }
        //sigmad tracking code
        if ($("input[name='sm_enable']").is(":checked")) {
            $("#form_camp_step2 > div:nth-child(7)").css("display", "block")
        } else {
            $("#form_camp_step2 > div:nth-child(7)").css("display", "none")
        }
        //facebook convert pixel
        if ($("input[name='fb_enable']").is(":checked")) {
            $("#form_camp_step2 > div:nth-child(10)").css("display", "block")
        } else {
            $("#form_camp_step2 > div:nth-child(10)").css("display", "none")
        }
    }

    function bindTrackingCheckBox() {
        $("input[name='ga_enable'],input[name='sm_enable'],input[name='fb_enable']").on('click', function() {
            trackingInit()
        })
    }
    trackingInit()
    bindTrackingCheckBox()
}

function AudienceProcess() {
    function bindCheck() {
        $("#form_camp_step3 > div > div > div:nth-child(1) > div:nth-child(6)").css(
            "display",
            $("input[name='age_split']").is(":checked") ? "block" : "none"
        )
        $("#form_camp_step3 > div > div > div:nth-child(1) > div:nth-child(12)").css(
            "display",
            $("input[name='save_template']").is(":checked") ? "block" : "none"
        )
    }

    function audienceInit() {
        bindCheck()
        $("#sel_fmptemplate").change(function() {
            reloadAudienceByTmpl($("#sel_fmptemplate").val())
        })
    }

    function bindLocAutoComplete() {
        //预先载入一个假的自动完成
        savedCountries = [];
        $("#fmplocation_autocomplete").wrap("<div class=\"ui-autocomplete-multiselect ui-state-default ui-widget\" id=\"fmp_loc_autocomplete_dummy\"></div>")
        $("#fmp_loc_autocomplete_dummy").bind('click', function() {
            $("#fmplocation_autocomplete").click()
        })
        $.each(gced.audience.fmplocation, function(k, v) {
            (v != null) && savedCountries.push(v)
        })
        before_savedCounties = "";
        $.each(savedCountries, function(k, v) {
            before_savedCounties += "<div class=\"ui-autocomplete-multiselect-item\">" + v + "<span class=\"ui-icon ui-icon-close\"></span></div>"
        })
        $("#fmplocation_autocomplete").before(before_savedCounties)
        $(".ui-icon,.ui-icon-close").bind('click', function() {
            $(this).parent().remove()
            del_country = $(this).parent().text()
            savedCountries = $.grep(savedCountries, function(n, i) {
                return n != del_country
            })
            $("input[name=fmplocation]").val(($.unique(savedCountries)).join('|'))
        })
        var contrys = []
        $.each(fmp_loc_dic, function(k, v) {
            contrys.push(v)
        })
        $("#fmplocation_autocomplete").on('click', function() {
            if ($("#fmplocation_autocomplete").parent().attr("id") == "fmp_loc_autocomplete_dummy") {
                $(".ui-autocomplete-multiselect-item").remove()
                $("#fmplocation_autocomplete").unwrap()
            }
            $("#fmplocation_autocomplete").autocomplete({
                source: contrys,
                multiselect: true
            });
            $("#fmplocation_autocomplete").parent().attr("id", "fmp_loc_autocomplete")
            before_savedCounties = "";
            $.each(savedCountries, function(k, v) {
                before_savedCounties += "<div class=\"ui-autocomplete-multiselect-item\">" + v + "<span class=\"ui-icon ui-icon-close\"></span></div>"
            })
            $("#fmplocation_autocomplete").before(before_savedCounties)
            savedCountries = []
            $(".ui-icon,.ui-icon-close").bind('click', function() {
                $(this).parent().remove()
            })
            $("#fmplocation_autocomplete").focus()
            $("#form_camp_step3 input").on('blur', function(event) {
                arr = [];
                event.stopPropagation();
                $.each($(".ui-autocomplete-multiselect-item"), function(k, v) {
                    arr.push($(this).text())
                })
                $("input[name=fmplocation]").val(($.unique(arr)).join('|'))
            })
        })
    }
    audienceInit()
    bindLocAutoComplete()
    $("input[name='age_split'],input[name='save_template']").on('click', function() {
        bindCheck()
    })
    $("#fmp_loc_autocomplete_dummy").trigger("click")
    $("#fmplocation_autocomplete").trigger("blur")
    $("#fmp_loc_autocomplete").removeClass("ui-state-active")
    generateDetail()
    $("#form_camp_step3 select").on('change', function() {
        generateDetail()
    })
    $("#fmp_loc_autocomplete").on('DOMSubtreeModified', function() {
        generateDetail()
    })
    becameSplitter($('#mainSplitter_step3'),660)
}

function reloadAudienceByTmpl(template_id) {
    $("#ad_edit_area").find("h2:contains('Audience')").remove()
    $("#form_camp_step3").remove()
    loading()
    $.get(baseConf.api_prefix + "/get/campaign/@step3?template_id=" + template_id, function(data) {
        $("#main-loading").remove()
        $("#ad_edit_area").css("display", "none")
        gced.audience = data
        cache["step/3"] = $.tmpl(gced["tpl_step3"], gced.audience).appendTo('#ad_edit_area');
        AudienceProcess()
        $("#ad_edit_area").css("display", "block")
    })
}



function spendingProcess() {
    becameSplitter($('#mainSplitter_step4'),400)
    try {
        generateDetail()
    } catch (e) {}
}

/**
 * Design的类
 */
var DesignProcess = function() {}
DesignProcess.prototype = {
    // 可以被加入的tab索引
    tabIndexs: [1,2,3,4,5],
    // 最大的tab数目
    maxTabNums: 5,
    // 初始化生成splitter和右侧明细,创建tabs，动态填充tabs
    init: function() {
        window.becameSplitter($('#mainSplitter_step5'),660)
        try {
            window.generateDetail()
        } catch (e) {}
        this.bindDropDown()
        this.createNewTabs($('#multi_product_jqxtabs'))
        this.bindTabsCloseBtn($('#multi_product_jqxtabs'))
        this.bindDbClkChTabTitle($('#multi_product_jqxtabs'))
        return this
    },
    // 绑定下拉page的选择变换
    bindDropDown: function() {
        $(document.body).on('click', '#form_camp_step5 .dropdown-menu li', function(event) {
            var $target = $(event.currentTarget)
            var $content = $($target.html())
            $content.find('input').attr('name', 'select_page')
            $target
                .closest('.btn-group')
                .find('[data-bind="label"]').html($content.html())
                .end()
                .children('.dropdown-toggle').dropdown('toggle')
            return false
        })
        return this
    },
    /** 创建tabs
     * @param {obj} obj_tabs - 创建的tabs的id
     */
    createNewTabs: function(obj_tabs) {
        //var index = 3;
        var $this=this
        obj_tabs
            .append("<ul id=\"unorderedList\"></ul>")
            .find('#unorderedList').append("<li canselect='false' hasclosebutton='false' name='li_add_new_product'>Add new Product</li>")
            .after("<div></div>")
            .parent()
            .jqxTabs({
                height: 500,
                width: '100%',
                showCloseButtons: true,
                scrollPosition: 'both'
            })
            .on('tabclick', function(event) {
                
                if (event.args.item == $('#unorderedList').find('li').length - 1) {
                    var length = $('#unorderedList').find('li').length
                    //obj_tabs.jqxTabs('addAt', event.args.item, 'Product ' + index, 'Sample content number: ' +
                    //    index)
                    length<=$this.maxTabNums && $this.createTabContent(obj_tabs,length-1)
                    //index++
                }
            })
        this.createTabContent(obj_tabs, 0)
        this.createTabContent(obj_tabs, 1)
        this.createTabContent(obj_tabs, 2)
        obj_tabs.jqxTabs('select', 0)
        return this
    },
    /** 创建tabs的内容
     * @param {obj} obj - jqxtabs的id
     * @param {int} idx - 从idx位置开始创建新的tab内容
     * @param {int} product_idx - 产品序号
     */
    createTabContent: function(obj, idx, product_idx) {
        // 剩下还可以创建的索引
        //alert("本次创建前剩下还可以创建的索引:"+this.tabIndexs)
        // 用剩余最小的id作为默认产品名字
        var $this=this
        var newTabId=Math.min.apply(Math,this.tabIndexs)
        this.tabIndexs = $.grep(this.tabIndexs, function(value) {
            return value != newTabId;
        })
        //alert("本次创建完剩下还可以创建的索引:"+this.tabIndexs)

        // pane的主要部分
        var pane_content = '<div class="form-group">'
        pane_content += '<label for="productLink">Product Link<code></code></label><input type="text" class="form-control" id="productLink'+newTabId+'" name="productLink" placeholder="Enter name" value=""></div>'
        pane_content += '<div class="form-group"><label for="productDescription">Product Description<code></code></label><input type="text" class="form-control" id="productDescription'+newTabId+'" name="productDescription" placeholder="Enter product description" value=""></div>'
        pane_content += '<div class="form-group" id="fg'+newTabId+'"><label for="picture">Picture<code></code></label><form><input id="file_upload'+newTabId+'" name="file_upload" type="file" multiple="true" style="display:none"><div id="btn-group'+newTabId+'"><button class="btn btn-default btn-sm btn-upload">Upload new images <span class="glyphicon glyphicon-plus"></span></button>or<button class="btn btn-default btn-sm btn-upload">Select from your galley <span class="glyphicon glyphicon-plus"></span></button></div></form></div>'
        //pane_content += '<div id="adimage0" class="modal-header" style="width:200px;border:none;"></div>'
        pane_content += '</div>'

        //obj.jqxTabs('addAt', idx, 'Product ' + idx, pane_content)
        obj.jqxTabs('addAt', idx, 'Product ' + newTabId, pane_content)

        // 上传控件初始化
        $('#file_upload'+newTabId).uploadify({
            'multi': false,
            'queueSizeLimit': 1,
            'fileTypeExts': '*.gif; *.jpg; *.png',
            'buttonImage': '../../assets/img/transparent.gif',
            'buttonClass': 'uploadify_no_display',
            'wmode': 'transparent',
            'width': $("#btn-group"+newTabId+" > button:nth-child(1)").width() + 20,
            'formData': {},
            'swf': '../../assets/widgets/uploadify/uploadify.swf',
            'uploader': baseConf.api_prefix + "/create/ajax_upload/@product1",
            'onUploadSuccess': function(file, data, response) {
                var responseObj = JSON.parse(data);
                if (responseObj.err_msg) {
                    $("#" + file.id).find('.data').css('color', 'red').html(' - ' + responseObj.err_msg);
                    return;
                } else {
                    // 绑定当前上传图片的行为，展示和关闭
                    $('#adimage'+newTabId).remove()
                    $('#multi_product_jqxtabs #fg'+newTabId).after('<div id="adimage'+newTabId+'" class="modal-header" style="width:200px;border:none;"></div>')
                    $('#adimage'+newTabId).empty().append('<button type="button" class="close" data-dismiss="modal" aria-hidden="true"><img src="../../assets/img/modal_close.png"/></button><div class="img-thumbnail imgPreview"><img src="' + responseObj.url + '"></div>').css('display', 'none').fadeIn();
                    $("#adimage"+newTabId+" > button").on('click', function() {
                        $("#adimage"+newTabId).empty()
                    });
                    setTimeout(function() {
                        var prev_offset=$("#adimage"+newTabId).offset()
                        $("#adimage"+newTabId).attr('position','absolute')
                        $("#adimage"+newTabId).offset({
                            top: prev_offset.top-20,
                            left: prev_offset.left
                        })
                        $("#adimage"+newTabId).animate({ "top": "-=30px" }, "slow" );
                    },3500)
                }
            }
        });

        // 对齐上传按钮到swf上传控件的位置
        $("#btn-group"+newTabId).offset({
                top: $("#file_upload"+newTabId).offset().top,
                left: $("#file_upload"+newTabId).offset().left
            })

        // 绑定物料库的操作
        $(function() {
            var $modal = $('#galley_modal');
            $('#btn-group'+newTabId+' > button:nth-child(2)').on('click', function() {
                $('body').modalmanager('loading');
                setTimeout(function() {
                    $ul = $("#galley_modal > div.modal-body > div.files > ul");
                    $ul.empty();
                    $.get(baseConf.api_prefix + "/get/ajax_upload/@all", function(data) {
                        $.each(data, function(k, v) {
                            v != null && $ul.append('<li><a href=\"' + v.url + '\" class=\"imgPreview\"><img src=\"' +
                                v.url + '\"></a></li>')
                        });
                        $modal.modal();

                        $.each(
                            $("#galley_modal ul").find('.imgPreview'),
                            function(k, v) {
                                $(v).bind('click', function() {
                                    $('#adimage'+newTabId).remove()
                                    $('#multi_product_jqxtabs #fg'+newTabId).after('<div id="adimage'+newTabId+'" class="modal-header" style="width:200px;border:none;"></div>')
                                    $("#adimage"+newTabId).attr('position','absolute')
                                    var prev_ofs=$("#adimage"+newTabId).offset()
                                    $("#adimage"+newTabId).offset({
                                        top: prev_ofs.top-20,
                                        left: prev_ofs.left
                                    })
                                    $("#adimage"+newTabId).animate({ "top": "-=30px" }, "slow" )
                                    $('#adimage'+newTabId).empty().append('<button type="button" class="close" data-dismiss="modal" aria-hidden="true"><img src="../../assets/img/modal_close.png"/></button><div class="img-thumbnail imgPreview"><img src="' + $(this).attr('href') + '"></div>').css('display', 'none').fadeIn();

                                    $("#adimage"+newTabId+" > button").on('click', function() {
                                        $("#adimage"+newTabId).empty()
                                    });
                                    $('#galley_modal').modal('hide');
                                    return false;
                                })
                            });
                    });
                }, 1000);
                return false;
            });
            $this.bindDbClkChTabTitle($('#multi_product_jqxtabs'))
        })
    },

    /** 更新剩余可用的tab索引
     * @param {obj} obj - jqxtabs的id
     */
    updateTabIndexs: function(obj) {
        var $this=this
        //alert("本次删除前还剩下的索引"+$this.tabIndexs)
        //console.log("before update tabIndexs:"+$this.tabIndexs)
        var alreadyHasId=[]
        var oldInx=$this.tabIndexs=[1,2,3,4,5]

        try{
            for(var i=0;i<$(obj).jqxTabs('length');i++){  
                var inp=$(obj)
                    .jqxTabs('getContentAt',i)
                    .find(">.form-group>input:first")
                    console.log("id:"+parseInt(inp.attr("id").substr(inp.attr("id").length-1)))
                alreadyHasId.push(parseInt(inp.attr("id").substr(inp.attr("id").length-1)))
            }
        } catch(e){}
        //alert("本次预先重置的索引"+$this.tabIndexs)
        //alert("本次已经占用的索引"+alreadyHasId)
        $.each(alreadyHasId,function(k,v){
            //从总的索引中排除这些索引
            oldInx.splice( $.inArray(v,oldInx) ,1 );
        })
        //alert("排除这些后剩下的索引"+oldInx)
        //console.log("tabIndexs:"+$this.tabIndexs)
    },

   /** 绑定jqxtabs上每个小tab的关闭按钮
    * @param {obj} obj - jqxtabs的id
    */
    bindTabsCloseBtn: function(obj) {
        var $this=this
         obj.on('removed', function (event) {
             $this.updateTabIndexs(obj)
         })
    },

    /** 绑定tab标题双击修改产品名字的功能
     * @param {obj} obj - jqxtabs的id
     */
     bindDbClkChTabTitle: function(obj) {
        var me = this;
        // disable keyboard navigation. The keyboard navigation handles the arrow keys and selects the next or previous tab depending on the // pressed arrow key.
        obj.jqxTabs({ keyboardNavigation: false });
        // find the tab we will show an editor for.
        var tabs = obj.find("li");
        // bind to the double-click event.
        tabs.bind('dblclick', function (event) {
            // find the double-clicked tab title.
            var target = event.target;
            var tab = target.tagName == "LI" ? $(target) : $(target).parents('li:first');
            // create a text input or get the already created.
            var input = me.input || $("<div style='position: absolute; z-index: 9999; background: white'><input/></div>");
            var textinput = input.find('input');
            if (!me.input) {
                // add the text input to the document's body.
                $(document.body).append(input);
                // update the tab's text on blur.
                textinput.bind('blur', function () {
                    var newtext = textinput.val();
                    me.edittab.text(newtext);
                    input.css('display', 'none');
                    obj.jqxTabs('_performHeaderLayout');
                    //需要再绑定一次否则关闭按钮会消失
                    me.bindDbClkChTabTitle(obj);
                });
            }
            me.input = input;
            // show the input.
            input.css('display', 'block');
            // position the input over the tab and set its size.
            var taboffset = tab.offset();
            me.input.css({ left: taboffset.left, top: taboffset.top });
            me.input.height(tab.outerHeight());
            me.input.width(tab.outerWidth());
            var sizeoffset = 6;
            textinput.width(me.input.width() - sizeoffset);
            textinput.height(me.input.height() - sizeoffset);
            // set the initial text of the input.
            textinput.val(tab.text());
            me.edittab = tab;
        });
        //添加按钮不能出现能被双击的情况
        $("#unorderedList > li[name='li_add_new_product']").unbind("dblclick");
    }
}

/**
 * 把内部具有splitter-panel类div的div变为jqxsplitter
 * @param {obj} obj - 外层div的对象名
 * @param {int} hgt - 高度
 */
window.becameSplitter = function(obj,hgt) {
    obj
        .jqxSplitter({
            width: 774,
            height: hgt,
            panels: [{
                size: 550,
                collapsible: false
            }]
        })
        .find(".form-group").css("padding-right", "20px")
    $(".jqx-widget-content").css("background", "transparent").css("border", "none")
    $("#multi_product_jqxtabs").css("background", "").css("border", "")
    $(".panel,.panel-default").css("margin-left", "20px")
}

window.generateDetail = function() {
    var idx = 2
    age_min = $(cache["step/3"][idx]).find("#age_from").val() + ""
    age_max = $(cache["step/3"][idx]).find("#age_to").val() + ""
    gender = $(cache["step/3"][idx]).find("#gender").val() + "" == "0" ? null : [$(cache["step/3"][idx]).find("#gender").val() + ""]
    countryArr = [];
    $(".ui-autocomplete-multiselect-item").each(function(k, v) {
        $.each(fmp_loc_dic, function(country_code, country) {
            v.innerText == country && countryArr.push(country_code)
        })
    })

    reachObj = {
        age_min: age_min,
        age_max: age_max,
        geo_locations: {
            countries: countryArr
        }
    }
    if (gender != null) {
        reachObj['genders'] = gender
    }
    reachestimateTs = JSON.stringify(reachObj)
    targetingsentencelinesTs = JSON.stringify({
        "interests": [],
        "user_adclusters": [],
        "custom_audiences": [],
        "excluded_custom_audiences": [],
        "locales": [],
        "connections": [],
        "friends_of_connections": [],
        "excluded_connections": [],
        "targeted_entities": [],
        "wireless_carrier": [],
        "education_schools": [],
        "education_majors": [],
        "college_years": [],
        "work_employers": [],
        "work_positions": [],
        "behaviors": [],
        "age_min": age_min,
        "age_max": age_max,
        "geo_locations": {
            "zips": [],
            "cities": [],
            "regions": [],
            "countries": countryArr
        },
        "flexible_spec": {}
    })
    if (gced.audience.billing_account == null) {
        gced.audience.billing_account = $(cache["step/1"][2]).find("#billingAccount").val()
    }
    $.ajax({
        url: baseConf.api_prefix + "/get/fb_graph/@self",
        method: "POST",
        data: {
            batch: [{
                method: "GET",
                url: "/act_" + gced.audience.billing_account + "/reachestimate?targeting_spec=" + reachestimateTs
            }, {
                method: "GET",
                url: "/act_" + gced.audience.billing_account + "/targetingsentencelines?targeting_spec=" + targetingsentencelinesTs
            }]
        },
        success: function(data) {
            if (data.status == "false") { //没有登录退出
                location.href = "../"
            }
            item = ""
            estimate_audience = "n/a"
            if (data[0][0] == "200") {
                estimate_audience = $.parseJSON(data[0][1]).users
            }
            if (data[1][0] == "200") {
                arr = $.parseJSON(data[1][1]).targetingsentencelines
                $.each(arr, function(k, v) {
                    item += "<li>" + v.content + v.children + "</li>"
                })
            }
            detailContent = "<h4 class=\"tit\">Audience</h4><strong class=\"emphasize\">" + estimate_audience + "</strong>people<div class=\"summary\"><strong class=\"subtit\">Your ad targets people</strong><ul>" + item + "</ul></div>";
            $("#step3_panel_detail > div.panel-body").html(detailContent)
        }
    })
}
