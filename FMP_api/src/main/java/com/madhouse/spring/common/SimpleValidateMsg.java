package com.madhouse.spring.common;

public class SimpleValidateMsg {
	private final String err_name;
	private final String err_msg;

	public SimpleValidateMsg(String err_name, String err_msg) {
		this.err_name = err_name;
		this.err_msg = err_msg;
	}

	public String getErr_name() {
		return this.err_name;
	}

	public String getErr_msg() {
		return this.err_msg;
	}
}
