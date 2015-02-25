package com.madhouse.spring.common;

public class LoginMsg {
	private String err_name;
	private String err_msg;
    private String state;
    private String gourl;
    public LoginMsg(SimpleValidateMsg simple_validate_msg,String state,String gourl){
    	this.err_name=simple_validate_msg.getErr_name();
    	this.err_msg=simple_validate_msg.getErr_msg();
	    this.state=state;
	    this.gourl=gourl;
    }

    public String getErr_name() {
		return err_name;
	}

	public void setErr_name(String err_name) {
		this.err_name = err_name;
	}

	public String getErr_msg() {
		return err_msg;
	}

	public void setErr_msg(String err_msg) {
		this.err_msg = err_msg;
	}

	public void setState(String state) {
		this.state = state;
	}

	public void setGourl(String gourl) {
		this.gourl = gourl;
	}

	public String getState(){
	    return this.state;
    }
    public String getGourl(){
	    return this.gourl;
    }
}
