package com.account.plat.impl.chYhJl.util;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class GioneeUtil {
//	static String port = "443";
//	static String verify_url = "https://id.gionee.com:" + port + "/account/verify.do";
//	static String apiKey = "7EBF116B7DC847C4A109F51C858320E4"; // 替换成商户申请获取的APIKey
//	static String secretKey = "1F2DF0D4022B48DEA3E18537E4159DF3"; // 替换成商户申请获取的SecretKey
//	static String host = "id.gionee.com";
//	static String url = "/account/verify.do";
//	static String method = "POST";
//
//	public static void main(String[] args) {
//		// amigoToken是通过文档“4.3.1.5获取AmigoToken等信息”接口获取，原封不动作为请求验证的内容
//		// 替换成客户端登录成功后获取到的amigoToken
//		String amigoToken = "{\"n\":\"2AE1C5AF\",\"v\":\"E6860F594765A58B3FFDC73CF0A00A11F3B36CB6\",\"h\":\"0C0C20C0F9BE40859FC9C151FFB763DE\",\"t\":\"1403850398\"}";
//
//		if (apiKey.equals("")) {
//			LOG.error(String.format("apiKey is empty!"));
//			return;
//		}
//
//		if (secretKey.equals("")) {
//			LOG.error(String.format("secretKey is empty!"));
//			return;
//		}
//
//		verify(amigoToken);
//	}


    static class CryptoUtility {

        private static final String MAC_NAME = "HmacSHA1";

        public static String macSig(String host, String port, String macKey, String timestamp, String nonce, String method, String uri) {
            // 1. build mac string
            // 2. hmac-sha1
            // 3. base64-encoded

            StringBuffer buffer = new StringBuffer();
            buffer.append(timestamp).append("\n");
            buffer.append(nonce).append("\n");
            buffer.append(method.toUpperCase()).append("\n");
            buffer.append(uri).append("\n");
            buffer.append(host.toLowerCase()).append("\n");
            buffer.append(port).append("\n");
            buffer.append("\n");
            String text = buffer.toString();

            byte[] ciphertext = null;
            try {
                ciphertext = hmacSHA1Encrypt(macKey, text);
            } catch (Throwable e) {
                e.printStackTrace();
                return null;
            }

            String sigString = Base64.encodeToString(ciphertext, Base64.DEFAULT);
            return sigString;
        }

        public static byte[] hmacSHA1Encrypt(String encryptKey, String encryptText) throws InvalidKeyException, NoSuchAlgorithmException {
            Mac mac = Mac.getInstance(MAC_NAME);
            mac.init(new SecretKeySpec(StringUtil.getBytes(encryptKey), MAC_NAME));
            return mac.doFinal(StringUtil.getBytes(encryptText));
        }

    }

    static class StringUtil {
        public static final String UTF8 = "UTF-8";
        private static final byte[] BYTEARRAY = new byte[0];

        public static boolean isNullOrEmpty(String s) {
            if (s == null || s.isEmpty() || s.trim().isEmpty())
                return true;
            return false;
        }

        public static String randomStr() {
            return CamelUtility.uuidToString(UUID.randomUUID());
        }

        public static byte[] getBytes(String value) {
            return getBytes(value, UTF8);
        }

        public static byte[] getBytes(String value, String charset) {
            if (isNullOrEmpty(value))
                return BYTEARRAY;
            if (isNullOrEmpty(charset))
                charset = UTF8;
            try {
                return value.getBytes(charset);
            } catch (UnsupportedEncodingException e) {
                return BYTEARRAY;
            }
        }
    }

    static class CamelUtility {
        public static final int SizeOfUUID = 16;
        private static final int SizeOfLong = 8;
        private static final int BitsOfByte = 8;
        private static final int MBLShift = (SizeOfLong - 1) * BitsOfByte;

        private static final char[] HEX_CHAR_TABLE = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

        public static String uuidToString(UUID uuid) {
            long[] ll = {uuid.getMostSignificantBits(), uuid.getLeastSignificantBits()};
            StringBuilder str = new StringBuilder(SizeOfUUID * 2);
            for (int m = 0; m < ll.length; ++m) {
                for (int i = MBLShift; i > 0; i -= BitsOfByte)
                    formatAsHex((byte) (ll[m] >>> i), str);
                formatAsHex((byte) (ll[m]), str);
            }
            return str.toString();
        }

        public static void formatAsHex(byte b, StringBuilder s) {
            s.append(HEX_CHAR_TABLE[(b >>> 4) & 0x0F]);
            s.append(HEX_CHAR_TABLE[b & 0x0F]);
        }

    }
}
