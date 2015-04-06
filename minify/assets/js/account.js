$(document).ready(function(){
	$("#add_fb_a").attr("href",baseConf.fb_login_url)
})
function doDelAdAccount(act_id) {
  document.getElementById("hid_del_act").value=act_id;
  document.getElementById("do_account_form").submit();
  }
