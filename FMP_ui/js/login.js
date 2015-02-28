$(document).ready(function(){
	$("code").css("display","none")
	$(".login_btn").bind("click",function(){
		var btn=$(this)
		btn.val("logining...")
		$.ajax({
			url: baseConf.api_prefix+"/update/login/@self", 
			context: document.body, 
			type: "POST",
			data:{ email: $("#email").val(), passwd: $("#passwd").val() },
			success: function(data){
				$("code").css("display","inline")
				$(".n-tip").text("")
        console.log(data)
				if ((data.err_msg).length>0) {
          console.log(data)
                    $(function(){
                        function show(){
                            btn.val("login")
                        }
                        setTimeout(show,1000);
                    })
                    alert_dom_id="#"+data.err_name+"+code"
                    $(alert_dom_id).text(data.err_msg)
                }
                if (data.state==="true")
                   location.href=baseConf.redirect_url
           },
           error:function (XMLHttpRequest, textStatus, errorThrown){
            $(function(){
               function show(){
                  btn.val("login")
              }
              setTimeout(show,1000);
          })
            
        }
    })
})
    //检查登陆状态，如果已经登陆，强制定位到操作面板页
    $.ajax({
    	url: baseConf.api_prefix+"/get/login/@self",
    	type: "GET",
    	success: function(data){
    		if(data.status=="true") {
    			location.href=baseConf.redirect_url
    		}
    		$("body").css("display","inline")
    	}
    })
})
