package com.account.plat.impl.test;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.chYhJl.rea.RSASignature;
import com.account.plat.impl.self.util.HttpUtils;

import net.sf.json.JSONObject;

public class TestPlat extends PlatBase {

    /**
     * 下单地址
     */
    private static String order_url;

    /**
     * RSA加密私钥
     */
    private static String private_key;

    /**
     * RSA解密公钥
     */
    private static String public_key;

    private JSONObject getParamsStr(Map<String, String> params) {
        JSONObject json = new JSONObject();
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat")) {
                continue;
            }

            if (params.get(k) == null || params.get(k).equals("")) {
                continue;
            }

            json.put(k, (String) params.get(k));
        }
        return json;
    }

    public static Map<String, String> getParmters(String respData) {
        Map<String, String> map = new HashMap<>();
        String params[] = respData.split("&");

        for (int i = 0; i < respData.length(); i++) {
            String date[] = params[i].split("=");
            map.put(date[0], date[1]);
        }
        return map;
    }

    @Override
    public String order(WebRequest request, String content) {
        Map<String, String> params = new HashMap<String, String>();
        try {
            params.put("appid", request.getParameter("appid"));
            params.put("waresid", request.getParameter("waresid"));
            params.put("waresname", request.getParameter("waresname"));
            params.put("cporderid", request.getParameter("cporderid"));
            params.put("price", request.getParameter("price"));
            params.put("currency", request.getParameter("currency"));
            params.put("appuserid", request.getParameter("appuserid"));
            params.put("cpprivateinfo", request.getParameter("cpprivateinfo"));
            params.put("notifyurl", request.getParameter("notifyurl"));

            String transdata = getParamsStr(params).toString();
            String sign = Rsa.sign(transdata, private_key);
            String paramsSrt = "transdata=" + transdata + "&sign=" + sign + "&signtype=RSA";
            LOG.error("下单请求参数=" + paramsSrt);
            String result = HttpUtils.sentPost(order_url, paramsSrt);
            LOG.error("下单接受到的参数=" + result);

            params.clear();
            params = getParmters(result);
            JSONObject repJson = JSONObject.fromObject(params.get("transdata"));
            if (repJson.has("code")) {
                return "fail";
            }
            if (repJson.has("transid")) {
                return repJson.getString("transid");
            }
        } catch (Exception e) {

        }
        return "fail";
    }


    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {

        return null;
    }

    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        LOG.error("pay chYhSx");
        String transdata = request.getParameter("transdata");
        String sign = request.getParameter("sign");

        try {
            if (!Rsa.doCheck(transdata, sign, public_key)) {
                //   验证失败
                LOG.error("支付RSA验签失败");
                return "fail";
            }
            //  解析 transdata     json 类型
            JSONObject json = JSONObject.fromObject(transdata);
            String transid = json.getString("transid");

            boolean isValid = false;
            isValid = RSASignature.doCheck(transdata, sign, public_key, "UTF-8");
            if (isValid = false) {
                LOG.error("签名不一致");
            }

            String result = json.getString("result");
            String cpprivate = json.getString("cpprivate");
            String money = json.getString("money");
            if (result == null || result.equals("0")) {
                LOG.error("支付结果失败");
                return "SUCCESS";
            }

            String[] infos = cpprivate.split("_");
            if (infos.length != 3) {
                LOG.error("自有参数有问题");
                return "SUCCESS";
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = String.valueOf(lordId);
            payInfo.orderId = transid;
            payInfo.serialId = cpprivate;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) payInfo.realAmount;
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("chYhSx 返回充值成功");
            } else {
                LOG.error("chYhSx 返回充值失败");
            }
            return "SUCCESS";

        } catch (Exception e) {
            // TODO: handle exception
        }
        return "SUCCESS";
    }
}
