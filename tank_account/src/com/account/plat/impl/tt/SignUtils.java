package com.account.plat.impl.tt;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import org.apache.commons.codec.binary.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 签名工具类
 *
 * @author TT
 */

public class SignUtils {

    public static Logger LOG = LoggerFactory.getLogger(SignUtils.class);

    public static String sign(String data, String key) {
        if (data == null) {
            LOG.error("源串为null");
            return "";
        }

        if (key == null) {
            LOG.error("key为null");
            return "";
        }
        String sign;
        try {
            sign = encodeBASE64(digestMD5((data + key).getBytes("UTF-8")));
            return sign;
        } catch (Exception e) {
            LOG.error("签名异常");
            return "";
        }
    }

    public static String encodeBASE64(byte[] key) {
        return Base64.encodeBase64String(key);
    }

    public static byte[] digestMD5(byte[] data) throws NoSuchAlgorithmException {
        MessageDigest md5 = MessageDigest.getInstance("MD5");
        md5.update(data);
        return md5.digest();
    }

}
