package com.madhouse.spring.dao;

import com.madhouse.spring.model.FbAccount;

public interface FbAccountDAO 
{
	public void saveOrUpdate(FbAccount fbaccount,int type);
	
}