package com.test;

import java.util.*;

public class Test {


//        BasePb.Base msg = PbHelper.createSendToMailRq("", 4, "0", 0, "100400000008", "37", "", "福利补偿", "尊敬的指挥官", "42|204203|88", 0, 0, 0, 0, null);
//        HttpHelper.sendMailMsgToGame("http://192.168.1.40:9202/inner.do", msg);
//
//        PayInfo payInfo = new PayInfo();
//        payInfo.platNo = 1;
//        payInfo.platId = "1";
//        payInfo.orderId = System.currentTimeMillis()+"";
//        payInfo.serialId = System.currentTimeMillis()+"";
//        payInfo.serverId = 40;
//        payInfo.roleId = 100400000001L;
//        payInfo.realAmount = 600;
//        payInfo.amount = (int) (payInfo.realAmount / 100);
//        BasePb.Base payBackRq = PlatBase.createPayBackRq(payInfo);
//        HttpHelper.sendMailMsgToGame("http://192.168.1.40:9202/inner.do", payBackRq);


//        Map<String, String> param = new HashMap<>();
//        param.put("app_id", "1001");
//        param.put("platform_id", "1016");
//        param.put("ext_data", "{\"appid\":125,\"userid\":\"71044284\",\"token\":\"E322+gP8WngJJD8qdDsQht8WgElCJg2aHUoVrcCHBWTDL\\/5Pg7Tc2vIhAG3vQIDJO\\/wZwsVgaZ8da30uEwGXgw1bZv6TvM1ZWWRb5UcYwDY0UcsM+d1lZ0OXiiMmB4PcGVwvEutHH6jx2B0IgQs8vvnuBg0l2XDYrDmcA9AKPIc=\"}");
//
//        String azStr = ParamUtil.getAzStr(param);
//        azStr += "202CB962AC59075B964B07152D234B70";
//
//        String sign = MD5.md5Digest(azStr).toUpperCase();
//
//        LOG.error("chQzZzzhg_caohua verifyAccount 签名原文 " + azStr);
//        LOG.error("chQzZzzhg_caohua verifyAccount 签名结果 " + sign);
//        param.put("sign", sign);
//
////        String result = HttpHelper.doPost("", param);
//
//
//        StringBuffer sb = new StringBuffer();
//        Set<Map.Entry<String, String>> entries = param.entrySet();
//        for (Map.Entry<String, String> e : entries) {
//            sb.append(e.getKey());
//            sb.append("=");
//            sb.append(e.getValue());
//            sb.append("&");
//        }
//
//        String sentPost = HttpUtils.sentPost("https://data-msdk.caohua.com/login/validateAccount", sb.substring(0, sb.length() - 1));
//        LOG.error("chQzZzzhg_caohua verifyAccount 响应结果" + sentPost);// 结果也是一个json格式字符串

//        JSONObject jsonObject = JSONObject.parseObject("{\"username\":\"5579118\",\"userid\":\"5579118\",\"body\":\"6\\u514360\\u91d1\\u5e01[\\u5728\\u7ebf\\u5145\\u503c2019010314505324949]\",\"fee\":\"6.00\",\"subject\":\"\\u91d1\\u5e01\",\"appId\":\"838\",\"trade_sn\":\"2019010314505324949\",\"orderId\":\"106_10101061000001_20190103145048573_7\",\"status\":\"succ\",\"createTime\":\"2019-01-03 14:50:53\",\"servername\":\"M3\",\"extradata\":\"106_10101061000001_20190103145048573_7\",\"sign\":\"4c69e744b29662be59b9b5a2d90c6d8c\"}");
//
//
//        String sentPost = HttpHelper.doPost("http://hwopen.xmwan.com/v2/oauth2/access_token","client_id=178327725707-39321l7njiqn1rpluchd7mkrh527jjbv.apps.googleusercontent.com&client_secret=lsDtRlOancivdw2u3ecBq1fy&grant_type=authorization_code&code=1");


    //String sentPost = HttpHelper.requestRemoteFileData("http://119.29.12.143/serverlist_tank.json", "",5000);

    //LOG.error(sentPost);

    public static void main(String[] args) {

        List<Model> lis = new ArrayList<>();
        lis.add(new Model(12, 2));
        lis.add(new Model(1, 2));
        Collections.sort(lis, new Comparator<Model>() {
            @Override
            public int compare(Model o1, Model o2) {
                if(o1.getA()>o2.getA()){
                    return -1;
                }
                if(o1.getA()<o2.getA()){
                    return 1;
                }
                return 0;
            }
        });

        System.err.println(lis.get(0).toString());


    }


}


class Model {

    private int a;

    private int b;

    public Model(int a, int b) {
        this.a = a;
        this.b = b;
    }

    public int getA() {
        return a;
    }

    public void setA(int a) {
        this.a = a;
    }

    public int getB() {
        return b;
    }

    public void setB(int b) {
        this.b = b;
    }

    @Override
    public String toString() {
        return "Model{" +
                "a=" + a +
                ", b=" + b +
                '}';
    }
}
