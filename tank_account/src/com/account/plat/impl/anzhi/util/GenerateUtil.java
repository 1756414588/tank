package com.account.plat.impl.anzhi.util;


public class GenerateUtil {


    public static final String generateSessionToken(String uid, String loginTime, Integer loginType) {
        return Base64.encodeToString(uid + "_" + loginTime + "_" + String.valueOf(loginType));
    }

    public static void main(String[] args) {
        //LOG.error(generateSessionToken("20130328165207hlUept53TD","1368870185",1));
//		LOG.error(Base64.encodeToString("c318br6RLex12IeBs0Ta6wo1" + loginName + sid + app.getAppSecret()));
    }

}
