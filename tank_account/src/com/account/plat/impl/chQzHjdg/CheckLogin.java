package com.account.plat.impl.chQzHjdg;
/**
 * '以下代码只是为了方便商户测试而提供的样例代码，商户可以根据自己的需要，按照技术文档编写,并非一定要使用该代码。
 * '该代码仅供学习和研究爱贝云计费接口使用，只是提供一个参考。
 */

import com.account.plat.impl.chQzHjdg.sign.SignHelper;
import net.sf.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.Map;

public class CheckLogin {


    public static Logger LOG = LoggerFactory.getLogger(CheckLogin.class);


    /*
     * 在客户端调用登陆接口，得到返回 logintoken 客户端把 logintoken 传给 服务端
     * 服务端组装验证令牌的请求参数：transdata={"appid":"123","logintoken":"3213213"}&sign=xxxxxx&signtype=RSA
     * 请求地址：以文档给出的为准
     */

    /**
     * 组装请求参数
     *
     * @param appid      应用编号
     * @param logintoken 从服务端获取的token
     * @return 返回组装好的用于post的请求数据
     * .................
     */
    public static String ReqData(String appid, String logintoken) {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("appid", IAppPaySDKConfig.APP_ID);
        jsonObject.put("logintoken", logintoken);
        String content = jsonObject.toString();// 组装成 json格式数据
        String sign = SignHelper.sign(content, IAppPaySDKConfig.APPV_KEY);// 调用签名函数
        String data = "transdata=" + URLEncoder.encode(content) + "&sign=" + URLEncoder.encode(sign) + "&signtype=RSA";// 组装请求参数
        LOG.error("chQzHjdg_appstore 请求数据：" + data);
        return data;
    }


    // 令牌验证
    public static boolean CheckToken(String logintoken) {
        String reqData = ReqData(IAppPaySDKConfig.APP_ID, logintoken);

        LOG.error("chQzHjdg_appstore 1 响应数据：" + reqData);

        String respData = HttpUtils.sentPost("http://ipay.iapppay.com:9999/openid/openidcheck", reqData, "UTF-8"); // 请求验证服务端
        LOG.error("chQzHjdg_appstore 2 响应数据：" + respData);

        Map<String, String> reslutMap = com.account.plat.impl.chQzHjdg.SignUtils.getParmters(respData);

        String signtype = reslutMap.get("signtype"); // "RSA";

        if (signtype == null) {
            return false;
        }
        String transdata = null;
        try {
            transdata = URLDecoder.decode(reslutMap.get("transdata"), "UTF-8");
        } catch (UnsupportedEncodingException e1) {
            LOG.error("chQzHjdg_appstore verify fail 1" + e1.getMessage());

        }
        String sign = null;
        try {
            sign = URLDecoder.decode(reslutMap.get("sign"), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            LOG.error("chQzHjdg_appstore verify fail 2" + e.getMessage());
        }

        if (SignHelper.verify(transdata, sign, IAppPaySDKConfig.PLATP_KEY)) {
            LOG.error("chQzHjdg_appstore verify ok");
            return true;
        } else {
            LOG.error("chQzHjdg_appstore verify fail");
            return false;
        }
    }


}
