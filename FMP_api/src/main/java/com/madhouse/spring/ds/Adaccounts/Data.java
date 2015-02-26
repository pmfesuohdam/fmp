package com.madhouse.spring.ds.Adaccounts;

import java.util.List;

public class Data {
    private String account_id;
    private String id;
    private String access_status;
    public String getAccount_id() {
		return account_id;
	}
	public void setAccount_id(String account_id) {
		this.account_id = account_id;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getAccess_status() {
		return access_status;
	}
	public void setAccess_status(String access_status) {
		this.access_status = access_status;
	}
	public String getAccess_type() {
		return access_type;
	}
	public void setAccess_type(String access_type) {
		this.access_type = access_type;
	}
	public List<String> getPermitted_roles() {
		return permitted_roles;
	}
	public void setPermitted_roles(List<String> permitted_roles) {
		this.permitted_roles = permitted_roles;
	}
	private String access_type;
    private List<String> permitted_roles;
}