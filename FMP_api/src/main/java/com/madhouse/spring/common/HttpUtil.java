package com.madhouse.spring.common;

import org.apache.commons.httpclient.HostConfiguration;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.URI;
import org.apache.commons.httpclient.methods.GetMethod;

public class HttpUtil {

	public String[] doGet(String http_url, boolean isProxy, String host,
			int port) {
		if (isProxy == true) {
			return this.doGetByProxy(http_url, host, port);
		}
		return doGetNormal(http_url);
	}

	/**
	 * 模拟一个get请求,返回头和body的数组
	 */
	public String[] doGetNormal(String http_url/* , boolean isProxy */) {
		HttpMethod method = null;
		try {
			URI uri = new URI(http_url, true);
			HttpClient client = new HttpClient();
			HostConfiguration hcfg = new HostConfiguration();
			hcfg.setHost(uri);
			client.setHostConfiguration(hcfg);
			/*
			 * if (isProxy) setProxy(client);
			 */
			// 参数验证
			client.getParams().setAuthenticationPreemptive(true);
			// GET请求方式
			method = new GetMethod(http_url);
			client.executeMethod(method);
			System.out.println("state:" + method.getStatusLine());
			// System.out.println("Qs:" + method.getQueryString());
			// System.out.println("response body:" +
			// method.getResponseBodyAsString());
			String ar[] = new String[2];
			ar[0] = String.valueOf(method.getStatusCode());
			ar[1] = method.getResponseBodyAsString();
			return ar;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 模拟一个get请求,返回头和body的数组,用代理的方式
	 */
	public String[] doGetByProxy(String http_url, String host, int port) {
		HttpMethod method = null;
		try {
			URI uri = new URI(http_url, true);
			HttpClient client = new HttpClient();
			HostConfiguration hcfg = new HostConfiguration();
			hcfg.setHost(uri);
			client.setHostConfiguration(hcfg);
			// if (isProxy)
			setProxy(client, host, port);
			// 参数验证
			client.getParams().setAuthenticationPreemptive(true);
			// GET请求方式
			method = new GetMethod(http_url);
			client.executeMethod(method);
			System.out.println("state:" + method.getStatusLine());
			// System.out.println("Qs:" + method.getQueryString());
			// System.out.println("response body:" +
			// method.getResponseBodyAsString());
			String ar[] = new String[2];
			ar[0] = String.valueOf(method.getStatusCode());
			ar[1] = method.getResponseBodyAsString();
			return ar;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 设置代理
	 */
	private void setProxy(HttpClient client, String host, int port) {
		// 设置代理
		client.getHostConfiguration().setProxy(host, port);
		// client.getHostConfiguration().setProxy(HTTP_HOST, HTTP_PORT);
		// client.getState().setProxyCredentials(AuthScope.ANY,
		// new UsernamePasswordCredentials(HTTP_USER, HTTP_PWD));
	}

}
