package com.madhouse.spring.model;

public class FmpUser {
	private long id;
	private String email;
	private String passwd;
	private String name;
public FmpUser() {
	
}
public long getId() {
	return id;
}
public void setId(long id) {
	this.id = id;
}
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
}
