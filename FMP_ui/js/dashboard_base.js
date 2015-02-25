$(document).ready(function(){
	$("#camp_select_div>select").bind("change",function(){location.href="dashboard.php?module=fmpcamp&id=xxxxx";})


	$.ajax({
		url: baseConf. api_prefix+"/user/get/self",
		type: "GET",
		success: function(data){
			$(".header > .userarea").html("<a href=\"../profiles\" id=\"user_profile_a\">"+data.username+"</a> | <a href=\"../\" onclick=\"return false;\" id=\"logout_btn\">logout</a>")
			$("#logout_btn").bind("click",function(){
				$.ajax({
					url: baseConf.api_prefix+"/login/delete/self",
					type: "GET",
					success: function(data){
						if (data.status=="false") {
							location.href="http://"+document.domain;
						}
					}
				})
			})
		}
	})

})