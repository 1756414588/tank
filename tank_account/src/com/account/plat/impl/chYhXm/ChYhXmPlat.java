package com.account.plat.impl.chYhXm;

import java.net.URLDecoder;
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
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

class MiAccount {
    public String uid;
}

@Component
public class ChYhXmPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String AppID;

    // private static String AppKey;

    private static String AppSecret;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYhXm/", "plat.properties");
        // if (properties != null) {
        AppID = properties.getProperty("AppID");
        // AppKey = properties.getProperty("AppKey");
        AppSecret = properties.getProperty("AppSecret");
        serverUrl = properties.getProperty("VERIRY_URL");
        // }
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
        String session = vParam[1];

        MiAccount miAccount = verifyAccount(session, uid);
        if (miAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), miAccount.uid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(miAccount.uid);
            account.setAccount(getPlatNo() + "_" + miAccount.uid);
            account.setPasswd(miAccount.uid);
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

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        if (!param.containsKey("sid") || !param.containsKey("baseVersion") || !param.containsKey("version") || !param.containsKey("deviceNo")) {
            return GameError.PARAM_ERROR;
        }

        String sid = param.getString("sid");
        String baseVersion = param.getString("baseVersion");
        String versionNo = param.getString("version");
        String deviceNo = param.getString("deviceNo");

        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];
        String session = vParam[1];

        // if (!verifyAccount(accessToken)) {
        // return GameError.SDK_LOGIN;
        // }

        MiAccount miAccount = verifyAccount(session, uid);
        if (miAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), miAccount.uid);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(miAccount.uid);
            account.setAccount(getPlatNo() + "_" + miAccount.uid);
            account.setPasswd(miAccount.uid);
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
            account.setVersionNo(versionNo);
            account.setDeviceNo(deviceNo);
            account.setLoginDate(new Date());
            accountDao.updateTokenAndVersion(account);
        }

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            return authorityRs;
        }

        response.put("recent", super.getRecentServers(account));
        response.put("keyId", account.getKeyId());
        response.put("token", account.getToken());

        if (isActive(account)) {
            response.put("active", 1);
        } else {
            response.put("active", 0);
        }

        return GameError.OK;
    }

    public static String getSign(HashMap<String, String> params, String appSecret) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        boolean hadFirst = false;
        try {
            for (int i = 0; i < keys.length; i++) {
                k = (String) keys[i];
                if (k.equals("signature") || k.equals("plat")) {
                    continue;
                }
                if (params.get(k) == null) {
                    continue;
                }
                v = (String) params.get(k);

                if (v.equals("")) {
                    continue;
                }

                if (hadFirst)
                    str += "&" + keys[i] + "=" + URLDecoder.decode(v, "UTF-8");
                else {
                    str += keys[i] + "=" + URLDecoder.decode(v, "UTF-8");
                    hadFirst = true;
                }
            }

            return HmacSHA1Encryption.HmacSHA1Encrypt(str, appSecret);
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    private JSONObject packResponse(int ResultCode) {
        JSONObject res = new JSONObject();
        res.put("errcode", ResultCode);
        return res;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chYhXm");
        LOG.error("[接收到的参数]" + content);
        try {
            Map<String, String[]> paramterMap = request.getParameterMap();
            HashMap<String, String> params = new HashMap<String, String>();
            String k, v;
            Iterator<String> iterator = paramterMap.keySet().iterator();
            while (iterator.hasNext()) {
                k = iterator.next();
                String arr[] = paramterMap.get(k);
                v = (String) arr[0];
                params.put(k, v);
                LOG.error(k + "=" + v);
            }
            LOG.error("[参数结束]");
            String appId = params.get("appId");
            String orderStatus = params.get("orderStatus");
            String signature = params.get("signature");
            String cpUserInfo = params.get("cpUserInfo");
            String amount = params.get("payFee");
            String orderId = params.get("orderId");
            if (orderStatus == null) {
                LOG.error("chYhXm orderStatus 错误！！ ");
                return packResponse(200).toString();
            }

            if (!"TRADE_SUCCESS".equals(orderStatus)) {
                LOG.error("chYhXm orderStatus 错误！！ ");
                return packResponse(200).toString();
            }

            if (appId == null || !AppID.equals(appId)) {
                LOG.error("chYhXm appid 不一致！！ ");
                return packResponse(1515).toString();
            }

            String orginSign = getSign(params, AppSecret);
            LOG.error("签名：" + orginSign + " | " + signature);
            if (orginSign.equals(signature)) {
                String[] infos = cpUserInfo.split("_");
                if (infos.length != 3) {
                    LOG.error("chYhXm 透传参数长度不等于3！！ ");
                    return packResponse(200).toString();
                }

                int serverid = Integer.valueOf(infos[0]);
                Long lordId = Long.valueOf(infos[1]);
                // int rechargeId = Integer.valueOf(infos[2]);
                // String exorderno = infos[3];

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = params.get("uid");
                payInfo.orderId = orderId;

                payInfo.serialId = cpUserInfo;
                payInfo.serverId = serverid;
                payInfo.roleId = lordId;
                payInfo.realAmount = Double.valueOf(amount) / 100;
                payInfo.amount = (int) (payInfo.realAmount / 1);
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("chYhXm 充值发货失败！！ " + code);
                }
                return packResponse(200).toString();
            } else {
                LOG.error("chYhXm 签名不一致！！ ");
                return packResponse(1525).toString();
            }
        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
            LOG.error("chYhXm充值异常");
            return packResponse(200).toString();
        }

    }

    private MiAccount verifyAccount(String session, String uid) {
        LOG.error("chYhXm开始调用sidInfo接口");

        HashMap<String, String> params = new HashMap<String, String>();
        params.put("appId", AppID);
        params.put("session", session);
        params.put("uid", uid);
        String signature = getSign(params, AppSecret);
        params.put("signature", signature);

        String result = HttpUtils.sendGet(serverUrl, params);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int errcode = rsp.getInt("errcode");
            if (200 != errcode) {
                String errMsg = rsp.getString("errMsg");
                LOG.error("chYhXm login error :" + errMsg);
                return null;
            }

            MiAccount miAccount = new MiAccount();
            miAccount.uid = uid;
            return miAccount;
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        }
    }
}
