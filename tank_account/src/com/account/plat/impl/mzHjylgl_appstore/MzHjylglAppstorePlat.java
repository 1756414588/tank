package com.account.plat.impl.mzHjylgl_appstore;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.muzhi.Rsa;
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
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.*;


@Component
public class MzHjylglAppstorePlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL_SANBOX = "";
    private static String VERIRY_URL = "";

    // 游戏编号
    private static String AppID;

    private static String AppKey;

    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();


    @Override
    public int getPlatNo() {
        return 501;
    }


    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzHjylgl_appstore/", "plat.properties");

        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");

        VERIRY_URL = properties.getProperty("VERIRY_URL");
        VERIRY_URL_SANBOX = properties.getProperty("VERIRY_URL_SANBOX");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "com.banma.tksjdz_6");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.banma.tksjdz_30");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.banma.tksjdz_98");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.banma.tksjdz_198");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.banma.tksjdz_328");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.banma.tksjdz_648");
        MONEY_MAP.put(6, 648);
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
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

        String[] vParam = sid.split("_");
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        String userName = vParam[1];
        String sign = vParam[2];
        String time = vParam[3];
        if (!verifyAccount(userId, userName, sign, time)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setChildNo(super.getPlatNo());
            account.setPlatId(userId);
            account.setAccount(getPlatNo() + "_" + userId);
            account.setPasswd(userId);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);

            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            accountDao.insertWithAccount(account);
            response.setUserInfo("1");
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

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay mzHjylgl_appstore content:" + content);
        boolean flag = false;
        Iterator<String> it = request.getParameterNames();
        while (it.hasNext()) {
            String parameter = it.next();
            if (parameter.equals("sign")) {
                flag = true;
            }
            String v = request.getParameter(parameter);
            LOG.error(parameter + "=" + v);
        }
        try {
            if (flag) {// 拇指充值
                String sign = request.getParameter("sign");
                String body = request.getParameter("content");
                body = new String(Base64.decode(body));
                String mysign = Rsa.getMD5(body + "&key=" + AppKey);
                LOG.error("mzHjylgl_appstore content " + body);
                LOG.error("mzHjylgl_appstore 签名结果 " + mysign + "|" + sign);
                if (!mysign.equals(sign)) {// 签名正确,做业务逻辑处理
                    LOG.error("mzHszzjj_appstore 签名失败");
                    return "fail";
                }
                JSONObject json = JSONObject.fromObject(body);
                String pay_no = json.getString("pay_no");
                String username = json.getString("username");
                String device_id = json.getString("device_id");
                String server_id = json.getString("server_id");
                String game_id = json.getString("game_id");
                String cp_order_id = json.getString("cp_order_id");
                String pay_type = json.getString("pay_type");
                int amount = json.getInt("amount");
                int payStatus = json.getInt("payStatus");
                int user_id = json.getInt("user_id");
                if (payStatus != 0) {
                    LOG.error("mzHjylgl_appstore 充值未完成");
                    return "fail";
                }

                // if (payStatus == 0) {
                // 1.下发游戏币,玩家实际付费以本通知的amount为准，不能使用订单生成的金额。
                // 2.成功与否都返回success，SDK服务器只关心是否有通知到CP服务器
                String[] info = cp_order_id.split("_");
                if (info.length < 3) {
                    LOG.error("mzHjylgl_appstore 自由参数不正确");
                    return "success";
                }

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.childNo = super.getPlatNo();
                payInfo.platId = String.valueOf(user_id);
                payInfo.orderId = pay_no;
                payInfo.serialId = cp_order_id;
                payInfo.serverId = Integer.parseInt(info[0]);
                payInfo.roleId = Long.parseLong(info[1]);

                payInfo.realAmount = Double.valueOf(amount) / 100.0;
                payInfo.amount = (int) (payInfo.realAmount / 1);
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("mzHjylgl_appstore 充值发货失败！！ " + code);
                } else {
                    LOG.error("mzHjylgl_appstore 充值发货成功！！ ");
                }
                return "success";

            } else {// 到苹果方进行票据验证
                content = URLDecoder.decode(content, "UTF-8");
                content = content.substring(content.indexOf("{"), content.lastIndexOf("}") + 1);
                content = content.replace("=", "");

                JSONObject json = JSONObject.fromObject(content);

                JSONObject params = new JSONObject();
                params.put("receipt-data", json.getString("receipt-data"));
                String body = params.toString();
                LOG.error("[请求参数]" + body);

                String result = HttpUtils.sentPost(VERIRY_URL, body);
                LOG.error("mzHjylgl_appstore appstore 返回" + result);
                JSONObject rsp = JSONObject.fromObject(result);
                int status = rsp.getInt("status");
                if (status != 0) {
                    LOG.error("form status error");
                    result = HttpUtils.sentPost(VERIRY_URL_SANBOX, body);
                    JSONObject rsp1 = JSONObject.fromObject(result);
                    LOG.error("[沙箱 返回]" + rsp1.getInt("status"));
                    if (rsp1.getInt("status") != 0) {
                        return "FAILURE";
                    }
                    rsp = rsp1;
                }

                JSONObject receipt = rsp.getJSONObject("receipt");
                // String item_id = receipt.getString("item_id");
                String product_id = receipt.getString("product_id");
                String transaction_id = receipt.getString("transaction_id");

                int rechargeId = json.getInt("rechargeId");
                int serverId = json.getInt("serverId");
                long roleId = json.getInt("playerId");
                String orderId = json.getString("orderId");
                if (json.containsKey("MuZhiOrderId")) {
                    transaction_id = json.getString("MuZhiOrderId");
                }

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = json.getString("userId");
                payInfo.orderId = transaction_id;
                payInfo.serialId = orderId;
                payInfo.serverId = serverId;
                payInfo.roleId = roleId;

                if (!product_id.equals(RECHARGE_MAP.get(rechargeId))) {
                    LOG.error("mzHjylgl_appstore rechargeId abnormal!!!");
                    return "FAILURE";
                }

                int money = MONEY_MAP.get(rechargeId);
                payInfo.realAmount = Double.valueOf(money);
                payInfo.amount = (int) (payInfo.realAmount / 1);
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("mzHjylgl_appstore 充值发货失败！！ " + code);
                    return "0|" + (System.currentTimeMillis() / 1000);
                }

            }

            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("mzHjylgl_appstore 充值异常！！ ");
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }

    private boolean verifyAccount(String userId, String usename, String sign, String time) {
        LOG.error("mzHjylgl_appstore 开始调用sidInfo接口");
        try {
            String signSource = userId + AppKey + time;
            signSource = URLEncoder.encode(signSource, "utf-8");
            String signGenerate = Rsa.getMD5(signSource).toLowerCase();

            LOG.error("mzHjylgl_appstore 签名原文" + signSource);
            LOG.error("mzHjylgl_appstore " + signGenerate);
            LOG.error("mzHjylgl_appstore 签名传入" + sign);

            if (sign.equals(signGenerate)) {
                return true;
            }
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        return false;

    }
}
