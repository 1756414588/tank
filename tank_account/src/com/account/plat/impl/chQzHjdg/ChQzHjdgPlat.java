package com.account.plat.impl.chQzHjdg;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.chQzHjdg.sign.Base64;
import com.account.plat.impl.chQzHjdg.sign.SignHelper;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.alibaba.fastjson.JSON;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.*;

/**
 * 桂杰，坦克 草花硬核 新增渠道
 * plat：chQzHjdg_appstore   备注 草花 IOS 仟指 红警帝国（爱贝登录和聚合支付）
 * 帐号要求：该IOS包体与渠道555进行互通
 * 接入的是爱贝的登录和聚合支付
 */
@Component
public class ChQzHjdgPlat extends PlatBase {

    public static String AppID;
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    static {
        MONEY_MAP.put(1, 6);
        MONEY_MAP.put(2, 30);
        MONEY_MAP.put(3, 98);
        MONEY_MAP.put(4, 198);
        MONEY_MAP.put(5, 328);
        MONEY_MAP.put(6, 648);
    }

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzHjdg/", "plat.properties");
        AppID = properties.getProperty("AppID");
        IAppPaySDKConfig.APP_ID = AppID;
    }

    @Override
    public int getPlatNo() {
        return 555;
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();


        //userID__loginName__loginToken
        String[] split = sid.split("__");

        String userName = split[0];
//        String loginToken = split[2];


//        if (!CheckLogin.CheckToken(loginToken)) {
//            return GameError.SDK_LOGIN;
//        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userName);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setChildNo(super.getPlatNo());
            account.setPlatId(userName);
            account.setAccount("0");
            account.setPasswd("0");
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
            return authorityRs;
        }

        response.addAllRecent(super.getRecentServers(account));
        response.setKeyId(account.getKeyId());
        response.setToken(account.getToken());
        response.setUserInfo(userName);


        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String order(WebRequest request, String content) {

        try {
            String waresname = request.getParameter("waresname");
            String cporderid = request.getParameter("cporderid");
            float price = Float.valueOf(request.getParameter("price"));
            String appuserid = request.getParameter("appuserid");
            String cpprivateinfo = request.getParameter("cpprivateinfo");
            String notifyurl = request.getParameter("notifyurl");
            Integer waresid = Integer.valueOf(request.getParameter("waresid"));

            waresid = waresid == null ? 6 : waresid;

            String result = Order.CheckSign(waresname, cporderid, price, appuserid, cpprivateinfo == null ? "" : cpprivateinfo, notifyurl, waresid);

            com.alibaba.fastjson.JSONObject json = new com.alibaba.fastjson.JSONObject();
            if (result == null) {
                json.put("code", 0);
            } else {
                json.put("code", 1);

                JSONObject j = new JSONObject();
                j.put("tid", result);
                j.put("app", AppID);
                j.put("url_r", "");
                j.put("url_h", "");
                String sign = SignHelper.sign(j.toString(), IAppPaySDKConfig.APPV_KEY);// 调用签名函数
                json.put("sign", URLEncoder.encode(sign, "utf-8"));
                json.put("data", URLEncoder.encode(j.toString(), "utf-8"));

//                LOG.error("order aa " + j.toString());
            }
            json.put("transid", result);

//            LOG.error("order bb " + json.toString());
            return json.toJSONString();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chQzHjdg_appstore payBack");
        LOG.error("chQzHjdg_appstore 接收到的参数" + content);


        try {
            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<String, String>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error("chQzHjdg_appstore " + paramName + ":" + request.getParameter(paramName));
                params.put(paramName, request.getParameter(paramName));
            }
            LOG.error("chQzHjdg_appstore 参数结束");


            String transdata = params.get("transdata");

            if (transdata == null) {
                return applePay(params);
            }


            String sign = params.get("sign");

            if (!SignHelper.verify(transdata, sign, IAppPaySDKConfig.PLATP_KEY)) {
                return "RSA error";
            }


            com.alibaba.fastjson.JSONObject json = JSON.parseObject(transdata);


            if (json.getIntValue("result") != 0) {
                return "result error " + json.getIntValue("result");
            }


            String cpOrderId = json.getString("cporderid");
            String[] infos = cpOrderId.split("__");
            if (infos.length < 3) {
                LOG.error("chQzHjdg_appstore 游戏订单错误 " + cpOrderId);
                return "cporderid error";
            }


            Long lordId = Long.valueOf(infos[0]);
            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.childNo = super.getPlatNo();
            payInfo.platId = json.getString("appuserid");
            payInfo.orderId = json.getString("transid");

            payInfo.serialId = cpOrderId;
            payInfo.serverId = Integer.valueOf(infos[1]);
            payInfo.roleId = lordId;
            payInfo.realAmount = json.getDouble("money");
            payInfo.amount = (int) payInfo.realAmount;
            int code = payToGameServer(payInfo);

            if (code == 1) {
                return "SUCCESS";
            }

            if (code != 0) {
                LOG.error("chQzHjdg_appstore 充值发货失败！！ " + code);
                return "system error";
            }

            LOG.error("chQzHjdg_appstore 充值发货成功");
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
            return "system error";
        }
    }


    private String applePay(Map<String, String> par) {
        try {
            String data = par.get("data");
            String extInfo = par.get("extInfo");

            JSONObject params = new JSONObject();
            params.put("receipt-data", data);
            String body = params.toString();
            LOG.error("[请求参数]" + body);

            String result = com.account.plat.impl.self.util.HttpUtils.sentPost("https://buy.itunes.apple.com/verifyReceipt", body);
            LOG.error("[appstore 返回]" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            int status = rsp.getInt("status");
            if (status != 0) {
                LOG.error("form status error");
                result = HttpUtils.sentPost("https://sandbox.itunes.apple.com/verifyReceipt", body);
                JSONObject rsp1 = JSONObject.fromObject(result);
                if (rsp1.getInt("status") != 0) {
                    return "FAILURE";
                }
                rsp = rsp1;
            }

            JSONObject receipt = rsp.getJSONObject("receipt");
            String transaction_id = receipt.getString("transaction_id");

            String[] v = extInfo.split("_");

            int rechargeId = Integer.valueOf(v[6]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = v[1];
            payInfo.orderId = transaction_id;
            payInfo.serialId = v[0] + "_" + v[1] + "_" + v[2];
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);


            int money = MONEY_MAP.get(rechargeId);
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("chjxtk_appstore 充值发货失败！！ " + code);
                return "0|" + (System.currentTimeMillis() / 1000);
            }

            return "SUCCESS";
        } catch (Exception e) {
            LOG.error("chjxtk_appstore 充值异常！！ ");
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }


    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }
}
