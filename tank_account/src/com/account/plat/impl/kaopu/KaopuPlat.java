package com.account.plat.impl.kaopu;

import java.util.Date;
import java.util.Iterator;
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
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class KaopuPlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL = "";

    private static String APP_ID;

    private static String APP_KEY;

    private static String APP_SECRET = "";

    private static String CHANNELINNER_ID = "";

    private static String KAOPU_APPVERSION = "";

    private static String[] scretkey = {"18257284-7F5D-348D-AB09-299E5B7DD997", "655A957D-157D-7C21-E3A7-9CAAFA835318",
            "F467CA93-D550-346D-6BCB-173995F7C83A", "BD32817A-99F9-2E26-5B33-15208F7B360A"};

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/kaopu/", "plat.properties");

        VERIRY_URL = properties.getProperty("VERIRY_URL");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        APP_SECRET = properties.getProperty("APP_SECRET");
        KAOPU_APPVERSION = properties.getProperty("KAOPU_APPVERSION");
        CHANNELINNER_ID = properties.getProperty("KAOPU_CHANNELINNER_ID");

    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        // TODO Auto-generated method stub
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        LOG.error("接收参数 sid:" + sid + " deviceNo:" + deviceNo + " baseVersion:" + baseVersion + " versionNo:" + versionNo);
        String[] vParam = sid.split("_");
        if (vParam.length < 6) {
            return GameError.PARAM_ERROR;
        }

        if (!verifyAccount(vParam)) {
            return GameError.SDK_LOGIN;
        }

        String uid = vParam[1];

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

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay Kaopu");
        LOG.error("[接收到的参数]" + content);
        JSONObject result = new JSONObject();
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }

            String username = request.getParameter("username");
            String kpordernum = request.getParameter("kpordernum");
            String ywordernum = request.getParameter("ywordernum");
            String status = request.getParameter("status");
            String paytype = request.getParameter("paytype");
            String amount = request.getParameter("amount");
            String gameserver = request.getParameter("gameserver");
            String errdesc = request.getParameter("errdesc");
            String paytime = request.getParameter("paytime");
            String gamename = request.getParameter("gamename");
            String sign = request.getParameter("sign");

            if (!"1".equals(status)) {
                result.put("code", 1003);
                result.put("msg", "订单支付失败");
                result.put("sign", MD5Util.toMD5("1003" + APP_SECRET));
                return result.toString();
            }

            String signnation = username + "|" + kpordernum + "|" + ywordernum + "|" + status + "|" + paytype + "|" + amount + "|" + gameserver + "|" + errdesc
                    + "|" + paytime + "|" + gamename + "|" + APP_SECRET;
            String tosign = MD5.md5Digest(signnation);
            LOG.error("[签名原文]" + signnation);
            LOG.error("[签名结果]" + sign + "|" + tosign);
            if (!tosign.equals(sign)) {
                result.put("code", 1002);
                result.put("msg", "验签失败");
                result.put("sign", MD5Util.toMD5("1002|" + APP_SECRET));
                LOG.error("kaopu 验签失败");
                return result.toString();
            }

            String[] infos = ywordernum.split("_");
            if (infos.length != 4) {
                result.put("code", 1004);
                result.put("msg", "系统异常");
                result.put("sign", MD5Util.toMD5("1004|" + APP_SECRET));
                LOG.error("kaopu 参数不正确");
                return result.toString();
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            String platId = infos[3];

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = platId;
            payInfo.orderId = kpordernum;

            payInfo.serialId = ywordernum;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(amount) / 100.0;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);

            if (code == 0) {
                LOG.error("返回充值成功");
                result.put("code", "1000");
                result.put("msg", "订单支付成功");
                result.put("sign", MD5Util.toMD5("1000|" + APP_SECRET));
            } else {
                LOG.error("返回充值发货失败");
                result.put("code", "1000");
                result.put("msg", "订单支付成功");
                result.put("sign", MD5Util.toMD5("1000|" + APP_SECRET));
            }
            return result.toString();
        } catch (Exception e) {
            LOG.error("充值异常:" + e.getMessage());
            e.printStackTrace();
            result.put("code", 1003);
            result.put("msg", "系统异常");
            result.put("sign", MD5Util.toMD5("1003|" + APP_SECRET));
            return result.toString();
        }
    }

    private boolean verifyAccount(String[] vParam) {
        LOG.error("kaopu 开始调用Oauth2.0验证接口");
        int r = RandomHelper.randomInSize(scretkey.length);
        String commonKey = scretkey[r];
        String devicetype = vParam[0];
        String openid = vParam[1];
        String token = vParam[2];
        String imei = vParam[3];

        String orSign = APP_ID + CHANNELINNER_ID + imei + r + APP_KEY + APP_SECRET + KAOPU_APPVERSION + commonKey;
        String signDes = MD5.md5Digest(orSign);
        // LOG.error("[请求地址签名原文]" + orSign);
        // LOG.error("[请求地址签名结果]" + signDes);

        StringBuffer queryUrl = new StringBuffer();
        queryUrl.append(VERIRY_URL).append("?");
        queryUrl.append("tag=").append(APP_KEY).append("&");
        queryUrl.append("tagid=").append(APP_SECRET).append("&");
        queryUrl.append("appid=").append(APP_ID).append("&");
        queryUrl.append("version=").append(KAOPU_APPVERSION).append("&");
        queryUrl.append("imei=").append(imei).append("&");
        queryUrl.append("channelkey=").append(CHANNELINNER_ID).append("&");
        queryUrl.append("r=").append(r).append("&");
        queryUrl.append("sign=").append(signDes);

        // LOG.error("[请求地址请求参数]" + queryUrl.toString());
        String urlRet = HttpHelper.doGet(queryUrl.toString());
        if (urlRet == null) {
            LOG.error("请求地址返回null:");
            return false;
        }
        JSONObject urlRets = JSONObject.fromObject(urlRet);
        int urlCode = urlRets.getInt("code");
        if (urlCode != 1) {
            LOG.error("请求地址失败:" + urlRets);
            return false;
        }

        JSONObject urlData = urlRets.getJSONObject("data");
        if (urlData == null) {
            LOG.error("请求地址失败:" + urlRets);
            return false;
        }
        String sendURl = urlData.getString("url");
        if (sendURl == null) {
            LOG.error("kaopu 请求地址失败:" + urlRets);
            return false;
        }

        StringBuffer sb = new StringBuffer();
        sb.append(sendURl).append("?");
        sb.append("devicetype=").append(devicetype).append("&");
        sb.append("imei=").append(imei).append("&");
        sb.append("r=").append(r).append("&");
        sb.append("tag=").append(APP_KEY).append("&");
        sb.append("tagid=").append(APP_SECRET).append("&");
        sb.append("appid=").append(APP_ID).append("&");
        sb.append("channelkey=").append(CHANNELINNER_ID).append("&");
        sb.append("openid=").append(openid).append("&");
        sb.append("token=").append(token).append("&");

        String signNation = APP_ID + CHANNELINNER_ID + devicetype + imei + openid + r + APP_KEY + APP_SECRET + token + commonKey;
        String sign = MD5.md5Digest(signNation);
        LOG.error("[签名原文]" + signNation);
        LOG.error("[签名结果]" + sign);
        sb.append("sign=").append(sign);

        LOG.error("[请求参数]" + sb.toString());
        String result = HttpHelper.doGet(sb.toString());
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
        if (result == null) {
            LOG.error("kaopu 登陆失败返回值为null:");
            return false;
        }
        String code;
        String msg;
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            code = rsp.getString("code");
            msg = rsp.getString("msg");
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return false;
        }

        LOG.error("Oauth2.0验证接口接口结束");
        if ("1".equals(code)) {
            LOG.error("kaopu a登陆成功:");
            return true;
        } else {
            LOG.error("kaopu 登陆失败:" + code + " 原因:" + msg);
            return false;
        }

    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }

    public static void main(String[] args) {
        String ss = "10299001" + "kaopu" + "android" + "357584050134370" + "FBC8184D4708E5C1FC57A44A33502C5D" + "1" + "10299"
                + "98902784-1EAF-473F-8A85-B169FDE3189F" + "3448E90A7E91F0A16B6C17AC7DC59DAF" + "655A957D-157D-7C21-E3A7-9CAAFA835318";
        //LOG.error(ss);
        //LOG.error(MD5Util.toMD5(ss));
    }
}
