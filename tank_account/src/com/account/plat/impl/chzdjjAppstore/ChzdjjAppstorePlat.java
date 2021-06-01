package com.account.plat.impl.chzdjjAppstore;

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
public class ChzdjjAppstorePlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL_SANBOX = "";
    private static String VERIRY_URL = "";
    private static String AppID = "";
    private static String AppKey = "";
    private static String SecretKey = "";
    private static String VERIFY_URL = "";

    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chzdjjAppstore/", "plat.properties");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
        VERIRY_URL_SANBOX = properties.getProperty("VERIRY_URL_SANBOX");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        SecretKey = properties.getProperty("SecretKey");
        VERIFY_URL = properties.getProperty("VERIFY_URL");
        initRechargeMap();
    }

    private void initRechargeMap() {
        RECHARGE_MAP.put(1, "com.zdjj.60");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.zdjj.300");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.zdjj.980");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.zdjj.1980");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.zdjj.3280");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.zdjj.6480");
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
        if (vParam.length != 3 && vParam.length != 2) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        // String userName = vParam[1];
        // String token = vParam[2];

        if (vParam.length == 3) {// 3为老SDK
            if (!verifyAccount(vParam)) {
                return GameError.SDK_LOGIN;
            }
        }

        if (vParam.length == 2) { // 2为草花新SDK
            if (!verifyAccount(vParam[0], vParam[1])) {
                return GameError.SDK_LOGIN;
            }
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
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay chzdjj appstore");
        LOG.error("pay chzdjj appstore content:" + content);
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

            String result = HttpUtils.sentPost(VERIRY_URL, body);
            LOG.error("[appstore 返回]" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            int status = rsp.getInt("status");
            if (status != 0) {
                LOG.error("form status error");
                result = HttpUtils.sentPost(VERIRY_URL_SANBOX, body);
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
                LOG.error("chzdjj appstore 充值发货失败！！ " + code);
                return "0|" + (System.currentTimeMillis() / 1000);
            }

            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("chzdjj appstore 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }

    @Override
    public String newPayBack(WebRequest request, String content,
                             HttpServletResponse response, String type) {
        LOG.error("pay chlhtk_appstore");
        LOG.error("pay chlhtk_appstore content:" + content);
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
                LOG.error("chlhtk_appstore 充值发货失败！！ " + code);
                if (code == 2) {
                    return returnCode(203);
                }
            } else {
                LOG.error("chlhtk_appstore 充值发货成功！！ " + code);
            }
            return returnCode(200);
        } catch (Exception e) {
            LOG.error("chlhtk_appstore 充值异常:" + e.getMessage());
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
    // public static void main(String[] args) {
    // LOG.error("1|" + System.currentTimeMillis());
    // }
    // String sourceId = vParam[0];
    // String deviceId = vParam[1];
    // String chDeviceNo = vParam[2];
    // String userId = vParam[3];
    // String userName = vParam[4];
    // String token = vParam[5];

    private boolean verifyAccount(String[] param) {
        LOG.error("chzdjj appstore 开始调用sidInfo接口");
        String signSource = param[0] + param[1];// 组装签名原文
        String sign = MD5.md5Digest(signSource).toLowerCase();
        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        try {
            if (sign.equals(param[2])) {// 成功
                LOG.error("chzdjj appstore 登陆成功");
                return true;
            } else {
                LOG.error("chzdjj appstore 登陆失败");
                return false;
            }
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("chzdjj appstore 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

    }

    private boolean verifyAccount(String userid, String token) {
        LOG.error("chlhtk_appstore 开始调用sidInfo接口");
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
