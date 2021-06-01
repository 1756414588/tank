package com.account.plat.impl.chQzZzzhg_baidu;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.impl.self.util.Base64;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.HashMap;
import java.util.Properties;

@Component
public class ChQzZzzhgBaiduPlat extends PlatBase {
    private static String ServerUrl = "";
    private static String AppID = "";
    private static String secretkey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzZzzhg_baidu/", "plat.properties");
        ServerUrl = properties.getProperty("ServerUrl");
        AppID = properties.getProperty("AppID");
        secretkey = properties.getProperty("secretkey");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK; // GameError.INVALID_PARAM
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("chQzZzzhg_baidu GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] param = sid.split("_");
        String uid = param[0];
        String accessToken = param[1];

        if (!verifyAccount(accessToken)) {
            LOG.error("GameError.SDK_LOGIN" + GameError.SDK_LOGIN);
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), uid);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setPlatId(uid);
            account.setAccount(getPlatNo() + "_" + uid);
            account.setPasswd(uid);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
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

    private boolean verifyAccount(String token) {
        try {
            //签名
            String sign = MD5Util.toMD5(AppID + token + secretkey);
            StringBuilder param = new StringBuilder();
            param.append("AppID=");
            param.append(AppID);
            param.append("&AccessToken=");
            param.append(token);
            param.append("&Sign=");
            param.append(sign.toLowerCase());

            String url = ServerUrl + param.toString();

            LOG.error("chQzZzzhg_baidu 登录验证http :" + url);


            String result = HttpUtils.sendGet(url, new HashMap<String, String>());

            LOG.error("chQzZzzhg_baidu 登录验证http :" + result);


            JSONObject jo = JSONObject.fromObject(result);

            //ResultCode=1则代表接口返回信息成功
            if (Integer.parseInt(jo.getString("ResultCode")) != 1) {
                return false;
            }

            if (MD5Util.toMD5(AppID + jo.getString("ResultCode") + java.net.URLDecoder.decode(jo.getString("Content"), "utf-8") + secretkey).toLowerCase().equals(jo.getString("Sign").toLowerCase())) {
//                //Content参数需要URLDecoder
//                String content = java.net.URLDecoder.decode(jo.getString("Content"), "utf-8");
//                //Base64解码
//                String jsonStr = Base64.decode(content);
//                out.println("Content内容：" + jsonStr);
//                //json解析
//                JSONObject json = JSONObject.fromObject(jsonStr);
//                //根据获取的信息，执行业务处理
//
//
//                out.println(json.getString("UID"));
                return true;

            }
            return false;

        } catch (Exception e) {
            LOG.error("chQzZzzhg_baidu 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        }

    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        try {
            LOG.error("chQzZzzhg_baidu payBack开始 content:" + content);

            String aid = request.getParameter("AppID");
            String OrderSerial = request.getParameter("OrderSerial");
            String CooperatorOrderSerial = request.getParameter("CooperatorOrderSerial");
            String Sign = request.getParameter("Sign");
            String Content = request.getParameter("Content");

            String toMD5 = MD5Util.toMD5(aid + OrderSerial + CooperatorOrderSerial + Content + secretkey);


            LOG.error("chQzZzzhg_baidu payBack param appId=" + aid);
            LOG.error("chQzZzzhg_baidu payBack param OrderSerial=" + OrderSerial);
            LOG.error("chQzZzzhg_baidu payBack param CooperatorOrderSerial=" + CooperatorOrderSerial);
            LOG.error("chQzZzzhg_baidu payBack param Sign=" + Sign);
            LOG.error("chQzZzzhg_baidu payBack param Content=" + Content);
            LOG.error("chQzZzzhg_baidu payBack param toMD5=" + toMD5);

            if (!AppID.equals(aid)) {
                return getRelust("3", "AppID error");
            }

            if (!toMD5.equals(Sign)) {
                return getRelust("2", "sign error");

            }

            String str = Base64.decode(Content);
            LOG.error("chQzZzzhg_baidu payBack param ContentDecode=" + str);

            com.alibaba.fastjson.JSONObject param = com.alibaba.fastjson.JSONObject.parseObject(str);

            if (!"1".equals(param.getString("OrderStatus"))) {
                return getRelust("5", "OrderStatus error");
            }

            PayInfo payInfo = new PayInfo();
            // 游戏内部渠道号
            payInfo.platNo = getPlatNo();
            // 渠道订单号
            payInfo.orderId = CooperatorOrderSerial;
            // 付费金额
            payInfo.amount = param.getIntValue("OrderMoney");
            payInfo.realAmount = payInfo.amount;

            String[] p = param.getString("ExtInfo").split("_");
            String serverid = p[0];
            String roleid = p[1];

            // 游戏内部订单号
            payInfo.serialId = param.getString("ExtInfo");
            // 渠道id
            payInfo.platId = param.getString("UID");
            // 游戏区号
            payInfo.serverId = Integer.valueOf(serverid);
            // 玩家角色id
            payInfo.roleId = Long.valueOf(roleid);

            int code = payToGameServer(payInfo);
            if (code == 0 || code == 1) {
                LOG.error("chQzZzzhg_baidu payBack 充值发货成功" + code);
                return getRelust("1", "success");
            } else {
                LOG.error("chQzZzzhg_baidu payBack 充值发货失败" + code);
                return getRelust("6", "game error");

            }

        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return getRelust("4", "system error");

        }

    }


    private String getRelust(String ResultCode, String ResultMsg) {
        com.alibaba.fastjson.JSONObject json = new com.alibaba.fastjson.JSONObject();
        json.put("AppID", AppID);
        json.put("ResultCode", ResultCode);
        json.put("ResultMsg", ResultMsg);
        json.put("Content", "");
        String resultSign = MD5Util.toMD5(AppID + ResultCode + secretkey);
        json.put("Sign", resultSign);

        LOG.error("chQzZzzhg_baidu payBack result json " + json.toJSONString());
        return json.toJSONString();
    }
}
