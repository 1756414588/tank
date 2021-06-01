package com.account.plat.impl.cmgeAppstore;

import java.security.MessageDigest;
import java.util.Arrays;
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
import com.account.plat.impl.self.util.Base64;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class CmgeAppstorePlat extends PlatBase {

    private static String AppKey;

    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();
    private static Map<Double, Integer> PRICE_MAP = new HashMap<Double, Integer>();
    private static Map<Double, Integer> PACK_PRICE_MAP = new HashMap<Double, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/cmgeAppstore/", "plat.properties");
//		TEXT_URL = properties.getProperty("TEXT_URL");
//		VERIRY_URL = properties.getProperty("VERIRY_URL");
//		ACCOUNT_CHECK = properties.getProperty("ACCOUNT_CHECK");
//		PAY_CHECK = properties.getProperty("PAY_CHECK");
//		AppId = properties.getProperty("AppId");
        AppKey = properties.getProperty("AppKey");
        initRechargeMap();
    }

    private void initRechargeMap() {
        MONEY_MAP.put(1, 6);
        PRICE_MAP.put(0.99, 6);

        MONEY_MAP.put(2, 30);
        PRICE_MAP.put(4.99, 30);

        MONEY_MAP.put(3, 90);
        PRICE_MAP.put(14.99, 90);

        MONEY_MAP.put(4, 190);
        PRICE_MAP.put(29.99, 190);

        MONEY_MAP.put(5, 320);
        PRICE_MAP.put(49.99, 320);

        MONEY_MAP.put(6, 670);

        PRICE_MAP.put(99.99, 670);

        PACK_PRICE_MAP.put(0.99, 1);

        PACK_PRICE_MAP.put(1.99, 2);

        PACK_PRICE_MAP.put(4.99, 3);

        PACK_PRICE_MAP.put(9.99, 4);

        PACK_PRICE_MAP.put(19.99, 5);
    }

    public int getPlatNo() {  // 角色与安卓渠道互通
        return 152;
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
        if (vParam.length < 4) {
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];
        if (!verifyAccount(vParam[0], vParam[1], vParam[2])) {
            return GameError.SDK_LOGIN;
        }

        int childNo = Integer.valueOf(vParam[3]);        // 分包子渠道  ios  50開始

        Account account = accountDao.selectByPlatId(getPlatNo(), uid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(getPlatNo());
            account.setChildNo(childNo);
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

    private boolean verifyAccount(String userid, String timestamp, String sign) {
        LOG.error("cmge_appstore 开始调用sidInfo接口");
        try {
            // 10分钟建议配置
            if ((System.currentTimeMillis() - Long.valueOf(timestamp)) / 60000 > 10) {
                LOG.error("请求超时");
                return false; // 签名超过有效时间，表示登录验签失败
            }
            String needsignstr = userid + "&" + timestamp + "&" + AppKey;
            MessageDigest md5 = MessageDigest.getInstance("MD5");
            byte[] digest = md5.digest(needsignstr.getBytes("utf-8"));
            byte[] encode = Base64.encodeBase64(digest);
            String validSign = new String(encode, "utf-8");
            if (sign.equals(validSign)) {
                LOG.error("验证成功");
                return true; // 表示登录验签成功
            } else {
                LOG.error("验证失败");
                return false; // 表示登录验签失败
            }

        } catch (Exception e) {
            LOG.error("接口返回异常");
            e.printStackTrace();
            return false;
        }
    }

    public static String getSignStr(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat")) {
                continue;
            }

            if (params.get(k) == null) {
                continue;
            }
            v = (String) params.get(k);

            if (str.equals("")) {
                str = k + "=" + v;
            } else {
                str = str + "&" + k + "=" + v;
            }
        }
        return str;
    }


    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay cmge_appstore");
        LOG.error("pay cmge_appstore content:" + content);
        Map<String, String> params = new HashMap<String, String>();
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
            params.put(paramName, request.getParameter(paramName));
        }
        LOG.error("[参数结束]");

        try {

            String openId = request.getParameter("openId");
            String serverId = request.getParameter("serverId");
            String serverName = request.getParameter("serverName");
            String roleId = request.getParameter("roleId");
            String roleName = request.getParameter("roleName");
            String orderId = request.getParameter("orderId");
            String orderStatus = request.getParameter("orderStatus");
            String payType = request.getParameter("payType");
            String payId = request.getParameter("payId");
            String payName = request.getParameter("payName");
            String amount = request.getParameter("amount");
            String currency = request.getParameter("currency");
            String remark = request.getParameter("remark");
            String callBackInfo = request.getParameter("callBackInfo");
            String payTime = request.getParameter("payTime");
            String paySUTime = request.getParameter("paySUTime");
            String sign = request.getParameter("sign");

            String signStr = getSignStr(params) + "&key=" + AppKey;
            LOG.error("代签名字符串:" + signStr);
            String checkSign = MD5.md5Digest(signStr).toLowerCase();

            if (!checkSign.equals(sign)) {
                LOG.error("cmge_appstore 签名验证失败, checkSign:" + checkSign);
                return "fail";
            }

            Double price = Double.valueOf(amount) / 100;
//			if (!PRICE_MAP.containsKey(price)) {
//				LOG.error("cmge_appstore 无效档位, amount:" + amount);
//				return "fail";
//			}

            String[] v = callBackInfo.split("_");
            int rechargeId = Integer.valueOf(v[3]);
            int rechargePackId = Integer.valueOf(v[4]);
            int childNo = Integer.valueOf(v[5]);        // 分包子渠道  ios  50開始

            if (rechargeId > 0 && PRICE_MAP.get(price).intValue() != MONEY_MAP.get(rechargeId).intValue()) {
                LOG.error("cmge_appstore 商品金额不匹配 充值发货失败  ！！ ");
                return "fail";
            }

            if (rechargePackId > 0 && PACK_PRICE_MAP.get(price).intValue() != rechargePackId) {
                LOG.error("cmge_appstore 商品金额不匹配 充值发货失败  ！！ ");
                return "fail";
            }

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = super.getPlatNo();            // 支付还是登记为自己的渠道号
            payInfo.childNo = childNo;
            payInfo.platId = roleId;
            payInfo.orderId = orderId;
            payInfo.serialId = callBackInfo;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = price;
            if (rechargeId > 0)  // 购买金币
                payInfo.amount = MONEY_MAP.get(rechargeId);
            if (rechargePackId > 0)  // 购买礼包
                payInfo.packId = rechargePackId;

            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("cmge_appstore 充值发货失败！！ " + code);
                if (code == 2) {
                    return "fail";
                }
            } else {
                LOG.error("cmge_appstore 充值发货成功！！ " + code);
                return "success";
            }
            return "fail";
        } catch (Exception e) {
            LOG.error("cmge_appstore 充值异常！！:" + e.getMessage());
            e.printStackTrace();
            return "fail";
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }

}
