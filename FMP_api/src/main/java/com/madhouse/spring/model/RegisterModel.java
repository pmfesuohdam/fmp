package com.madhouse.spring.model;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.validator.constraints.Email;

public class RegisterModel {
	@NotNull(message="email must not be empty")
	@Size(min=5,max=80,message="email length must between 5-80")
	@Email(message="please enter a valid email address")
	private String email;
	
    @NotNull(message="password must not br empty")
    @Size(min=6,max=20,message="password length must between 6-20")
	private String passwd;
    
    @NotNull(message="name must not br empty")
    @Size(min=3,max=20,message="name length must between 3-20")
	private String name;
    
    @Size(min=6,max=40,message="company name must between 6-40")
	private String company;
	
	@NotNull(message="country code must not br empty")
    @Size(min=2,max=2,message="country code length must be 2")
	private String countryCode;
	
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getPasswd() {
		return passwd;
	}
	public void setPasswd(String passwd) {
		this.passwd = passwd;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getCountryCode() {
		return countryCode;
	}
	public void setCountryCode(String countryCode) {
		this.countryCode = countryCode;
	}
	public String getCompany() {
		return company;
	}
	public void setCompany(String company) {
		this.company = company;
	}

	
}
