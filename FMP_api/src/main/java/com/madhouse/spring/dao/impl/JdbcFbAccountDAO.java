package com.madhouse.spring.dao.impl;

import org.springframework.jdbc.core.support.JdbcDaoSupport;
import com.madhouse.spring.dao.FbAccountDAO;
import com.madhouse.spring.model.FbAccount;


public class JdbcFbAccountDAO extends JdbcDaoSupport implements FbAccountDAO{

	@Override
	public void saveOrUpdate(FbAccount fbaccount,int type) {
		if (type==1) {
	        // update
	        String sql = "UPDATE t_fb_account SET ad_account_name=?, access_token=? WHERE ad_account_id=?";
	        getJdbcTemplate().update(sql, fbaccount.getAd_account_name(), fbaccount.getAccess_token(),
	        		fbaccount.getAd_account_id());
	    } else {
	        // insert
	        String sql = "INSERT INTO t_fb_account (ad_account_name, access_token)"
	                    + " VALUES (?, ?)";
	        getJdbcTemplate().update( sql, fbaccount.getAd_account_name(), fbaccount.getAccess_token() );
	    }
	}




}
