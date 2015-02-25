package com.madhouse.spring.dao;


import java.util.List;
import com.madhouse.spring.model.FmpUser;

public interface FmpUserDAO 
{
	public void insert(FmpUser fmpuser);
	
	public void insertNamedParameter(FmpUser fmpuser);
			
	public void insertBatch(List<FmpUser> fmpuser);
	
	public void insertBatchNamedParameter(List<FmpUser> fmpuser);
	
	public void insertBatchNamedParameter2(List<FmpUser> fmpuser);
			
	public void insertBatchSQL(String sql);
	
	public FmpUser findByFmpUserEmail(String fmpUserEmail);
	
	public FmpUser findByFmpUserId(long fmpUserId);
	
	public FmpUser findByFmpUserId2(long fmpUserId);

	public List<FmpUser> findAll();
	
	public List<FmpUser> findAll2();
	
	public String findFmpUserNameById(long fmpUserId);
	
	public int findTotalFmpUser();
	
}