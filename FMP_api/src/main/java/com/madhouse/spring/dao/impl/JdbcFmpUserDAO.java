package com.madhouse.spring.dao.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.support.JdbcDaoSupport;

import com.madhouse.spring.dao.FmpUserDAO;
import com.madhouse.spring.model.FmpUser;
import com.madhouse.spring.model.FmpUserRowMapper;

public class JdbcFmpUserDAO extends JdbcDaoSupport implements FmpUserDAO{

	@Override
	public void insert(FmpUser fmpuser) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void insertNamedParameter(FmpUser fmpuser) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void insertBatch(List<FmpUser> fmpuser) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void insertBatchNamedParameter(List<FmpUser> fmpuser) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void insertBatchNamedParameter2(List<FmpUser> fmpuser) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void insertBatchSQL(String sql) {
		// TODO Auto-generated method stub
		
	}
    @Override
    public FmpUser findByFmpUserEmail(String fmpUserEmail) {
    	String sql = "SELECT * from t_fmp_user WHERE email = ?";
    	FmpUser fmp_user=null;
    	try{
    	    fmp_user = (FmpUser)getJdbcTemplate().queryForObject(
    				sql, new Object[] { fmpUserEmail }, 
    				new BeanPropertyRowMapper(FmpUser.class));
    	} catch (DataAccessException e) {
    	}
		return fmp_user;
    }
	@Override
	public FmpUser findByFmpUserId(long fmpUserId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public FmpUser findByFmpUserId2(long fmpUserId) {
		// TODO Auto-generated method stub
		String sql = "SELECT * FROM t_fmp_user WHERE id = ?";
		FmpUser fmp_user = (FmpUser)getJdbcTemplate().queryForObject(
				sql, new Object[] { fmpUserId }, new FmpUserRowMapper());
		return fmp_user;
	}

	@Override
	public List<FmpUser> findAll() {
		// TODO Auto-generated method stub
/*		String sql = "SELECT * FROM t_fmp_user";
		 
		List<FmpUser> fmp_users = new ArrayList<FmpUser>();
	
		List<Map> rows = getJdbcTemplate().queryForList(sql);
		for (Map<K, V> row : rows) {
			FmpUser fmp_user = new FmpUser();
			fmp_user.setId((Long)row.get("id"));
			fmp_user.setName((String)row.get("name"));
			fmp_user.setEmail((String)row.get("email"));
			fmp_user.setPasswd((String)row.get("passwd"));
			fmp_users.add(fmp_user);
		}
		
		return fmp_users;*/
		return null;
	}

	@Override
	public List<FmpUser> findAll2() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String findFmpUserNameById(long fmpUserId) {
		// TODO Auto-generated method stub
		String sql = "SELECT name FROM t_fmp_user WHERE id = ?";
		 
		String name = (String)getJdbcTemplate().queryForObject(
				sql, new Object[] { fmpUserId }, String.class);
		return name;
	}

	@Override
	public int findTotalFmpUser() {
		// TODO Auto-generated method stub
		return 0;
	}
}
