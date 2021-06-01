package com.account.plat.impl.chQzHjdg;

import com.account.plat.impl.chQzHjdg.sign.SignHelper;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

public class Order {
    public static Logger LOG = LoggerFactory.getLogger(Order.class);

    /**
     * 组装请求参数
     *
     * @param appid         应用编号
     * @param waresid       商品编号
     * @param price         商品价格
     * @param waresname     商品名称
     * @param cporderid     商户订单号
     * @param appuserid     用户编号
     * @param cpprivateinfo 商户私有信息
     * @param notifyurl     支付结果通知地址
     * @return 返回组装好的用于post的请求数据
     * .................
     */

    public static String ReqData(String appid, int waresid, String waresname, String cporderid, float price, String appuserid, String cpprivateinfo, String notifyurl) {

        String json;
        json = "appid:";
        json += IAppPaySDKConfig.APP_ID;
        json += " userid:";
        json += appuserid;
        json += " waresid:";
        json += waresid;
        json += "cporderid:";
        json += cporderid;
        LOG.error("chQzHjdg_appstore json=" + json);

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("appid", IAppPaySDKConfig.APP_ID);
        jsonObject.put("waresid", waresid);
        jsonObject.put("cporderid", cporderid);
        jsonObject.put("currency", "RMB");
        jsonObject.put("appuserid", appuserid);
        //以下是参数列表中的可选参数
        if (!waresname.isEmpty()) {
            jsonObject.put("waresname", waresname);
        }
        /*
         * 当使用的是 开放价格策略的时候 price的值是 程序自己 设定的价格，使用其他的计费策略的时候
         * price 不用传值
         * */
        jsonObject.put("price", price);
        if (!cpprivateinfo.isEmpty()) {
            jsonObject.put("cpprivateinfo", cpprivateinfo);
        }
        if (!notifyurl.isEmpty()) {
            /*
             * 如果此处不传同步地址，则是以后台传的为准。
             * */
            jsonObject.put("notifyurl", notifyurl);
        }
        String content = jsonObject.toString();// 组装成 json格式数据

        String sign = SignHelper.sign(content, IAppPaySDKConfig.APPV_KEY);
        String data = "transdata=" + content + "&sign=" + sign + "&signtype=RSA";// 组装请求参数
        LOG.error("chQzHjdg_appstore 请求数据:" + data);
        return data;
    }

    // 数据验签
    public static String CheckSign(String waresname, String cporderid, float price, String appuserid, String cpprivateinfo, String notifyurl, int waresid) {
        String reqData = ReqData(IAppPaySDKConfig.APP_ID, waresid, waresname, cporderid, price, appuserid, cpprivateinfo, notifyurl);

        LOG.error("chQzHjdg_appstore CheckSign" + reqData);

        String respData = HttpUtils.sentPost("http://ipay.iapppay.com:9999/payapi/order", reqData, "UTF-8"); // 请求验证服务端
        LOG.error("chQzHjdg_appstore CheckSign 响应数据：" + respData);

        Map<String, String> reslutMap = SignUtils.getParmters(respData);

        if (SignHelper.verify(reslutMap.get("transdata"), reslutMap.get("sign"), IAppPaySDKConfig.PLATP_KEY)) {
            LOG.error(reslutMap.get("transdata"));
            LOG.error(reslutMap.get("sign"));
            JSONObject json = JSON.parseObject(reslutMap.get("transdata"));

            LOG.error("chQzHjdg_appstore verify ok");
            return json.getString("transid");
        } else {
            LOG.error("chQzHjdg_appstore verify fail");
            return null;
        }
    }

    //	可以右键运行查看效果
    public static void main(String[] argv) {
//        CheckSign("aaa", "12312223", 0.1f, "108412312312310", "1231231231", "http://58.250.160.241:8888/IapppayCpSyncForPHPDemo/TradingResultsNotice.php");
    }


}
