package com.account.plat.impl.anzhi;

import java.text.SimpleDateFormat;
import java.util.Date;
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
import com.account.plat.impl.anzhi.util.Base64;
import com.account.plat.impl.anzhi.util.Des3Util;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

class AnzhiAccount {
    public String uid;
    public String nickName;
}

@Component
public class AnzhiPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";
    private static String APP_KEY = "";
    private static String APP_SECRET = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/anzhi/", "plat.properties");
        APP_KEY = properties.getProperty("APP_KEY");
        APP_SECRET = properties.getProperty("APP_SECRET");
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

        AnzhiAccount anzhiAccount = verifyAccount(sid);
        if (anzhiAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), String.valueOf(anzhiAccount.uid));
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(String.valueOf(anzhiAccount.uid));
            account.setAccount(getPlatNo() + "_" + String.valueOf(anzhiAccount.uid));
            account.setPasswd(String.valueOf(anzhiAccount.uid));
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
        LOG.error("pay anzhi");
        LOG.error("[接收到的参数]" + content);
        try {
            String data = Des3Util.decrypt(request.getParameter("data"), APP_SECRET);

            LOG.error("anzhi 支付回调data:" + data);
            JSONObject json = JSONObject.fromObject(data);
            String uid = json.getString("uid");
            String orderId = json.getString("orderId");
            String orderAmount = json.getString("orderAmount");
            // String orderTime = json.getString("orderTime");
            // String orderAccount = json.getString("orderAccount");
            String code = json.getString("code");
            // String payAmount = json.getString("payAmount");
            String cpInfo = json.getString("cpInfo");
            // String notifyTime = json.getString("notifyTime");
            // String memo = json.getString("memo");
            String redBagMoney = null;
            if (json.containsKey("redBagMoney")) {
                redBagMoney = json.getString("redBagMoney");
            }

            if (!"1".equals(code)) {
                LOG.error("支付不成功");
                return "success";
            }

            String[] infos = cpInfo.split("_");
            if (infos.length != 3) {
                LOG.error("传参不正确");
                return "success";
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);
            // int exorderno = Integer.valueOf(infos[2]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = uid;
            payInfo.orderId = orderId;

            payInfo.serialId = cpInfo;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            float amount = Float.valueOf(orderAmount);
            if (redBagMoney != null && !redBagMoney.equals("")) {
                amount += Float.valueOf(redBagMoney);
            }
            payInfo.amount = (int) (amount / 100);
            payInfo.realAmount = Double.valueOf(orderAmount) / 100.0;
            int retCode = payToGameServer(payInfo);

            // int rsCode = payResult(lordId, serverid, Double.valueOf(amount) *
            // 100, rechargeId, order_id, exorderno);
            if (retCode == 0) {
                LOG.error("anzhi 返回充值成功");
                return "success";
            }

        } catch (Exception e) {
            LOG.error("anzhi 充值异常 " + e.getMessage());
            e.printStackTrace();
            return "success";
        }
        return "success";
    }

    private AnzhiAccount verifyAccount(String sid) {
        LOG.error("anzhi开始调用sidInfo接口");

        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMddHHmmssSSS");
        String time = simpleDateFormat.format(new Date());

        // Base64.encodeToString(appkey +sid+appsecret)
        String signSource = APP_KEY + sid + APP_SECRET;// 组装签名原文
        String sign = Base64.encodeToString(signSource);

        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        String body = "time=" + time + "&appkey=" + APP_KEY + "&sid=" + sid + "&sign=" + sign;
        LOG.error("[请求参数]" + body);

        String result = HttpUtils.sentPost(serverUrl, body);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        AnzhiAccount anzhiAccount = new AnzhiAccount();
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int sc = rsp.getInt("sc");
            String st = rsp.getString("st");
            if (sc == 1 || sc == 200) {
                String msg = rsp.getString("msg");
                String tem = Base64.decode(msg, "UTF-8");
                JSONObject temObject = JSONObject.fromObject(tem);
                anzhiAccount.uid = temObject.getString("uid");
                // anzhiAccount.nickName = anzhiAccount.uid;
                return anzhiAccount;
            } else {
                LOG.error("anzhi登陆失败:" + sc + "|" + st);
                return null;
            }

        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常 " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }

    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }
}
