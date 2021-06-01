package com.account.util;

import java.util.Date;

public class VerifyCodeUtil {

    private static final String src_number = "0123456789";
    private static final String src_lower = "abcdefghijkLmnopqrstuvwxyz";

    public static String getVerifyCode() {
        return get(12);
    }

    private static String get(int size) {
        StringBuffer r = new StringBuffer(size);
        String src = src_number + src_lower;
        for (int i = 0; i < size; i++) {
            r.append(getRandomChar(src));
        }
        return r.toString();
    }

    private static String getRandomChar(String src) {
        return String.valueOf((src.charAt((int) (Math.random() * src.length()))));
    }

    public static void main(String[] args) {
//		Set<String> set = new HashSet<String>();
//		long nowTime = System.currentTimeMillis();
//
//		for (int i = 0; i < 100000000; i++) {
//			set.add(getVerifyCode());
//
//			if (i % 5000000 == 0) {
//				LOG.error("生成[" + (i + 1) + "]数据消费时间:" + (System.currentTimeMillis() - nowTime) / 1000);
//				LOG.error("集合中的个数为:" + set.size());
//			}
//		}

        Date date = new Date();
        //LOG.error(date.getTime());
        //LOG.error(System.currentTimeMillis());


    }
}