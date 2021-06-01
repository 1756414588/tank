package com.account.plat.impl.nhdz;

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
import com.account.plat.impl.jrtt.RSA;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class NhdzPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_SECRET = "";

    private static String PAY_KEY = "";

    private static String PUBLIC_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/nhdz/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
        APP_SECRET = properties.getProperty("APP_SECRET");
        PAY_KEY = properties.getProperty("PAY_KEY");
        PUBLIC_KEY = properties.getProperty("PUBLIC_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");
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

        String access_token = vParam[0];
        String uid = vParam[1];
        if (!verifyAccount(uid, access_token)) {
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
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay nhdz");
        try {
            LOG.error("[开始接收参数]");
            Map<String, String> params = new HashMap<String, String>();
            Iterator<String> it = request.getParameterNames();
            while (it.hasNext()) {
                String paramKey = it.next();
                String paramValue = request.getParameter(paramKey);
                LOG.error(paramKey + "=" + paramValue);
                params.put(paramKey, paramValue);
            }
            LOG.error("[结束接收参数]");

            String buyer_id = request.getParameter("buyer_id");
            String client_id = request.getParameter("client_id");
            String notify_id = request.getParameter("notify_id");
            String notify_time = request.getParameter("notify_time");
            String notify_type = request.getParameter("notify_type");
            String out_trade_no = request.getParameter("out_trade_no");
            String pay_time = request.getParameter("pay_time");
            String total_fee = request.getParameter("total_fee");
            String trade_no = request.getParameter("trade_no");
            String trade_status = request.getParameter("trade_status");
            String tt_sign = request.getParameter("tt_sign");
            // String tt_sign_type = request.getParameter("tt_sign_type");
            String way = request.getParameter("way");

            if (!"0".equals(trade_status)) {
                LOG.error("扣费不成功");
                return "error";
            }

            // 所有参数按键先后排序组装,然后进行RSA签名验证
            LOG.error("[签名公钥]" + PUBLIC_KEY);

            // String signcontent = "buyer_id=" + buyer_id + "&client_id=" +
            // client_id + "&notify_id=" + notify_id + "&notify_time=" +
            // notify_time
            // + "&notify_type=" + notify_type + "&out_trade_no=" + out_trade_no
            // + "&pay_time=" + pay_time + "&total_fee=" + total_fee +
            // "&trade_no="
            // + trade_no + "&trade_status=" + trade_status + "&way=" + way;

            String signcontent = getSignNation(params);
            boolean verify_result = RSA.verify(signcontent, tt_sign, PUBLIC_KEY);
            LOG.error("[签名原文]" + signcontent);
            LOG.error("[签名结果]" + verify_result);

            if (!verify_result) {
                LOG.error("验签失败");
                return "error";
            }
            String[] infos = out_trade_no.split("_");
            if (infos.length != 4) {
                LOG.error("传参不正确");
                return "success";
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            String userId = infos[3];

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = userId;
            payInfo.orderId = trade_no;

            payInfo.serialId = out_trade_no;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(total_fee) / 100.0;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int retcode = payToGameServer(payInfo);
            if (retcode == 0) {
                LOG.error("返回充值成功");
                return "success";
            } else {
                LOG.error("返回充值失败" + retcode);
                return "error";
            }
        } catch (Exception e) {
            LOG.error("支付异常");
            return "error";
        }
    }

    public static String getSignNation(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("tt_sign") || k.equals("tt_sign_type") || k.equals("plat")) {
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

    private boolean verifyAccount(String uid, String access_token) {
        LOG.error("nhdz 开始调用sidInfo接口");

        Map<String, String> parameter = new HashMap<>();
        parameter.put("client_key", APP_ID);
        parameter.put("uid", uid);
        parameter.put("access_token", access_token);
        parameter.put("check_safe", "0");
        LOG.error("[请求参数]" + parameter.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sendGet(serverUrl, parameter);
        LOG.error("[响应结果]" + result);

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            String message = rsp.getString("message");

            if ("success".equals(message)) {
                // return true;
                JSONObject data = rsp.getJSONObject("data");
                if (data.containsKey("verify_result") && data.getInt("verify_result") == 1) {
                    return true;
                }
                LOG.error("jrtt 登陆失败:" + message);
            }

            return false;

        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
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
}
