package com.game.util;

/**
 * @author zhangdh
 * @ClassName: NumberHelper
 * @Description: 数字相关的处理工具类
 * @date 2017/4/17 11:02
 */
public class NumberHelper {
	
	public final static int ZERO = 0; //数字常量
	
	public final static int HUNDRED_INT = 100; //数字常量

	public final static float HUNDRED_FLOAT = 100.0f; //数字常量
	
	public final static int THOUSAND = 1000; //数字常量

    public final static int TEN_THOUSAND = 10000; //数字常量万

    public final static int I_MILLION = 1000000; //数字常量万

    public final static double TEN_THOUSAND_DOUBLE = 10000d; //数字常量万

    /**
     * 将整数V转化为byte数组
     * @param v 需要转换的整数
     * @return v 按位匹配的byte 数组
     */
    public static byte[] toBytes(int v) {
        byte[] bytes = new byte[32];
        int bytePos = 32;
        int radix = 1 << 1;
        int mask = radix - 1;
        do {
            bytes[--bytePos] = (byte) (v & mask);
            v >>>= 1;
        } while (v != 0);
        return bytes;
    }

   /**
    * 
   * 取得正文长度
   * @param b
   * @param index
   * @return  
   * short
    */
    static public short getShort(byte[] b, int index) {
        return (short) (((b[index + 1] & 0xff) | b[index + 0] << 8));
    }
    
}
