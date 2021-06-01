package com.account.util;

import com.account.plat.impl.kaopu.MD5Util;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * Created by z on 2017-09-27.
 * AES加密工具类
 */
public class AESUtil {
    public static Logger LOG = LoggerFactory.getLogger(AESUtil.class);
    private static final String KEY_ALGORITHM = "AES";
    private static final String DEFAULT_CIPHER_ALGORITHM = "AES/CBC/NoPadding";//默认的加密算法

    /**
     * AES 加密操作
     *
     * @param content 待加密内容
     * @param key     加密密码
     * @param iv      偏移变量
     * @return 返回Base64转码后的加密数据
     */
    public static String encrypt(String content, String key, String iv) {
        try {
            Cipher cipher = Cipher.getInstance(DEFAULT_CIPHER_ALGORITHM); // 创建密码器
            int blockSize = cipher.getBlockSize();
            byte[] dataBytes = content.getBytes();
            int plaintextLength = dataBytes.length;
            if (plaintextLength % blockSize != 0) {
                plaintextLength = plaintextLength + (blockSize - (plaintextLength % blockSize));
            }
            byte[] plaintext = new byte[plaintextLength];
            System.arraycopy(dataBytes, 0, plaintext, 0, dataBytes.length);

            SecretKeySpec keyspec = new SecretKeySpec(key.getBytes(), KEY_ALGORITHM);
            IvParameterSpec ivspec = new IvParameterSpec(iv.getBytes());
            cipher.init(Cipher.ENCRYPT_MODE, keyspec, ivspec); // 初始化为加密模式的密码器
            byte[] encrypted = cipher.doFinal(plaintext);
            return new sun.misc.BASE64Encoder().encode(encrypted); //通过Base64转码返回
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * AES 解密操作
     *
     * @param content
     * @param key
     * @param iv
     * @return
     */
    public static String decrypt(String content, String key, String iv) {
        try {
            byte[] encrypted1 = new sun.misc.BASE64Decoder().decodeBuffer(content);
            Cipher cipher = Cipher.getInstance(DEFAULT_CIPHER_ALGORITHM); // 创建密码器
            SecretKeySpec keyspec = new SecretKeySpec(key.getBytes(), KEY_ALGORITHM);
            IvParameterSpec ivspec = new IvParameterSpec(iv.getBytes());
            cipher.init(Cipher.DECRYPT_MODE, keyspec, ivspec); //使用密钥初始化，设置为解密模式
            byte[] original = cipher.doFinal(encrypted1); //执行操作
            String originalString = new String(original);
            return originalString;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static void main(String[] args) {
        LOG.error(AESUtil.decrypt("87WsBNOldw93V0ESOSUBMdFLfw1qTLGnI0EG8rjTiG9H7o8mIrCYRV6hTvxbwZkOAfW0Xk9uM6ud\n" +
                "ljJk/Z5E4ElW/YjJO/yP8ajOLUQMi7K8DLfMafARZ8BppyfhzTAFyXCrjgg6886S1Fs6QNHPDw==", "drOl6tD44k0lc9OE", "drOl6tD44k0lc9OE"));

    }


}



