package com.account.plat.impl.youlongteng;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.account.plat.impl.self.util.MD5;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author ChenKui
 * @version 创建时间：2016-6-12 下午6:24:24
 * @declare
 */

public class Tst {

    public static Logger LOG = LoggerFactory.getLogger(Tst.class);


    public static String getSignNation(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("oauth_signature")) {
                continue;
            }
            if (k.equals("plat")) {
                continue;
            }

            if (params.get(k) == null) {
                continue;
            }
            v = (String) params.get(k);

            k = encode(k);
            v = encode(v);

            if (str.equals("")) {
                str = k + "=" + v;
            } else {
                str = str + "&" + k + "=" + v;
            }
        }
        return str;
    }


    public void productPaySignAndRequest(Map<String, String> params, String url) {
        try {
            String source = URLEncoder.encode("J2k0nTEMSV2XhkYzDxE3l5Wb0tyVAEHm8g0pLxCb", "utf-8") + "&" + "POST" + "&"
                    + URLEncoder.encode(url, "utf-8") + "&" + URLEncoder.encode(sortParams(params), "utf-8");
            String s2 = source.replace("+", "%20").replace("*", "%2A").replace("%7E", "~");

            String oauth_signature = encryptMd5(s2);
            params.put("oauth_signature", oauth_signature);
            LOG.error("[oauth_signature]" + oauth_signature);
            // Util.log("--recharge--【url】" + url + "【params】" +
            // params.toString());
            // submitPostData(url, params, callback);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String sortParams(Map<String, String> params) {
        List<String> keys = new ArrayList(params.keySet());
        Collections.sort(keys);
        String prestr = "";
        for (String key : keys) {
            String value = (String) params.get(key);
            prestr = prestr + key + "=" + value + "&";
        }
        prestr = prestr.substring(0, prestr.length() - 1);
        LOG.error("[prestr]" + prestr);
        return prestr;
    }

    private static String encryptMd5(String secret_key) {
        MessageDigest messageDigest = null;
        try {
            messageDigest = MessageDigest.getInstance("MD5");
            messageDigest.reset();
            messageDigest.update(secret_key.getBytes("UTF-8"));
        } catch (NoSuchAlgorithmException e) {
            System.exit(-1);
        } catch (UnsupportedEncodingException localUnsupportedEncodingException) {
        }
        byte[] byteArray = messageDigest.digest();

        StringBuffer md5StrBuff = new StringBuffer();
        for (int i = 0; i < byteArray.length; i++) {
            if (Integer.toHexString(0xFF & byteArray[i]).length() == 1) {
                md5StrBuff.append("0").append(Integer.toHexString(0xFF & byteArray[i]));
            } else {
                md5StrBuff.append(Integer.toHexString(0xFF & byteArray[i]));
            }
        }
        return md5StrBuff.toString();
    }

    public static String encode(String param) {
        try {
            return URLEncoder.encode(param, "utf-8").replace("+", "%20").replace("*", "%2A").replace("%7E", "~");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void main(String[] args) {
        String oauth_signature = "a1000c0ac288018af30a4f52eef1998d";
        String SecretKey = "J2k0nTEMSV2XhkYzDxE3l5Wb0tyVAEHm8g0pLxCb";
        // String PAY_URL = "http://us.p2.youlongteng.com/payment/notify";
        String PAY_URL = "http://ylt.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=ylt";
        Map<String, String> param = new HashMap<String, String>();
//		param.put("uid", "1500013225");
//		param.put("apply_time", "2016-06-12 20:08:59");
//		param.put("product_id", "1");
//		param.put("status", "1");
//		param.put("currency", "rmb");
//		param.put("amount", "10.0000");
//		param.put("plat", "ylt");
//		param.put("targetamount", "100.00");
//		param.put("exts", "1_135290_1465733338448");
//		 param.put("oauth_signature", "a1000c0ac288018af30a4f52eef1998d");
//		param.put("game_area", "1");
//		param.put("order_sn", "201606122008590000077640");
//		param.put("platment", "googleplay");
//		
//		param.put("uid", "1500013225");
//		param.put("apply_time", "2016-06-12 20:13:28");
//		param.put("product_id", "1");
//		param.put("oauth_version", "1.0");
//		param.put("status", "1");
//		param.put("oauth_nonce", "1465734344");

//		param.put("currency", "rmb");
//		param.put("amount", "10.0000");
//		param.put("plat", "ylt");
//		param.put("targetamount", "100.00");
//		param.put("exts", "1_135290_1465733605278");
//		param.put("oauth_signature", "0888191f9526459dabaf3506219864d1");
//		param.put("oauth_signature_method", "md5");
//		param.put("game_area", "1");
//		param.put("order_sn", "201606122013280000079500");
//		param.put("platment", "googleplay");
//		param.put("oauth_timestamp", "1465734344");
//
//		LOG.error("[map参数]" + param.toString());
//		String s = getSignNation(param);
//		LOG.error("[s参数]" + s);
//		String s1 = encode(s);
//		LOG.error("[S1参数]" + s1);
//		String s2 = encode(PAY_URL);
//		LOG.error("[S2参数]" + s2);
//		String s3 = "POST&" + s2 + "&" + s1;
//		LOG.error("[S3参数]" + s3);
//		
//		String s4 = SecretKey + "&";
//		LOG.error("[S4参数]" + s4);
////		String sign = MD5.md5Digest(s4 + s3);
//		String sign = encryptMd5(s4 + s3);
//
//		LOG.error("[签名原文]" + s4 + s3);
//		LOG.error("[签名结果]" + oauth_signature + "|" + sign);
//
//		Tst t = new Tst();
//		t.productPaySignAndRequest(param, PAY_URL);
    }

}
