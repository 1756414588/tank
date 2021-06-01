package com.account.plat.impl.wandoujia;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.Date;
import java.util.HashMap;
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
public class WdjPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    // private static String APP_ID;

    private static String APP_KEY = "";

    private static String SECRET_KEY = "";

    // private static String PAY_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/wandoujia/", "plat.properties");
        // if (properties != null) {
        // APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        SECRET_KEY = properties.getProperty("SECRET_KEY");
        // SECRET_KEY = properties.getProperty("SECRET_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");
        // }
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

        String[] vParam = sid.split(",");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String accessToken = vParam[0];
        String uid = vParam[1];
        if (!verifyAccount(accessToken, uid)) {
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
    public String payBack(WebRequest request, String content1, HttpServletResponse response) {
        LOG.error("pay wandoujia");
        LOG.error("[接收到的参数]" + content1);
        try {

            String content = request.getParameter("content");
            String signType = request.getParameter("signType");
            String sign = request.getParameter("sign");

            JSONObject cjson = JSONObject.fromObject(content);
            String timeStamp = cjson.getString("timeStamp");
            String orderId = cjson.getString("orderId");
            String money = cjson.getString("money");
            String chargeType = cjson.getString("chargeType");
            String appKeyId = cjson.getString("appKeyId");
            String buyerId = cjson.getString("buyerId");
            String out_trade_no = cjson.getString("out_trade_no");
            String cardNo = cjson.getString("cardNo");

            boolean check = false;
            check = WandouRsa.doCheck(content, sign);
            if (!check) {
                LOG.error("签名不通过");
                return "fail";
            }

            String[] infos = out_trade_no.split("_");
            if (infos.length != 3) {
                return "fail";
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = buyerId;
            payInfo.orderId = orderId;

            payInfo.serialId = out_trade_no;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(money) / 100.0;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("发货成功");
                return "success";
            } else {
                LOG.error("发货失败");
                return "fail";
            }
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("支付异常");
            return "fail";
        }
    }

    private boolean verifyAccount(String accessToken, String uid) {
        LOG.error("wandoujia 开始调用sidInfo接口");

        Map<String, String> param = new HashMap<String, String>();
        param.put("appkey_id", APP_KEY);
        param.put("token", accessToken);
        param.put("uid", uid);
        LOG.error("[请求参数]" + param.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sendGet(serverUrl, param);

        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串
        if (result == null || result.equals("")) {
            return false;
        }
        if (result.trim().toLowerCase().equals("true")) {
            return true;
        }
        return false;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

}
