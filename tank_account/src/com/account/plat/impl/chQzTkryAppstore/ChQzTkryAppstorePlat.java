package com.account.plat.impl.chQzTkryAppstore;

import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.MD5;
import com.account.util.Http;
import com.account.util.HttpHelper;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

import net.sf.json.JSONObject;

@Component
public class ChQzTkryAppstorePlat extends PlatBase {

    private static String AppID;

    private static String AppKey;

    private static String url;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzTkryAppstore/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        url = properties.getProperty("URL");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("_");
        String uin = vParam[0];
        String accessToken = vParam[1];

        if (!verifyAccount(accessToken)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), uin);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setPlatId(uin);
            account.setAccount(getPlatNo() + "_" + uin);
            account.setPasswd(uin);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            account.setChildNo(super.getPlatNo());
            accountDao.insertWithAccount(account);

        } else {
            String token = RandomHelper.generateToken();
            account.setToken(token);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setDeviceNo(deviceNo);
            account.setLoginDate(new Date());
            accountDao.updateTokenAndVersion(account);
        }

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            LOG.error("authorityRs" + authorityRs);
            return authorityRs;
        }

        response.addAllRecent(super.getRecentServers(account));
        response.setKeyId(account.getKeyId());
        response.setToken(account.getToken());

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);

        }
        return GameError.OK;
    }

    private boolean verifyAccount(String accessToken) {
        try {
            String str = AppID + "&" + AppKey;
            LOG.error("chQztkry_appstore str " + str);

            String md5Str = MD5.md5Digest(str);
            String param = "appId=" + AppID + "&accessToken=" + accessToken + "&secret=" + md5Str;
            LOG.error("chQzZjldz_appstore param " + param);
            com.alibaba.fastjson.JSONObject obj = new com.alibaba.fastjson.JSONObject();
            obj.put("appId", AppID);
            obj.put("accessToken", accessToken);
            obj.put("secret", md5Str);
            String post = HttpHelper.doPost(url, obj.toJSONString());
            LOG.error("chQzZjldz_appstore post " + post);

            if (post == null) {
                return false;
            }

            JSONObject jsonObject = JSONObject.fromObject(post);

            if (jsonObject.containsKey("result") && jsonObject.getLong("result") == 0) {
                return true;
            }
        } catch (Exception e) {
            LOG.error("chqztkry_appstore 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        }
        return false;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {

        LOG.error("chQzTkry_appstore payBack 开始 " + content);


        if (content != null) {
            if (isJson(content)) {
                return payBackJson(request, content, response);
            }
        }

        try {
            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<String, String>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error("chQzTkry_appstore " + paramName + ":" + request.getParameter(paramName));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            if (!"1".equals(request.getParameter("payStatus"))) {
                return "FAILURE1";
            }

            List<String> list = new ArrayList<>();
            list.add("userId");
            list.add("goodsId");
            list.add("goodsName");
            list.add("payOrderId");
            list.add("payPrice");
            list.add("payStatus");
            if ("1".equals(request.getParameter("applePay"))) {
                list.add("applePay");
            }
            Collections.sort(list);

            StringBuilder sb = new StringBuilder();
            for (String str : list) {
                sb.append(str);
                sb.append("=");
                sb.append(params.get(str));
                sb.append("&");
            }
            sb.append("appKey=" + AppKey);

            // 调用MD5进行签名
            String checkSign = MD5.md5Digest(sb.toString());

            String sign = URLDecoder.decode(request.getParameter("sign"), "UTF-8");

            LOG.error("chQzTkry_appstore payBack signstr:" + sb.toString());
            LOG.error("chQzTkry_appstore payBack sign:" + sign);
            if (!sign.equalsIgnoreCase(checkSign)) {
                LOG.error("chQzTkry_appstore payBack sign:md5验证失败");
                return "FAILURE2";
            }

            PayInfo payInfo = new PayInfo();
            // 游戏内部渠道号
            payInfo.platNo = getPlatNo();
            payInfo.childNo = super.getPlatNo();
            // 渠道订单号
            payInfo.orderId = params.get("payOrderId");
            // 付费金额
            payInfo.amount = Float.valueOf(params.get("payPrice")).intValue() / 100;

            String[] param = params.get("goodsId").split("_");
            String serverid = param[0];
            String roleid = param[1];

            // 游戏内部订单号
            payInfo.serialId = params.get("goodsId");
            // 渠道id
            payInfo.platId = getPlatNo() + "";
            // 游戏区号
            payInfo.serverId = Integer.valueOf(serverid);
            // 玩家角色id
            payInfo.roleId = Long.valueOf(roleid);

            int code = payToGameServer(payInfo);

            if (code == 0 || code == 1) {
                LOG.error("chQzTkry_appstore 充值发货成功！！ " + code);
                return "0";
            }
            LOG.error("chQzTkry_appstore 充值发货失败！！ " + code);
            return "FAILURE3";

        } catch (Exception e) {
            LOG.error("chQzTkry_appstore 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "FAILURE4";
        }
    }


    /**
     * 特殊的充值回调
     *
     * @param request
     * @param content
     * @param response
     * @return
     */
    public String payBackJson(WebRequest request, String content, HttpServletResponse response) {

        // {"amount":"600","orderId":"1527577454128","extra":"20_56300200000001_20180529150412","status":"1"}

        com.alibaba.fastjson.JSONObject result = new com.alibaba.fastjson.JSONObject();


        com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(content);

        try {
            if (jsonObject.getIntValue("status") != 1) {

                result.put("success", "false");
                result.put("msg", "失败订单");

                return result.toJSONString();
            }

            PayInfo payInfo = new PayInfo();
            // 游戏内部渠道号
            payInfo.platNo = getPlatNo();
            // 渠道订单号
            payInfo.orderId = jsonObject.getString("orderId");
            // 付费金额
            payInfo.amount = Float.valueOf(jsonObject.getString("amount")).intValue() / 100;

            String[] param = jsonObject.getString("extra").split("_");
            String serverid = param[0];
            String roleid = param[1];

            // 游戏内部订单号
            payInfo.serialId = jsonObject.getString("extra");
            // 渠道id
            payInfo.platId = getPlatNo() + "";
            // 游戏区号
            payInfo.serverId = Integer.valueOf(serverid);
            // 玩家角色id
            payInfo.roleId = Long.valueOf(roleid);

            int code = payToGameServer(payInfo);

            if (code == 0 || code == 1) {
                LOG.error("chQzTkry_appstore 充值发货成功！！ " + code);
                result.put("success", "true");
                return result.toJSONString();
            }
            LOG.error("chQzTkry_appstore 充值发货失败！！ " + code);
            result.put("success", "false");
            result.put("msg", "充值失败");
            return result.toJSONString();
        } catch (NumberFormatException e) {
            e.printStackTrace();

            result.put("success", "false");
            result.put("msg", "系统内部错误");
            return result.toJSONString();
        }

    }

    private boolean isJson(String str) {

        if (str == null || str.trim().length() == 0) {
            return false;
        }

        try {
            com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(str);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

}
