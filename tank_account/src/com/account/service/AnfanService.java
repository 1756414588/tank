package com.account.service;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.context.request.WebRequest;

import com.account.handle.PlatHandle;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.MD5;

public class AnfanService {
    public static Logger LOG = LoggerFactory.getLogger(AnfanService.class);

    /**
     * 签名秘钥
     */
    private final static String SIGN_KEY = "rlPv9cEFgXdoLgO6hMJfS6neJdYUPJ3jub0TjTEOgHYdDKYv";

    @Autowired
    private PlatHandle platHandle;

    public String yBPayBack(WebRequest request, String content, HttpServletResponse response, int platNo) {
        try {
            LOG.error("pay anfanYB");
            String amount = request.getParameter("amount");
            String charid = request.getParameter("charid");
            String cporderid = request.getParameter("cporderid");
            String orderid = request.getParameter("orderid");
            String serverid = request.getParameter("serverid");
            String uid = request.getParameter("uid");
            String sign = request.getParameter("sign");
            String signstr = "amount=" + amount + "&charid=" + charid + "&cporderid=" + cporderid
                    + "&orderid=" + orderid + "&serverid=" + serverid
                    + "&uid=" + uid;
            LOG.error("待签名字符串：" + signstr);
            signstr = signstr + SIGN_KEY;
            signstr = URLDecoder.decode(signstr, "UTF-8");
            String checkSign = MD5.md5Digest(signstr);
            LOG.error("签名" + signstr);
            if (!sign.equalsIgnoreCase(checkSign)) {
                LOG.error("签名验证失败");
                return "ERROR";
            }
            PlatBase plat = platHandle.getPlatInst(request.getParameter("plat"));
            PayInfo payInfo = new PayInfo();
            payInfo.platNo = platNo;
            payInfo.platId = charid;
            payInfo.orderId = orderid;
            payInfo.serialId = cporderid;

            // serverId_roleId_timeStamp
            String[] v = payInfo.serialId.split("_");
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = plat.payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("anfanYB 充值发货失败！！ " + code);
            }
            return "SUCCESS";
        } catch (Exception e) {
            LOG.error("anfanYB 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "ERROR";
        }
    }

    public static void main(String[] args) {
        String signstr = "amount=" + 10 + "&appid=" + 1 + "&charid=" + 10 + "&cporderid=" + "1_654321_123456"
                + "&extinfo=" + 654321 + "&gold=" + 100 + "&orderid=" + 789987 + "&serverid=" + 1 + "&time=" + 1000000
                + "&uid=" + 77777;
        LOG.error("待签名字符串：" + signstr);
        signstr = signstr + SIGN_KEY;
        try {
            signstr = URLDecoder.decode(signstr, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        String checkSign = MD5.md5Digest(signstr);
        LOG.error(checkSign);
    }
}
