$(document).ready(function(){
	$("code").css("display","none")
  $("#email").keydown(function(e){
    var curKey = e.which;
    if(curKey == 13){$("#passwd").focus()}
    })
  $("#passwd").keydown(function(e){ 
    var curKey = e.which; 
    if(curKey == 13){$(".login_btn").click()}})
	$(".login_btn").bind("click",function(){
		var btn=$(this)
		btn.val("logining...")
    $(this).attr("disabled",'disabled')
		$.ajax({
			url: baseConf.api_prefix+"/update/login/@self", 
			context: document.body, 
			type: "POST",
			data:{ email: $("#email").val(), passwd: $("#passwd").val() },
			success: function(data){
				$("code").css("display","inline")
				$(".n-tip").text("")
                $("#email+code").text("")
                $("#passwd+code").text("")
                err_msg=data.err_msg
                for (i=0;i<err_msg.length;i++) {
                  for ( var id in err_msg[i] ){
                    alert_dom_id="#"+id+"+code"
                    $(alert_dom_id).text(err_msg[i][id])
                }
            }
            $(function(){
                function show(){
                    btn.val("login")
                    $(".login_btn").attr("disabled",false)
                }
                setTimeout(show,1000);
            })
            if (data.status==="true")
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
