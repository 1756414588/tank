package com.account.plat.impl.chgtfcAppstore;

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

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class ChgtfcAppstorePlat extends PlatBase {
    private static String AppID;
    private static String AppKey;
    private static String SecretKey;
    private static String VERIFY_URL;

    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chgtfcAppstore/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        SecretKey = properties.getProperty("SecretKey");
        VERIFY_URL = properties.getProperty("VERIFY_URL");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "com.gtfc.60");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.gtfc.300");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.gtfc.980");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.gtfc.1980");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.gtfc.3280");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.gtfc.6480");
        MONEY_MAP.put(6, 648);
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
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

        String userId = vParam[0];
        // String userName = vParam[1];
        // String token = vParam[2];

        if (!verifyAccount(vParam[0], vParam[1])) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
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
    public String payBack(WebRequest request, String content,
                          HttpServletResponse response) {
        LOG.error("pay chgtfc_appstore");
        LOG.error("pay chgtfc_appstore content:" + content);
        LOG.error("[开始参数]");
        try {
            Map<String, String> params = new HashMap<String, String>();
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("[结束参数]");
            List<String> keys = new ArrayList<String>(params.keySet());
            Collections.sort(keys);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < keys.size(); i++) {
                String k = keys.get(i);
                String v = params.get(k);
                if (!k.equalsIgnoreCase("sign") && !k.equalsIgnoreCase("plat")) {
                    sb.append(k + "=" + v + "&");
                }
            }
            sb.deleteCharAt(sb.length() - 1);
            String signstr = sb.toString();
            signstr = signstr + SecretKey;
            signstr = URLDecoder.decode(signstr, "UTF-8");
            String checkSign = MD5.md5Digest(signstr).toUpperCase();
            String sign = params.get("sign");

            LOG.error("signstr:" + signstr);
            LOG.error("checkSign:" + checkSign);
            LOG.error("sign:" + sign);

            if (!sign.equalsIgnoreCase(checkSign)) {
                LOG.error("签名验证失败");
                return returnCode(202);
            }

            String info = params.get("extra");
            String[] v = info.split("_");

//			int rechargeId = Integer.valueOf(v[3]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = params.get("userid");
            payInfo.orderId = params.get("orderno");

            payInfo.serialId = info;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);

//			int money = MONEY_MAP.get(rechargeId);
            payInfo.realAmount = Double.valueOf(params.get("pay_amt")) / 100.0;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                if (code == 2) {
                    return returnCode(203);
                }
                LOG.error("chgtfc_appstore 充值发货失败！！ " + code);
            } else {
                LOG.error("chgtfc_appstore 充值发货成功！！ " + code);
            }
            return returnCode(200);
        } catch (Exception e) {
            LOG.error("chgtfc_appstore 充值异常:" + e.getMessage());
            e.printStackTrace();
            return returnCode(203);
        }
    }

    private String returnCode(int code) {
        JSONObject json = new JSONObject();
        json.put("code", code);
        switch (code) {
            case 200:
                json.put("msg", "成功");
                json.put("data", "");
                break;
            case 202:
                json.put("msg", "签名校验失败");
                json.put("data", "");
                break;
            case 203:
                json.put("msg", "其他错误");
                json.put("data", "");
                break;
            default:
                break;
        }
        return json.toString();
    }

    private boolean verifyAccount(String userid, String token) {
        LOG.error("chgtfc_appstore 开始调用sidInfo接口");
        try {
            long time = System.currentTimeMillis() / 1000;
            StringBuffer sb = new StringBuffer();
            sb.append("appid=");
            sb.append(AppID);
            sb.append("&times=");
            sb.append(time);
            sb.append("&token=");
            sb.append(token);
            sb.append("&userid=");
            sb.append(userid);
            String signSource = sb.toString() + AppKey;
            String sign = MD5.md5Digest(signSource).toUpperCase();
            sb.append("&sign=");
            sb.append(sign);
            LOG.error("需要发送到服务器的数据为：" + sb.toString());
            String result = HttpUtils.sentPost(VERIFY_URL, sb.toString());
            LOG.error("[响应结果]" + result);

            JSONObject rsp = JSONObject.fromObject(result);
            String code = rsp.getString("code");
            if (!"200".equals(code)) {
                LOG.error("验证失败");
                return false;
            }
            LOG.error("验证成功");
            return true;
        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

    }
}
