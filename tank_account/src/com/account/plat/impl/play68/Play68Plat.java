package com.account.plat.impl.play68;

import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class Play68Plat extends PlatBase {

    private static String VERIRY_URL = "";
    private static String VERIRY_PC_URL = "";
    private static String VERIRY_GP_URL = "";
    private static String PAY_SUC_URL = "";
    private static String APP_KEY = "";

    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/play68/", "plat.properties");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
        VERIRY_PC_URL = properties.getProperty("VERIRY_PC_URL");
        VERIRY_GP_URL = properties.getProperty("VERIRY_GP_URL");
        PAY_SUC_URL = properties.getProperty("PAY_SUC_URL");
        APP_KEY = properties.getProperty("APP_KEY");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "tk_gd_30_02");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "tk_gd_150_02");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "tk_gd_300_02");
        MONEY_MAP.put(3, 60);

        RECHARGE_MAP.put(4, "tk_gd_590_02");
        MONEY_MAP.put(4, 118);

        RECHARGE_MAP.put(5, "tk_gd_1490_02");
        MONEY_MAP.put(5, 298);

        RECHARGE_MAP.put(6, "tk_gd_2990_02");
        MONEY_MAP.put(6, 598);

    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];

        if (!verifyAccount(vParam[1])) {
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
        LOG.error("68play 开始调用sidInfo接口");
        try {
            String result = HttpUtils.sentPost(VERIRY_URL, "token=" + token);
            LOG.error("[响应结果]" + result);
            result = new String(Base64.decode(result, Base64.DEFAULT));
            LOG.error("[转换响应结果]" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            String code = rsp.getString("code");
            if (!"1".equals(code)) {
                LOG.error("验证失败");
                return false;
            }
            LOG.error("验证成功");
            return true;
        } catch (Exception e) {
            LOG.error("接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }


    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay 68play");
        LOG.error("pay 68play content:" + content);
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }
        LOG.error("[参数结束]");
        try {
            String type = request.getParameter("type");
            if (type.equals("GP")) { // google
                return gpPayBack(request, content, response);
            } else if (type.equals("PC")) { // paycard
                return pcPayBack(request, content, response);
            }
            return "fail";
        } catch (Exception e) {
            LOG.error("68play 参数异常！！:" + e.getMessage());
            e.printStackTrace();
            return "fail";
        }
    }


    /**
     * google支付
     *
     * @param request
     * @param content
     * @param response
     * @return
     */
    private String gpPayBack(WebRequest request, String content,
                             HttpServletResponse response) {
        try {

            String packID = request.getParameter("packID");
            String sid = request.getParameter("sid");
            String serverID = request.getParameter("serverID");
            String itemID = request.getParameter("itemID");  // Google内购品项资料
            String price = request.getParameter("price");  // Google内购品项金额
            String orderid = request.getParameter("orderid"); // Google订单号

            String payload = request.getParameter("payload");

            // md5($packID.$sid.$serverID.$itemID.$price.$orderid.$packKey)
            String hash = MD5.md5Digest(packID + sid + serverID + itemID + price + orderid + APP_KEY);

            String body = "packID=" + packID + "&sid=" + sid + "&serverID="
                    + serverID + "&itemID=" + itemID + "&price=" + price
                    + "&orderid=" + orderid + "&hash=" + hash;

            LOG.error("[请求原串]" + body);
            String result = HttpUtils.sentPost(VERIRY_GP_URL, body);
            result = new String(Base64.decode(result, Base64.DEFAULT));
            LOG.error("[响应结果]" + result);
            JSONObject rsp = JSONObject.fromObject(result);

            if (!rsp.getString("code").equals("1")) {
                LOG.error("68play 验证失败");
                return "fail";
            }

            String[] v = payload.split("_");
            int rechargeId = Integer.valueOf(v[3]);

            if (!itemID.equals(RECHARGE_MAP.get(rechargeId))) {
                LOG.error("68play 商品id与档位不一致");
                return "fail";
            }

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = sid;
            payInfo.orderId = rsp.getString("orderid");
            payInfo.serialId = payload;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            int money = MONEY_MAP.get(rechargeId);
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("68play 充值发货失败！！ " + code);
                if (code == 2) {
                    return "fail";
                }
            } else {
                LOG.error("68play 充值发货成功！！ " + code);
                paySucCallBack(body);
                return "success";
            }
            return "fail";
        } catch (Exception e) {
            LOG.error("68play 充值异常！！:" + e.getMessage());
            e.printStackTrace();
            return "fail";
        }
    }

    /**
     * google发货成功回传
     *
     * @param packID
     * @param sid
     * @param serverID
     * @param itemID
     * @param price
     * @param orderid
     */
    private void paySucCallBack(String body) {
        LOG.error("68play 充值成功开始回传！！");
        try {
            body = body + "&isValid=1";
            LOG.error("[请求原串]" + body);
            String result = HttpUtils.sentPost(PAY_SUC_URL, body);
            result = new String(Base64.decode(result, Base64.DEFAULT));
            LOG.error("[响应结果]" + result);
            LOG.error("68play 充值成功回传返回！！:" + result);
        } catch (Exception e) {
            LOG.error("68play 充值成功回传异常！！:" + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * payCard 支付
     *
     * @param request
     * @param content
     * @param response
     * @return
     */
    private String pcPayBack(WebRequest request, String content,
                             HttpServletResponse response) {
        try {

            String packID = request.getParameter("packID");
            String sid = request.getParameter("sid");
            String serverID = request.getParameter("serverID");
            String itemID = request.getParameter("itemID");
            String payload = request.getParameter("payload");

            // MD5(packID+sid+serverID+itemID+payload+packKey)
            String hash = MD5.md5Digest(packID + sid + serverID + itemID + payload + APP_KEY);

            String body = "pack=" + packID + "&sid=" + sid + "&serverID="
                    + serverID + "&itemID=" + itemID + "&payload=" + payload
                    + "&hash=" + hash;

            LOG.error("[请求原串]" + body);
            String result = HttpUtils.sentPost(VERIRY_PC_URL, body);
            result = new String(Base64.decode(result, Base64.DEFAULT));
            LOG.error("[响应结果]" + result);
            JSONObject rsp = JSONObject.fromObject(result);

            if (!rsp.getString("code").equals("1")) {
                LOG.error("68play 验证失败");
                return "fail";
            }

            String[] v = payload.split("_");
            int rechargeId = Integer.valueOf(v[3]);

            if (!itemID.equals(RECHARGE_MAP.get(rechargeId))) {
                LOG.error("68play 商品id与档位不一致");
                return "fail";
            }

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = sid;
            payInfo.orderId = rsp.getString("orderID");
            payInfo.serialId = payload;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            int money = MONEY_MAP.get(rechargeId);
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("68play 充值发货失败！！ " + code);
                if (code == 2) {
                    return "fail";
                }
            } else {
                LOG.error("68play 充值发货成功！！ " + code);
                return "success";
            }
            return "fail";
        } catch (Exception e) {
            LOG.error("68play 充值异常！！:" + e.getMessage());
            e.printStackTrace();
            return "fail";
        }
    }

}
