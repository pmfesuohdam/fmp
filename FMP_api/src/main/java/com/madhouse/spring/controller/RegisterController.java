package com.madhouse.spring.controller;

import java.util.ArrayList;
import java.util.List;

import javax.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.validation.Errors;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.madhouse.spring.common.LoginMsg;
import com.madhouse.spring.common.SimpleValidateMsg;
import com.madhouse.spring.model.RegisterModel;

@RestController
public class RegisterController {

	/* post register info */
	@RequestMapping(value = "/register/post/self", method = RequestMethod.POST, produces = { "application/json"} )
	@ResponseStatus(HttpStatus.OK)
	public String doRegister(@Valid @ModelAttribute("register") RegisterModel register,
			Errors errors) throws JsonProcessingException {
		ArrayList<SimpleValidateMsg> msgs = new ArrayList<SimpleValidateMsg>();
		if (errors.hasErrors()) {
			List<FieldError> fieldErrors = errors.getFieldErrors();
			for (FieldError fieldError : fieldErrors) {
				msgs.add(new SimpleValidateMsg(fieldError.getField(),
						fieldError.getDefaultMessage()));
			}
		}
		return new ObjectMapper().writeValueAsString(msgs);
	}
	
}
