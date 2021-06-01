package com.account.plat.impl.chQzZzzhgGionee.util;

import java.io.UnsupportedEncodingException;
import java.util.UUID;


/**
 * @author: LiFeng
 * @date:
 * @description: 生成随机字符串, 格式如 648E25FFC90B41A3A075B8F79DB60097
 */
public class StringUtil {

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
	
	/*public static void main(String[] args) {
		String uuidToString = CamelUtility.uuidToString(UUID.randomUUID());
		LOG.error(uuidToString);
	}*/

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

