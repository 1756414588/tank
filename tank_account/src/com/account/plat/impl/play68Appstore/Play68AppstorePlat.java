package com.account.plat.impl.play68Appstore;

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
public class Play68AppstorePlat extends PlatBase {

    private static String VERIRY_URL = "";
    private static String VERIRY_PAY_URL = "";
    private static String APP_KEY = "";

    private static Map<Integer, Integer> RECHARGE_MAP = new HashMap<Integer, Integer>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/play68Appstore/", "plat.properties");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
        VERIRY_PAY_URL = properties.getProperty("VERIRY_PAY_URL");
        APP_KEY = properties.getProperty("APP_KEY");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, 30);
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, 150);
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, 300);
        MONEY_MAP.put(3, 60);

        RECHARGE_MAP.put(4, 590);
        MONEY_MAP.put(4, 118);

        RECHARGE_MAP.put(5, 1490);
        MONEY_MAP.put(5, 298);

        RECHARGE_MAP.put(6, 2990);
        MONEY_MAP.put(6, 598);

    }

    public int getPlatNo() {  // //  账号与151互通
        return 151;
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
            account.setPlatNo(getPlatNo());
            account.setChildNo(super.getPlatNo());
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
        LOG.error("68play_appstore 开始调用sidInfo接口");
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
        return null;
    }

    /**
     * payCard 支付
     *
     * @param request
     * @param content
     * @param response
     * @return
     */
    @Override
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay 68play_appstore");
        LOG.error("pay 68play_appstore content:" + content);
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }
        LOG.error("[参数结束]");
        try {

            String pack = request.getParameter("pack");
            String sid = request.getParameter("sid");
            String orderId = request.getParameter("orderId");
            String price = request.getParameter("price");
            String payload = request.getParameter("payload");

            String hash = request.getParameter("hash");

            // hash=md5(pack+sid+orderId+price+packKey)
            String hashStr = pack + sid + orderId + price + payload + APP_KEY;
            LOG.error("[签名原串]" + hashStr);
            String hashCheck = MD5.md5Digest(hashStr);
            LOG.error("[签名结果]" + hashCheck);

            if (!hash.equals(hashCheck)) {
                LOG.error("68play_appstore 验证失败");
                return "fail";
            }

            String[] v = payload.split("_");
            int rechargeId = Integer.valueOf(v[3]);

            if (RECHARGE_MAP.get(rechargeId).intValue() != Integer.valueOf(price).intValue()) {
                LOG.error("68play_appstore 商品金额与档位不一致");
                return "fail";
            }

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.childNo = super.getPlatNo();
            payInfo.platId = sid;
            payInfo.orderId = orderId;
            payInfo.serialId = payload;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            int money = MONEY_MAP.get(rechargeId);
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("68play_appstore 充值发货失败！！ " + code);
                if (code == 2) {
                    return "fail";
                }
            } else {
                LOG.error("68play_appstore 充值发货成功！！ " + code);
                return "success";
            }
            return "fail";
        } catch (Exception e) {
            LOG.error("68play_appstore 充值异常！！:" + e.getMessage());
            e.printStackTrace();
            return "fail";
        }
    }

}
