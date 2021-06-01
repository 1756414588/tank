package com.account.plat.impl.chSqWx;

import java.util.Iterator;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.MD5;

@Component
public class ChSqWxPlat extends PlatBase {

    private static String APP_ID = "";
    private static String APP_KEY = "";
    private static String SERVER_KEY = "";

    private static final int chSq = 85;  // 草花手Q
    private static final int chWx = 86;  // 草花微信

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chSqWx/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        SERVER_KEY = properties.getProperty("SERVER_KEY");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        LOG.error("pay chsqwx");
        LOG.error("[接收到的参数]" + content);
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }

            String OrderNo = request.getParameter("OrderNo");
            String OutPayNo = request.getParameter("OutPayNo");
            String UserID = request.getParameter("UserID");
            String ServerNo = request.getParameter("ServerNo");
            String PayType = request.getParameter("PayType");
            String Money = request.getParameter("Money");
            String PMoney = request.getParameter("PMoney");
            String PayTime = request.getParameter("PayTime");
            String Sign = request.getParameter("Sign");

            //MD5(OrderNo+OutPayNo+UserID+ServerNo+PayType+Money+PMoney+ PayTime+ServerKey)

            String signSource = OrderNo + OutPayNo + UserID + ServerNo + PayType + Money + PMoney + PayTime + SERVER_KEY;// 组装签名原文
            String sign = MD5.md5Digest(signSource).toUpperCase();
            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + sign);

            if (!sign.equals(Sign)) {
                LOG.error("chsqwx sign error");
                return "0";
            }

            String[] v = OutPayNo.split("_");

            int platNo = getPlatNo();  // 该渠道实际作用于支付    渠道号为  chSq 或是   chWx
            if (v[3].equals("chSq")) {
                platNo = chSq;
            } else if (v[3].equals("chWx")) {
                platNo = chWx;
            }

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = platNo;
            payInfo.platId = UserID;
            payInfo.orderId = OrderNo;

            payInfo.serialId = OutPayNo;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(Money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("chsqwx 充值发货失败！！ " + code);
                return "0";
            }
            return "1";
        } catch (Exception e) {
            LOG.error("chsqwx 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "1";
        }
    }

}
