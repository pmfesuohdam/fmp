package com.madhouse.spring.controller;

import java.util.ArrayList;
//import java.util.HashMap;
import java.util.List;
//import java.util.Map;



import javax.validation.Valid;





//import org.apache.commons.lang.StringUtils;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindingResult;
import org.springframework.validation.Errors;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.madhouse.spring.model.LoginModel;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.madhouse.spring.common.LoginMsg;
import com.madhouse.spring.common.SimpleValidateMsg;

@RestController
public class TestValidateController {
@RequestMapping(value="/validate/hello",method=RequestMethod.POST,produces={"application/json"})
@ResponseStatus(HttpStatus.OK)
public String validate(@Valid @ModelAttribute("login")LoginModel login,Errors errors,BindingResult br) throws JsonProcessingException{
	 //user.addAttribute("username", "12");
	if (br.hasErrors()) {
    /* map.put("errorCode", "40001");*/
    // System.out.println("errorMsg"+ br.getFieldError().getDefaultMessage());
    }
if(errors.hasErrors()) {
//return "validate/error";
	List<FieldError> fieldErrors=errors.getFieldErrors();
    ObjectMapper json_mapper = new ObjectMapper();
	ArrayList<SimpleValidateMsg> msgs= new ArrayList<SimpleValidateMsg>();
	for (FieldError fieldError : fieldErrors) {
		msgs.add( new SimpleValidateMsg(fieldError.getField(), fieldError.getDefaultMessage()) );
	}
	String state="false";
    if ( !(msgs!=null && msgs.size()>0) ) {
    	msgs.add(new SimpleValidateMsg("",""));
    	state="true";
    }
    return json_mapper.writeValueAsString(new LoginMsg(msgs.get(0),state,"http://xxxx"));
} else 
return "redirect:/success";
}}