//TOOD delete
package com.madhouse.spring.common;


public class ValidateMsg {
    private final String err_code;
    private final String err_name;
    private final String err_msg;

    public ValidateMsg(String err_code, String err_name, String err_msg) {
    	this.err_code=err_code;
        this.err_name = err_name;
        this.err_msg = err_msg;
    }
    
    public ValidateMsg( String err_name, String err_msg) {
    	this.err_code=null;
        this.err_name = err_name;
        this.err_msg = err_msg;
    }
    
    public String getErr_name() {
        return err_name;
    }

    public String getErr_msg() {
        return err_msg;
    }
    public String getErr_code() {
    	return err_code;
    }
}