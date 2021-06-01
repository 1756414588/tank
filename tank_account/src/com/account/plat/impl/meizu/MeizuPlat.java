package com.account.plat.impl.meizu;

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
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class MeizuPlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL = "";

    private static String APP_ID;

    private static String APP_KEY;

    private static String APP_SECRET = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/meizu/", "plat.properties");

        VERIRY_URL = properties.getProperty("VERIRY_URL");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        APP_SECRET = properties.getProperty("APP_SECRET");

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

        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];
        String accessToken = vParam[1];

        if (!verifyAccount(uid, accessToken)) {
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

    @Override
    public String order(WebRequest request, String content) {
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

            String sign = getSign(params, APP_SECRET);
            return packOrderResponse(0, sign).toString();
        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
            return packOrderResponse(1, "服务器异常").toString();
        }
    }

    private JSONObject packResponse(String code, String message) {
        JSONObject res = new JSONObject();
        res.put("code", code);
        res.put("message", message);
        return res;
    }

    private JSONObject packOrderResponse(int code, String sign) {
        JSONObject res = new JSONObject();
        res.put("code", code);
        res.put("sign", sign);
        return res;
    }

    public static void main(String[] args) {
        //LOG.error(MD5.md5Digest("中国"));
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay meizu");
        LOG.error("[接收到的参数]" + content);
        // return null;
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

            String sign1 = params.get("sign");
            String sign2 = getSign(params, APP_SECRET);
            LOG.error("meizu 生成签名:" + sign2 + "|" + sign1);
            if (!sign1.equals(sign2)) {
                LOG.error("meizu 验签失败");
                return packResponse("120014", "sign error").toString();
            }

            String trade_status = params.get("trade_status");
            if (!"3".equals(trade_status)) {
                LOG.error("meizu 支付不成功");
                return packResponse("200", "success").toString();
            }

            String amount = params.get("total_price");
            String extInfo = params.get("user_info");
            String order_id = params.get("order_id");
            String uid = params.get("uid");
            String[] infos = extInfo.split("_");
            if (infos.length != 3) {
                LOG.error("meizu 传参错误");
                return packResponse("120014", "param error").toString();
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            // int rechargeId = Integer.valueOf(infos[2]);
            // String exorderno = infos[3];

            // String[] param = extInfo.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = uid;
            payInfo.orderId = order_id;

            payInfo.serialId = extInfo;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);

            // int rsCode = payResult(lordId, serverid, Double.valueOf(amount) *
            // 100, rechargeId, order_id, exorderno);
            if (code == 0) {
                LOG.error("meizu 返回充值成功");
                return packResponse("200", "success").toString();
            } else {
                LOG.error("meizu 返回充值失败");
                return packResponse("120013", "send error").toString();
            }

        } catch (Exception e) {
            LOG.error("meizu 充值异常:" + e.getMessage());
            e.printStackTrace();
            return packResponse("900000", "exception error").toString();
        }
    }

    private static String getSign(HashMap<String, String> params, String appSecret) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat") || k.equals("sign_type")) {
                continue;
            }

            // if (params.get(k) == null || params.get(k).equals("")) {
            // continue;
            // }

            if (params.get(k) == null) {
                continue;
            }
            v = (String) params.get(k);

            if (i != 0) {
                str += "&";
            }

            str += k + "=" + v;
        }

        str += ":" + appSecret;
        //LOG.error("getSign:" + str);
        return MD5.md5Digest(str);
    }

    private boolean verifyAccount(String uid, String accessToken) {
        LOG.error("meizu开始调用sidInfo接口");

        Date now = new Date();
        String ts = String.valueOf(now.getTime());

        HashMap<String, String> params = new HashMap<String, String>();
        params.put("app_id", APP_ID);
        params.put("session_id", accessToken);
        params.put("uid", uid);
        params.put("ts", ts);

        String sign = getSign(params, APP_SECRET);
        String body = "app_id=" + APP_ID + "&session_id=" + accessToken + "&uid=" + uid + "&ts=" + now.getTime() + "&sign_type=md5" + "&sign=" + sign;
        LOG.error("[请求参数]" + body);

        String result = HttpUtils.sentPost(VERIRY_URL, body);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            String code = rsp.getString("code");
            if (!"200".equals(code)) {
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
}
