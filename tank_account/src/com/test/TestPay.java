package com.test;

import com.account.plat.impl.kaopu.MD5Util;
import com.account.util.AESUtil;
import com.account.util.Http;
import com.account.util.HttpHelper;
import com.alibaba.fastjson.JSONObject;

import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

/**
 * @author ChenKui
 * @version 创建时间：2015-11-17 上午9:34:30
 * @declare
 */

public class TestPay {

    public static void main(String[] args) throws Exception {

            JSONObject j = new JSONObject();

            JSONObject p = new JSONObject();
            p.put("user_id", 9378729);
            p.put("os_type", "all");

            String decrypt = AESUtil.encrypt(p.toString(), "drOl6tD44k0lc9OE", "drOl6tD44k0lc9OE");
            decrypt = decrypt.replace("\r\n", "");

            String signStr = "data=" + decrypt + "actkey=" + "stE7PRxhOy";
            String md5 = MD5Util.toMD5(signStr);
            decrypt = URLEncoder.encode(decrypt, "utf-8");
            j.put("data", decrypt);
            j.put("sign", md5);
            long t = System.currentTimeMillis();
           // LOG.error(HttpHelper.doPost("http://tankgm.hundredcent.com:8090/tank_account_role/account/queryMuzhiRoleInfos.do", j.toString()));
            //LOG.error((System.currentTimeMillis() -t)/1000.0f);

//        Map<String,String> paramMap = new HashMap<>();
//
//        paramMap.put("orderid","20_k90lnvmg2_1cuj8kg2500");
//        paramMap.put("gameaccount","12345");
//        paramMap.put("macaddress","678");
//        paramMap.put("imei","1122");
//        paramMap.put("channelid","1123");
//        paramMap.put("serviceid","9988");
//        paramMap.put("cpid","0000");
//
//        String doPostssxxx= Http.post("http://192.168.1.40/tank_account/account/order.do?plat=mzUnicom", paramMap);
//        LOG.error(doPostssxxx);
//
//        String toMD5 = MD5Util.toMD5("orderid= 20_k90lnvmg2_1cuj8kg2500&Key=181316956052cb2055d6");
//        toMD5 ="3062656435396262656238663064643133386236313230623166623531376332";
//        String str ="<?xml version=\"1.0\" encoding=\"UTF-8\"?><checkOrderIdReq><orderid>20_k90lnvmg2_1cuj8kg2500</orderid><signMsg>"+toMD5+"</signMsg><usercode>15600000000</usercode><provinceid>00001</provinceid><cityid>00001</cityid></checkOrderIdReq>";
//        String doPostss = HttpHelper.doPost("http://192.168.1.40/tank_account/account/mzUnicomPayCallbackMzUnicom.do?serviceid=validateorderid", str);
//        LOG.error(doPostss);
//
//
//        String param = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><callbackReq><orderid>20_k90lnvmg2_1cuj8kg2500</orderid><ordertime>20181213154918</ordertime><cpid>86011503</cpid><appid>9021122219520181205173514717800</appid><fid>00012243</fid><consumeCode>9021122219520181205173514717800001</consumeCode><payfee>1000</payfee><payType>6</payType><hRet>0</hRet><status>00000</status><signMsg>14ec1354144fa80a3825591a777de5fe</signMsg></callbackReq>";
//
//        String doPost = HttpHelper.doPost("http://192.168.1.40/tank_account/account/mzUnicomPayCallbackMzUnicom.do", param);
//        LOG.error(doPost);


//        Document document = StringXmlUtil.stringToXml("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
//                "<callbackReq><orderid>XXX</orderid><ordertime>XXX</ordertime><cpid>XXX</cpid><appid>XXX</appid><fid>XXX</fid><consumeCode>XXX</consumeCode><payfee>XXX</payfee><payType>5566</payType><hRet>XXX</hRet><status>XXX</status><signMsg>XXX</signMsg></callbackReq>");
//        String payType = StringXmlUtil.getNodeValue(document, "/callbackReq/payType");
//        LOG.error("pay mzUnicom xml解析后对应参数 payType :" + payType);



//        LOG.error(Long.toHexString(1544288575658l));
//        LOG.error(Long.toHexString(8007470007374l));
//        LOG.error();
//        LOG.error(Long.valueOf("791h6fh2e",32));
//        LOG.error(("1_"+Long.toString(8907470007374L,32)+"_"+Long.toString(1544288575658l,32)));
//


    }

}
