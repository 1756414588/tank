package com.account.plat.impl.jrtt;

import com.account.plat.impl.self.util.MD5;

public class Example {

    public static void main(String argv[]) {
        String toutiao_public_key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDOZZ7iAkS3oN970+yDONe5TPhPrLHoNOZOjJjackEtgbptdy4PYGBGdeAUAz75TO7YUGESCM+JbyOz1YzkMfKl2HwYdoePEe8qzfk5CPq6VAhYJjDFA/M+BAZ6gppWTjKnwMcHVK4l2qiepKmsw6bwf/kkLTV9l13r6Iq5U+vrmwIDAQAB";
//		String content = "buyer_id=18253265571&client_id=96f988d461913403&notify_id=ea8fbc6985da2a1a4a3129afa51b83185m&notify_time=2015-07-02 18:13:48&notify_type=trade_status_sync&out_trade_no=20150702-100-688-0000389565&pay_time=2015-07-02 17:49:57&total_fee=100&trade_no=2015070200001000650056705706&trade_status=0&way=2";
        // String sign =
        // "CqE8e8sHOEiU4cAVdiVXVjpWuPBg6l9lwVw2H8tOe9c7s8XZOzh7jlGyfZFdelGiILZSKdzFyWhQWWmbFQAapJ+wwxPw66qjcJghXwcqJuZCADzP+VcJeV57T/y+AzfsAQQvSGHppNWvVEHJ8HG9El7FKZZq0F+qC2Sgi2yTTpY=";
        // boolean verify_result = RSA.verify(content, sign,
        // toutiao_public_key);
        // LOG.error("verify_result: " + verify_result);
        // String toutiao_public_key =
        // "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDOZZ7iAkS3oN970+yDONe5TPhPrLHoNOZOjJjackEtgbptdy4PYGBGdeAUAz75TO7YUGESCM+JbyOz1YzkMfKl2HwYdoePEe8qzfk5CPq6VAhYJjDFA/M+BAZ6gppWTjKnwMcHVK4l2qiepKmsw6bwf/kkLTV9l13r6Iq5U+vrmwIDAQAB";
        String key = MD5.md5Digest("9550e1303faea6eb#cff48ca2b5b3aad84dcd6b35c6f2d116").toLowerCase();
        String content = "buyer_id=15926202951&client_id=9550e1303faea6eb&notify_id=567dd9129fd0efb7772a164cadcbb7egji&notify_time=2016-03-03 14:26:44&notify_type=trade_status_sync&out_trade_no=1_1427954_1456986161144&pay_time=2016-03-03 14:22:56&plat=jrtt&total_fee=1000&trade_no=2016030321001004070201655663&trade_status=0&way=2";
//		content = "&key=" + key;
//		LOG.error(MD5.md5Digest(content));
        String sign = "uIhBNbqDXsx/T4dD+oPoQZQpDNhNU4KnJh+NoY5OVl1WNzZo/jOafS4Ae+XhK6VVUkktbihHEsRInskXtzFT53REKrk2b3D6JyERKnXR6Z2iSGrxjCR6YdA5PZCbxM4lqoA8nrPjTCRt10oI25ShfUW6pRblWg36ZJ/csJou9K0=";
        boolean verify_result = RSA.verify(content, sign, toutiao_public_key);
        //LOG.error("verify_result: " + verify_result);
    }
}
