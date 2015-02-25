<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
登录页，测试1211
 <%
 if (session.isNew()){
	 System.out.println("未登录");
	 session.setAttribute("login_status",true);
 } else {
	 System.out.println("session:"+session.getAttribute("login_status"));
	 System.out.println("已登录");
 }
 %>
</body>
</html>