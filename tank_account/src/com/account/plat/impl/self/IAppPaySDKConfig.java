package com.account.plat.impl.self;

/**
 * 应用接入iAppPay云支付平台sdk集成信息
 */
public class IAppPaySDKConfig {

    /**
     * 应用名称：
     * 应用在iAppPay云支付平台注册的名称
     */
    public final static String APP_NAME = "国民主公";

    /**
     * 应用编号：
     * 应用在iAppPay云支付平台的编号，此编号用于应用与iAppPay云支付平台的sdk集成
     */
    public final static String APP_ID = "3002458134";

    /**
     * 商品编号：
     * 应用的商品在iAppPay云支付平台的编号，此编号用于iAppPay云支付平台的sdk到iAppPay云支付平台查找商品详细信息（商品名称、商品销售方式、商品价格）
     * 编号对应商品名称为：钻石
     */
    public final static int WARES_ID_1 = 1;

    /**
     * 应用私钥：
     * 用于对商户应用发送到平台的数据进行加密
     */
    public final static String APPV_KEY = "MIICXAIBAAKBgQCDEj2F0WSbYkeYoyg2GWrwH67B3SgOciM9XjyBPGe9oOFIfvqh8Q6DXSMxRERIqZx6Lfsj8WcZnQuMwiHaMmE78E0ckIUM7egk7OiqXfKns66HCTIbzKT/Aj5026ymjIjpo0iXkFUVgnUWE/RJ89wWtyi5Z6J75qRVIuQ9njak9wIDAQABAoGAdNVjhc8asO8wBr0Y8PBDRHvZWPF77TSMeP1xTXm8t2mapvaZDpVDbJEu95F0lJir5LTr8iQS1OAKFZROfKL/zBZFJpBb0fRlPXHOTVkttNHCkTgMseILVN7kQ7Omac/IJ/BckytmXsZxoIyi03/L0VWd707chqJwOlDQRlj4bRECQQDSLgCh0QuTIr6flTw8uCTJfOqovkrUH3laUnkIOx66fABG08lHizt/eXDTVZUJiXMnPv1g/dVaC7oLOk644P97AkEAn6U+s/rWhZs51ecqwE6U+MxKMudyEz0tMhaDzC1hea3NIPGPhb0AkBIl8HRbPmli6xMx5Snu8GkL+T+o090ZtQJADiwB6OdSk3o9Rj9mz2VPPbLJk9U48HKq2RdEh/SMjuB7mEsBgGx395F1tRpJMVpuRFAv/5E+CJNP2R/2XOr27wJAfnwZ1dcjJ+/4PrVMddjMxuJ01yfwhbWunUShX5+E3zcIktVQdRFt5Le8P2qw8B3nNYCbw4kZung/+FarmFBREQJBAMsLgVwCsq6IIM6huqxKKweOTOYHjJYc4KKobLiu0ekfOWYgtk7C27XJN27IhXza+GjVGL2evN8mrQD0DaEoDN0=";

    /**
     * 平台公钥：
     * 用于商户应用对接收平台的数据进行解密
     */
    public final static String PLATP_KEY = "REJCMUUzRkZCQTgxM0ZDMjc0QjA1MzM0RTQzN0Y2MzYyMkU3MkFCRk1UWXlNekl4TmpRd01EYzBNVFF5TlRVeU16TXJNalE1TkRVeU5qTTROell4T1RVek5qQTVORFk0TURjNE1qSTVNVGc0TXpVNE5qVXlOekE1";

}