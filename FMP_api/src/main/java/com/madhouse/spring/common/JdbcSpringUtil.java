package com.madhouse.spring.common;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public final class JdbcSpringUtil {
    private static ApplicationContext  ctx = new ClassPathXmlApplicationContext("jdbcContext.xml");
    
    public static Object getBean(String beanName){
         return ctx.getBean(beanName);
    }
}