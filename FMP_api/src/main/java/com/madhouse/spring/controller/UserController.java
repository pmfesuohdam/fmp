package com.madhouse.spring.controller;

import javax.servlet.http.HttpSession;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserController {
	@RequestMapping(value="/user/get/self",method=RequestMethod.GET,produces={"application/json"})
	@ResponseStatus(HttpStatus.OK)
	public String getUser(HttpSession session){
		try{
		String user_name = (String) session.getAttribute("user_name");
		if (user_name.isEmpty()) {
			return "{\"username\":\""+(String) session.getAttribute("user_email")+"\",\"status\":\"true\"}";	
		} else {
			return "{\"username\":\""+user_name+"\",\"status\":\"true\"}";
		}
		} catch (Exception e) {
			return "{\"username\":\"null\",\"status\":\"false\"}";
		}
		
	}
}
