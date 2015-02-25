package com.madhouse.spring.model;

public class FbAccount {
	private long ad_account_id;
	private String ad_account_name;
	private String access_token;

public FbAccount() {
	
}

public long getAd_account_id() {
	return ad_account_id;
}

public void setAd_account_id(long ad_account_id) {
	this.ad_account_id = ad_account_id;
}

public String getAd_account_name() {
	return ad_account_name;
}

public void setAd_account_name(String ad_account_name) {
	this.ad_account_name = ad_account_name;
}

public String getAccess_token() {
	return access_token;
}

public void setAccess_token(String access_token) {
	this.access_token = access_token;
}

}
