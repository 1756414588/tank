package com.account.plat.impl.chYhX7;

import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeMap;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

import org.apache.commons.codec.binary.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class VerifyTest {
    public static Logger LOG = LoggerFactory.getLogger(VerifyTest.class);

    //签名算法 
    public static final String SIGN_ALGORITHMS = "SHA1WithRSA";

    //RSA最大解密密文大小
    private static final int MAX_DECRYPT_BLOCK = 128;

    //Base64解码
    public static byte[] decode(String str) {
        return Base64.decodeBase64(str.getBytes());
    }

    //Base64编码
    public static String encode(final byte[] bytes) {
        return new String(Base64.encodeBase64(bytes));
    }

    //从字符串加载公钥
    public static PublicKey loadPublicKeyByStr(String key) throws Exception {
        try {
            String publicKeyStr = "";

            int count = 0;
            for (int i = 0; i < key.length(); ++i) {
                if (count < 64) {
                    publicKeyStr += key.charAt(i);
                    count++;
                } else {
                    publicKeyStr += key.charAt(i) + "\r\n";
                    count = 0;
                }
            }
            byte[] buffer = decode(publicKeyStr);
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            X509EncodedKeySpec keySpec = new X509EncodedKeySpec(buffer);
            PublicKey publicKey = keyFactory.generatePublic(keySpec);
            //LOG.error(publicKey);
            return publicKey;
        } catch (NoSuchAlgorithmException e) {
            throw new Exception("无此算法");
        } catch (InvalidKeySpecException e) {
            throw new Exception("公钥非法");
        } catch (NullPointerException e) {
            throw new Exception("公钥数据为空");
        }
    }

    //公钥解密
    public static byte[] decrypt(PublicKey publicKey, byte[] cipherData) throws Exception {
        if (publicKey == null) {
            throw new Exception("解密公钥为空, 请设置");
        }
        Cipher cipher = null;
        try {
            cipher = Cipher.getInstance("RSA");
            cipher.init(Cipher.DECRYPT_MODE, publicKey);

            int inputLen = cipherData.length;
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            int offSet = 0;
            byte[] cache;
            int i = 0;
            // 对数据分段解密
            while (inputLen - offSet > 0) {
                if (inputLen - offSet > MAX_DECRYPT_BLOCK) {
                    cache = cipher.doFinal(cipherData, offSet, MAX_DECRYPT_BLOCK);
                } else {
                    cache = cipher.doFinal(cipherData, offSet, inputLen - offSet);
                }
                out.write(cache, 0, cache.length);
                i++;
                offSet = i * MAX_DECRYPT_BLOCK;
            }
            byte[] decryptedData = out.toByteArray();
            out.close();
            return decryptedData;
        } catch (NoSuchAlgorithmException e) {
            throw new Exception("无此解密算法");
        } catch (NoSuchPaddingException e) {
            e.printStackTrace();
            return null;
        } catch (InvalidKeyException e) {
            throw new Exception("解密公钥非法,请检查");
        } catch (IllegalBlockSizeException e) {
            throw new Exception("密文长度非法");
        } catch (BadPaddingException e) {
            throw new Exception("密文数据已损坏");
        }
    }

    //RSA验签名检查   
    private static boolean doCheck(String content, String sign, PublicKey publicKey) {
        try {
            java.security.Signature signature = java.security.Signature.getInstance(SIGN_ALGORITHMS);

            signature.initVerify(publicKey);
            //LOG.error(content.getBytes());
            signature.update(content.getBytes());

            boolean bverify = signature.verify(decode(sign));
            return bverify;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    private static String buildHttpQuery(Map<String, String> data) throws UnsupportedEncodingException {
        String builder = new String();
        for (Entry<String, String> pair : data.entrySet()) {
            builder += URLEncoder.encode(pair.getKey(), "utf-8") + "=" + URLEncoder.encode(pair.getValue(), "utf-8") + "&";
        }
        return builder.substring(0, builder.length() - 1);
    }

    private static Map<String, String> decodeHttpQuery(String httpQuery) throws UnsupportedEncodingException {
        Map<String, String> map = new TreeMap<String, String>();

        for (String s : httpQuery.split("&")) {
            String pair[] = s.split("=");
            map.put(URLDecoder.decode(pair[0], "utf-8"), URLDecoder.decode(pair[1], "utf-8"));
        }

        return map;
    }

    public static Map<String, String> check(Map<String, String> value, String sign, String publicKey) {
        try {
            String sourceStr = buildHttpQuery(value);
            // LOG.error(sourceStr);
            // 验签
            if (!doCheck(sourceStr, sign, loadPublicKeyByStr(publicKey))) {
                LOG.error("verify_failed");
            } else {
                // 解密
                String decryptData = new String(decrypt(loadPublicKeyByStr(publicKey), decode(value.get("encryp_data"))));
                LOG.error("decryptData:" + decryptData);
                Map<String, String> decryptMap = decodeHttpQuery(decryptData);
                // 这里是比较解密后的订单号与我们通过POST传递过来的订单号是否一致
                if (decryptMap.containsKey("game_orderid") && decryptMap.get("game_orderid").equals(value.get("game_orderid"))) {
                    return decryptMap;
                } else {
                    return null;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
