package com.account.plat.impl.pengy;

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
public class PengyPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_KEY = "";

    private static String SECRET_KEY = "";

    private static String PAY_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/pengy/", "plat.properties");
        // if (properties != null) {
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        PAY_KEY = properties.getProperty("PAY_KEY");
        SECRET_KEY = properties.getProperty("SECRET_KEY");
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

        String[] vParam = sid.split("_");
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
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay pengy");
        String dcontent = URLDecoder.decode(content);
        LOG.error("[接收到的参数]" + dcontent);
        JSONObject rets = new JSONObject();
        rets.put("ack", 200);
        rets.put("msg", "OK");
        try {

            dcontent = dcontent.replace("plat=pyw", "");
            dcontent = dcontent.replace("&", "");
            dcontent = dcontent.replace("=", "");

            JSONObject params = JSONObject.fromObject(dcontent);
            String tid = params.getString("tid");
            String sign = params.getString("sign");
            String gamekey = params.getString("gamekey");
            String channel = params.getString("channel");
            String cp_orderid = params.getString("cp_orderid");
            String ch_orderid = params.getString("ch_orderid");
            String amount = params.getString("amount");
            String cp_param = params.getString("cp_param");

            String signSource = SECRET_KEY + cp_orderid + ch_orderid + amount;
            String orginSign = MD5.md5Digest(signSource);
            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + sign + " | " + orginSign);

            if (!orginSign.equals(sign)) {
                LOG.error("验签失败");
                rets.put("ack", 1);
                rets.put("msg", "sign error");
                return rets.toString();
            }

            String[] infos = cp_orderid.split("_");
            if (infos.length != 3) {
                LOG.error("参数错误");
                return rets.toString();
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            JSONObject user_param = JSONObject.fromObject(cp_param);
            String platId = user_param.getString("SDK_userId");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = platId;
            payInfo.orderId = ch_orderid;

            payInfo.serialId = cp_orderid;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(amount);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("发货成功");
                return rets.toString();
            } else {
                LOG.error("发货失败");
                return rets.toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
            rets.put("ack", 2);
            rets.put("msg", "pay excption");
            LOG.error("支付异常");
            return rets.toString();
        }
    }

    private boolean verifyAccount(String accessToken, String uid) {
        LOG.error("pengyw 开始调用sidInfo接口");

        JSONObject param = new JSONObject();
        param.put("tid", System.currentTimeMillis());
        param.put("token", accessToken);
        param.put("uid", uid);
        LOG.error("[请求参数]" + param.toString());
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sentPost(serverUrl, param.toString());

        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int msg_code = rsp.getInt("ack");
            String msg_desc = rsp.getString("msg");

            if (msg_code == 200) {
                return true;
            }

            LOG.error("pengyw 登陆失败:" + msg_desc);
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

    public static void main(String[] args) {
        String ss = "%7B%22tid%22%3A%225863f795-dcf9-43%22%2C%22sign%22%3A%227ec7d35687284ccc666a9ec809bcf9e9%22%2C%22gamekey%22%3A%223b91b0f4%22%2C%22channel%22%3A%22PYW%22%2C%22cp_orderid%22%3A%221_132469_1456972423149_9648102d1983b0fe0254f341674%22%2C%22ch_orderid%22%3A%22K1603031N2187079%22%2C%22amount%22%3A%2210.00%22%2C%22cp_param%22%3A%22%7B%5C%22order_id%5C%22%3A%5C%221_132469_1456972423149_9648102d1983b0fe0254f3416746ce13%5C%22%2C%5C%22product_id%5C%22%3A1%2C%5C%22product_desc%5C%22%3A%5C%22%5Cu91d1%5Cu5e01%5C%22%7D%22%7D";
        //LOG.error(URLDecoder.decode(ss));
    }
}
