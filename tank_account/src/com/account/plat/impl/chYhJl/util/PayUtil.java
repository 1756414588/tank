package com.account.plat.impl.chYhJl.util;

import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;

import com.account.plat.impl.chYhJl.rea.RSASignature;


import net.sf.json.JSONObject;

public class PayUtil {

    public static String wrapCreateOrder(Order order, String privateKey, String deliverType) throws InvalidKeyException, NoSuchAlgorithmException,
            InvalidKeySpecException, SignatureException, IOException {
        JSONObject jsonReq = new JSONObject();
        String expireTime = order.getExpireTime();
        String notifyURL = order.getNotifyURL();

        StringBuilder signContent = new StringBuilder();
        signContent.append(order.getApiKey());
        jsonReq.put("api_key", order.getApiKey());

        signContent.append(order.getDealPrice());
        jsonReq.put("deal_price", order.getDealPrice().toString());
        signContent.append(deliverType);
        jsonReq.put("deliver_type", deliverType);

        if (expireTime != null) {
            signContent.append(expireTime);
            jsonReq.put("expire_time", expireTime);
        }

        if (notifyURL != null) {
            signContent.append(notifyURL);
            jsonReq.put("notify_url", notifyURL);
        }

        signContent.append(order.getOutOrderNo());
        jsonReq.put("out_order_no", order.getOutOrderNo());
        signContent.append(order.getSubject());
        jsonReq.put("subject", order.getSubject());
        signContent.append(order.getSubmitTime());
        jsonReq.put("submit_time", order.getSubmitTime());
        signContent.append(order.getTotalFee());
        jsonReq.put("total_fee", order.getTotalFee().toString());

        String sign = RSASignature.sign(signContent.toString(), privateKey, "UTF-8");
        jsonReq.put("sign", sign);

        // player_id不参与签名
        jsonReq.put("player_id", order.getPlayerId());

        return jsonReq.toString();
    }
}
