package com.madhouse.spring.common;

public class SimpleValidateMsg {
    private final String err_name;
    private final String err_msg;
/*    private final String state;
    private final String goto_url;*/
    public SimpleValidateMsg(String err_name,String err_msg/*,String state,String goto_url*/){
    	this.err_name=err_name;
    	this.err_msg=err_msg;
/*    	this.state=state;
    	this.goto_url=goto_url;*/
    }
    public String getErr_name(){
    	return this.err_name;
    }
    public String getErr_msg(){
    	return this.err_msg;
    }
/*    public String getState(){
    	return state;
    }
    public String getGoto_url(){
    	return goto_url;
    }*/
}
