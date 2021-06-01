package com.account.plat.impl.chQzHjdg;

/**
 * 应用接入iAppPay云支付平台sdk集成信息
 */
public class IAppPaySDKConfig {

    /**
     * 应用名称：
     * 应用在iAppPay云支付平台注册的名称
     */
    public final static String APP_NAME = "testFAQ";

    /**
     * 应用编号：
     * 应用在iAppPay云支付平台的编号，此编号用于应用与iAppPay云支付平台的sdk集成
     * 请用商户自己的appid!!
     */
    public static String APP_ID;

    /**
     * 商品编号：
     * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
     * 编号对应商品名称为：1
     */
    public final static int WARES_ID_1 = 6;

    /**
     * 应用私钥：
     * 用于对商户应用发送到平台的数据进行加密
     * <p>
     * JAVA请到后台复制pkcs8格式的私钥！！
     */
    public final static String APPV_KEY = "MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAPB0z74FInKPiumMx79tKFzTjabn2BHu9eWhA5zLMllSYeiTasimqkW+/l1U0i9SBzWPv3ocuzgwIi734B6Sc+M0mqn8rtXgiZ81eUaC5NS7hoXhxkhbsveAkhO6wcUQwgWdXUDgg2hORgJwM8751NhQZuQd/HJ4+CzNgRurUHlnAgMBAAECgYEAiL2U6fWXilhw4bHKYeTcgDVaJ6FOsZwXwBcZq8+t+TetMAqtPh/xUqpzknXK9VgLe30coX+3RBOzTMxvalNUjLU1UsBIBShGs9WVlFwijBubTOgX/VDZE33MQLkWW7RyZa5QkS/wgmuWzMf/vw53jsdgjC+Otn8as4NjC4DgsdkCQQD+hFwSzRr+3ZoomRgB8miYVKg/KVizg/VLBZh+08HfOrCE8ak49zPFyVRoxgwI4615x+2jaism4fZ6c1kn2HSTAkEA8dt6i0ijVumj/VlWTDNhdIVMuztvX35PBNs3h/Y/83Bxr6HeHO1IMsgAowHszJ1bc1kkg5PL2Fp1SO6Ri41gXQJAWA1QkUyWJ1BhMeRtEtdbaj/3iQpz3n8rkI3aCR6XdvQl94hnhAa5yZZydmD17uldrcEGLL/hN+16yTg4wvk2swJBAIeS8XmcSTuSEsQUzSQ/9RQ9GMsnwQG1qxPc0p8bcbPDx2adhQWQGVWl+X1mudflKXtab/Z15eGsq2wrl1iz8l0CQQCT6pZJY6q40u94IW6/H1R/nj0TxgzxM5NPHpRXlf5UFgIBGtXIXU06wVpwXmq9DScwY5UIxDVZhy3+qkPcrmh2";

    /**
     * 平台公钥：
     * 用于商户应用对接收平台的数据进行解密
     * 请用商户自己的公钥！！
     */
    public final static String PLATP_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCAAGF9qLx1lahuBD4sV4LX04uLd4gAWOfTpEtAi4IPFe7r829kGaQpp6BMaT/e6P8PotgiWiaE5U1jUyeAy9hQtXhV+z0f3bwWe5TToLEnjlfuAJoyRSv7RP8C6zAn2DKfmux2qCk2yRAyGt0BG8Msz7VOUKPdVXvMo/wMQoh8zQIDAQAB";

}