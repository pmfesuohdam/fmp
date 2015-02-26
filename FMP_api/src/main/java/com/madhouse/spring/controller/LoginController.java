package com.madhouse.spring.controller;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.validation.Valid;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.validation.Errors;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.madhouse.spring.model.FbAccount;
import com.madhouse.spring.model.FmpUser;
import com.madhouse.spring.model.LoginModel;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.madhouse.spring.common.HttpUtil;
import com.madhouse.spring.common.JdbcSpringUtil;
import com.madhouse.spring.common.LoginMsg;
import com.madhouse.spring.common.MD5Digest;
import com.madhouse.spring.common.SimpleValidateMsg;
import com.madhouse.spring.dao.FmpUserDAO;
import com.madhouse.spring.dao.impl.JdbcFmpUserDAO;
import com.madhouse.spring.dao.FbAccountDAO;
import com.madhouse.spring.dao.impl.JdbcFbAccountDAO;
import com.madhouse.spring.ds.Businesses.Businesses;
import com.madhouse.spring.ds.Businesses.Data;
import com.madhouse.spring.ds.Adaccounts.AdAccounts;

@RestController
public class LoginController {
	private FmpUserDAO fmpuserDAO = (FmpUserDAO) JdbcSpringUtil
			.getBean("fmpuserDAO");
	private FbAccountDAO fbaccountDAO = (FbAccountDAO) JdbcSpringUtil
			.getBean("fbaccountDAO");

	@RequestMapping(value = "/login/test/self", method = RequestMethod.GET, produces = { "application/json" })
	@ResponseStatus(HttpStatus.OK)
	public String test(
			@RequestParam(value = "proxy", required = false, defaultValue = "false") boolean proxy,
			@RequestParam(value = "host", required = false, defaultValue = "") String host,
			@RequestParam(value = "port", required = false, defaultValue = "") int port)
	throws JsonProcessingException {
		List<Data> businessesData = null;
		List<com.madhouse.spring.ds.Adaccounts.Data> adaccountsData = null;
		try {
			String access_tok="CAALFqlUZB2acBABgrdEVAJaMZCuE3g9HSZCbvMfBr3wXZBGVOqnjZCzbyfGYZA3vDRnsm2Cc52gK4NIZBnXxQnyZCFxECKVTjXWrzZACCwipdbca3aGP4zuvejfZBJwS60eq3ZB0NNVSn2VlE6yFcTMEVp6PKdN1ZBO5j0Uh3WT2nfYWOV13iLCz8ZCnMewWK2uR9oKowCxloDvnYXYMKVnJiBdo2xL20O7JqV0AZD";
			String ret[] = new HttpUtil()
					.doGet("https://graph.facebook.com/v2.2/me/businesses?access_token="+access_tok,
							proxy,host,port);
			System.out.println(ret[1]);
			Gson gson = new Gson();
			Businesses businesses = gson.fromJson(ret[1], Businesses.class);
			businessesData = businesses.getData();
/*			for (int i = 0; i < businessesData.size(); i++) {
				System.out.println(businessesData.get(i).getName());
			}*/
			for (int i = 0; i < businessesData.size(); i++) {
				System.out.println("business name:"+businessesData.get(i).getName());
				//遍历business
			    String business_id=businessesData.get(i).getId();
			    System.out.println("business_id:"+business_id);
			    String qActUrl="https://graph.facebook.com/v2.2/"+business_id+"/adaccounts?access_token="+access_tok;
			    System.out.println("qActUrl:"+qActUrl);
			    String ret2[]=new HttpUtil().doGet("https://graph.facebook.com/v2.2/"+business_id+"/adaccounts?access_token="+access_tok,proxy,host,port);
			   System.out.println("ret2:"+ret2[1]);
			   //解析adaccounts api
			   Gson gson_act = new Gson();
			   AdAccounts adaccounts = gson_act.fromJson(ret2[1],AdAccounts.class);
			   adaccountsData = adaccounts.getData();
				for (int i1 = 0; i1 < adaccountsData.size(); i1++) {
					System.out.println("adaccount:"+adaccountsData.get(i1).getAccount_id());
				}
			}
			//System.out.println(businesses.getPaging().getNext());
			System.out.println(new ObjectMapper()
					.writeValueAsString(businesses));
			System.out.println(new ObjectMapper()
					.writeValueAsString(businessesData));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ObjectMapper()
		.writeValueAsString(businessesData);
	}

	/* go through business accounts,then save fb ad account */
	@RequestMapping(value = "/login/save/self", method = RequestMethod.POST, produces = { "application/json" })
	@ResponseStatus(HttpStatus.OK)
	public String saveLoginInfo(
			@RequestParam(value = "ac", required = false, defaultValue = "") String ac)
			throws JsonProcessingException {
		boolean hasErr = false;
		FbAccount fbaccount = new FbAccount();
		fbaccount.setAccess_token(ac);
		// 向graph api请求/me/businesses
		String ret[] = new HttpUtil().doGet(
				"https://graph.facebook.com/v2.2/me/businesses?access_token="
						+ ac,false,"",0);
		System.out.println(ret[1]);
		// 检查状态
		if (ret[0].equals("200")) {

		} else {
			hasErr = true;
		}
		fbaccountDAO.saveOrUpdate(fbaccount, 0);
		if (hasErr == false) {
			return "{\"status\":\"true\"}";
		}
		return "{\"status\":\"false\"}";
	}

	/* logout system */
	@RequestMapping(value = "/login/delete/self", method = RequestMethod.GET, produces = { "application/json" })
	@ResponseStatus(HttpStatus.OK)
	public String logOut(HttpSession session) {
		session.invalidate();
		return "{\"status\":\"false\"}";
	}

	/* get login status */
	@RequestMapping(value = "/login/get/self", method = RequestMethod.GET, produces = { "application/json" })
	@ResponseStatus(HttpStatus.OK)
	public String getLoginStatus(HttpSession session) {
		String user_status = (String) session.getAttribute("user_online");
		if (user_status == null || user_status.isEmpty()) {
			return "{\"status\":\"false\"}";
		}
		return "{\"status\":\"true\"}";

	}

	/* post login data */
	@RequestMapping(value = "/login/post/self", method = RequestMethod.POST, produces = { "application/json" })
	@ResponseStatus(HttpStatus.OK)
	public String doLogin(@Valid @ModelAttribute("login") LoginModel login,
			Errors errors, HttpServletRequest request) throws Exception {
		ObjectMapper json_mapper = new ObjectMapper();
		ArrayList<SimpleValidateMsg> msgs = new ArrayList<SimpleValidateMsg>();
		String state = "false";
		if (errors.hasErrors()) {
			List<FieldError> fieldErrors = errors.getFieldErrors();
			for (FieldError fieldError : fieldErrors) {
				msgs.add(new SimpleValidateMsg(fieldError.getField(),
						fieldError.getDefaultMessage()));
			}
		}
		// 查询用户，如果存在，再检查用户名
		FmpUser fu = fmpuserDAO.findByFmpUserEmail(request
				.getParameter("email"));
		if (fu == null) {
			msgs.add(new SimpleValidateMsg("email", "user not existed!"));
		} else {
			String digest = new MD5Digest().run(request.getParameter("passwd"));
			if (!digest.equals(fu.getPasswd())) {
				msgs.add(new SimpleValidateMsg("passwd", "password incorrect!"));
			}
		}
		if (!(msgs != null && msgs.size() > 0)) {
			msgs.add(new SimpleValidateMsg("", ""));
			state = "true";
			(request.getSession()).setAttribute("user_online", "true");
			(request.getSession()).setAttribute("user_email", fu.getEmail());
			(request.getSession()).setAttribute("user_name", fu.getName());
		}
		// System.out.println(new jdbcFmpUserDao().findAllUsers());
		/*
		 * ApplicationContext context = new
		 * ClassPathXmlApplicationContext("jdbcContext.xml");
		 * 
		 * FmpUserDAO fmpuserDAO = (FmpUserDAO) context.getBean("fmpuserDAO");
		 */
		// System.out.println(fmpuserDAO.findFmpUserNameById(10001));
		return json_mapper.writeValueAsString(new LoginMsg(msgs.get(0), state,
				"settings/"));
	}
}