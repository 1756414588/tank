package com.account.plat.impl.mzXmlyAppstore;

import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.plat.impl.self.util.HttpUtils;
import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

import net.sf.json.JSONObject;

@Component
public class MzXmlyAppstorePlat extends PlatBase {

    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();
    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    //	private static String TEXT_URL;
    private static String VERIRY_URL;
    //	private static String ACCOUNT_CHECK;
//	private static String PAY_CHECK;
//	private static String AppKey;
//	private static String AppId;
    private static String PAY_VERIRY_URL;
    private static String PAY_VERIRY_URL_SANBOX;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzXmlyAppstore/", "plat.properties");
//		TEXT_URL = properties.getProperty("TEXT_URL");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
//		ACCOUNT_CHECK = properties.getProperty("ACCOUNT_CHECK");
//		PAY_CHECK = properties.getProperty("PAY_CHECK");
//		AppId = properties.getProperty("AppId");
//		AppKey = properties.getProperty("AppKey");
        PAY_VERIRY_URL = properties.getProperty("PAY_VERIRY_URL");
        PAY_VERIRY_URL_SANBOX = properties.getProperty("PAY_VERIRY_URL_SANBOX");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "com.muzhiyouwan.tkjjdgjq60");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.muzhiyouwan.tkjjdgjq300");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.muzhiyouwan.tkjjdgjq980");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.muzhiyouwan.tkjjdgjq1980");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.muzhiyouwan.tkjjdgjq3280");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.muzhiyouwan.tkjjdgjq6480");
        MONEY_MAP.put(6, 648);
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

        String uid = verifyAccount(vParam[0], vParam[1]);
        if (uid == null) {
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

    private String verifyAccount(String uid, String session) {
        LOG.error("mzXmly_appstore 开始调用sidInfo接口");
        String result = HttpUtils.sendGet(VERIRY_URL + "uid=" + uid + "&session=" + session, new HashMap<String, String>());
        LOG.error("[响应结果]" + result);
        try {
            if (result != null) {
                JSONObject rsp = JSONObject.fromObject(result);
                int status = rsp.getInt("状态");
                if (status == 1) {
                    return rsp.getInt("会员编号") + "";
                }
            }
            return null;
        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay mzXmly_appstore");
        LOG.error("pay mzXmly_appstore content:" + content);
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }

        try {
            String data = request.getParameter("data");
            String extInfo = request.getParameter("extInfo");
            // String orderId = request.getParameter("orderId");

            JSONObject params = new JSONObject();
            params.put("receipt-data", data);
            String body = params.toString();
            LOG.error("[请求参数]" + body);

            String result = HttpUtils.sentPost(PAY_VERIRY_URL, body);
            LOG.error("[mzXmly_appstore 返回]" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            int status = rsp.getInt("status");
            if (status != 0) {
                LOG.error("form status error");
                result = HttpUtils.sentPost(PAY_VERIRY_URL_SANBOX, body);
                JSONObject rsp1 = JSONObject.fromObject(result);
                if (rsp1.getInt("status") != 0) {
                    return "FAILURE";
                }
                rsp = rsp1;
            }

            JSONObject receipt = rsp.getJSONObject("receipt");
            // String item_id = receipt.getString("item_id");
            String product_id = receipt.getString("product_id");
            String transaction_id = receipt.getString("transaction_id");

            // serverId_roleId_timeStamp_platId_rechargeId
            String[] v = extInfo.split("_");

            int rechargeId = Integer.valueOf(v[4]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = v[3];
            payInfo.orderId = transaction_id;
            payInfo.serialId = v[0] + "_" + v[1] + "_" + v[2];
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

            if (!product_id.equals(RECHARGE_MAP.get(rechargeId))) {
                LOG.error("rechargeId abnormal!!!");
                return "FAILURE";
            }

            int money = MONEY_MAP.get(rechargeId);
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("mzXmly_appstore 充值发货失败！！ " + code);
                return "0|" + (System.currentTimeMillis() / 1000);
            }

            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("mzXmly_appstore 充值异常！！ ");
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }
}
