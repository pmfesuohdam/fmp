package com.madhouse.spring.model;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

public class FmpUserRowMapper implements RowMapper{
	public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
		FmpUser fmp_user = new FmpUser();
		fmp_user.setId(rs.getLong("id"));
		fmp_user.setName(rs.getString("name"));
		fmp_user.setEmail(rs.getString("email"));
		fmp_user.setPasswd(rs.getString("passwd"));
		return fmp_user;
	}
}
