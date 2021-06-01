package com.account.util;

import com.account.service.PhpRecService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.UnsupportedEncodingException;
import java.util.Properties;

public class CryptHelper {
    public static Logger LOG = LoggerFactory.getLogger(CryptHelper.class);
    private static String ENCODE = "iso-8859-1";


    //加密utf-8字符串, 生成一个原始编码的加密字符串
    public static String xxteaEncrypt(String in, String key) {
        byte[] bytes;
        try {
            bytes = XXTEA.xxtea_encrypt(in.getBytes(), key.getBytes());
            printDecString("xxteaEncrypt:", bytes);
            return new String(bytes, ENCODE);
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return "";
    }

    //解密一个原始编码的加密字符串
    public static String xxteaDecrypt(String in, String key) {
        byte[] bytes;
        try {
            bytes = in.getBytes(ENCODE);
            printDecString("xxteaDecrypt:", bytes);
            return new String(XXTEA.xxtea_decrypt(bytes, key.getBytes()));
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return "";
    }

    //对二进制数据进行加密，生成二进制数据
    public static byte[] xxteaEncrypt(byte[] in, String key) {
        return XXTEA.xxtea_encrypt(in, key.getBytes());
    }

    // 对二进制数据进行解密,恢复成utf8的字符串
    public static String xxteaDecrypt(byte[] in, String key) {
        return new String(XXTEA.xxtea_decrypt(in, key.getBytes()));
    }

    public static void main(String[] args) {
        Properties initProp = new Properties(System.getProperties());
        LOG.error("file.encoding:" + initProp.getProperty("file.encoding"));
        LOG.error("file.encoding:" + initProp.getProperty("user.language"));

        String encrypt = xxteaEncrypt("中文[{cmd:doLogin,code:1003,msg:,response:{}}]", "ooxx");
        String decrypt = xxteaDecrypt(encrypt, "ooxx");
        PrintHelper.println("original:" + decrypt);

    }

    public static void printHexString(String hint, byte[] b) {
        System.out.print(hint);
        for (int i = 0; i < b.length; i++) {
            String hex = Integer.toHexString(b[i] & 0xFF);
            if (hex.length() == 1) {
                hex = '0' + hex;
            }
            System.out.print(hex.toUpperCase() + " ");
        }
        LOG.error("");
    }

    public static void printDecString(String hint, byte[] b) {
        System.out.print(hint);
        for (int i = 0; i < b.length; i++) {
            String hex = Integer.toString((int) b[i]);
            System.out.print(hex + " ");
        }
        LOG.error("");
    }

}

class XXTEA {
    public static final int XXTEA_DELTA = 0x9e3779b9;

    static void xxtea_long_encrypt(int[] v, int[] k) {
        int n = v.length - 1;
        int z = v[n], y = v[0], p, q = 6 + 52 / (n + 1), sum = 0, e;
        if (n < 1) {
            return;
        }
        while (0 < q--) {
            sum += XXTEA_DELTA;
            e = sum >>> 2 & 3;
            for (p = 0; p < n; p++) {
                y = v[p + 1];
                z = v[p] += (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
            }
            y = v[0];
            z = v[n] += (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
        }
    }

    static void xxtea_long_decrypt(int[] v, int[] k) {
        int n = v.length - 1;
        int z = v[n], y = v[0], p, q = 6 + 52 / (n + 1), sum = q * XXTEA_DELTA, e;
        if (n < 1) {
            return;
        }
        while (sum != 0) {
            e = sum >>> 2 & 3;
            for (p = n; p > 0; p--) {
                z = v[p - 1];
                y = v[p] -= (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
            }
            z = v[n];
            y = v[0] -= (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
            sum -= XXTEA_DELTA;
        }
    }

    static byte[] fix_key_length(byte[] key) {
        byte[] tmp = new byte[16];
        System.arraycopy(key, 0, tmp, 0, key.length);
        return tmp;
    }

    static int[] xxtea_to_long_array(byte[] data, int include_length) {
        int i, n, result[];
        int len = data.length;
        n = len >> 2;// int数组长度
        n = (((len & 3) == 0) ? n : n + 1);// data数组长度不能被4整除时
        if (include_length != 0) {
            result = new int[n + 1];
            result[n] = len;
        } else {
            result = new int[n];
        }

        for (i = 0; i < len; i++) {
            result[i >>> 2] |= (0x000000ff & data[i]) << ((i & 3) << 3);
        }

        return result;
    }

    static byte[] xxtea_to_byte_array(int[] data, int include_length) {
        int i, n, m;
        byte[] result;
        int len = data.length;
        n = len << 2;
        if (include_length != 0) {
            m = data[len - 1];
            if ((m < n - 7) || (m > n - 4))
//			if (m > n)
                return null;
            n = m;
        }

        result = new byte[n];
        for (i = 0; i < n; i++) {
            result[i] = (byte) ((data[i >>> 2] >>> ((i & 3) << 3)) & 0xff);
        }

        return result;
    }

    static byte[] do_xxtea_encrypt(byte[] data, byte[] key) {
        byte[] result;
        int v[], k[];

        v = xxtea_to_long_array(data, 1);
        k = xxtea_to_long_array(key, 0);
        xxtea_long_encrypt(v, k);
        result = xxtea_to_byte_array(v, 0);
        return result;
    }

    static byte[] do_xxtea_decrypt(byte[] data, byte[] key) {
        byte[] result;
        int v[], k[];

        v = xxtea_to_long_array(data, 0);
        k = xxtea_to_long_array(key, 0);
        xxtea_long_decrypt(v, k);
        result = xxtea_to_byte_array(v, 1);

        return result;
    }

    static byte[] xxtea_encrypt(byte[] data, byte[] key) {
        byte[] result;

        if (key.length < 16) {
            byte[] key2 = fix_key_length(key);
            result = do_xxtea_encrypt(data, key2);
        } else {
            result = do_xxtea_encrypt(data, key);
        }

        return result;
    }

    static byte[] xxtea_decrypt(byte[] data, byte[] key) {
        byte[] result;

        if (key.length < 16) {
            byte[] key2 = fix_key_length(key);
            result = do_xxtea_decrypt(data, key2);
        } else {
            result = do_xxtea_decrypt(data, key);
        }

        return result;
    }
}
