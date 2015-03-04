function postStep1(){
  $.ajax({			
    url: baseConf.api_prefix+"/update/campaign/@step1",
  context: document.body, 
  type: "POST",
  data:{ 
    billingAccount: $("#billingAccount").val(),
  campaignName: $("#campaignName").val(),
  buyingType: $("#buyingType").val(),
  objective: $("#buyingType").val()
  },
  success: function(data) {
  } 
  })
}
function bind_proceed(){
  $("#jsProceed").on({
    "click":function(){
      alert("")
    }
  })
}
