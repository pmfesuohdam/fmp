package com.madhouse.spring.model;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.validator.constraints.Email;

public class LoginModel {
	@NotNull(message="email must not be empty")
	@Size(min=5,max=80,message="email length must between 5-80")
	@Email(message="please enter a valid email address")
	private String email;
	
    public String getEmail() { return email; }
    public void setEmail(String email) { 
      this.email = email; 
    }
	//@Min(value=0,message="age can not be minus")
    @NotNull(message="password must not br empty")
    @Size(min=6,max=20,message="password length must between 6-20")
    private String passwd;
	
    public String getPasswd() { return passwd; }
    public void setPasswd(String passwd) { 
      this.passwd = passwd; 
    }	

}