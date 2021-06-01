package com.account.plat.impl.zhuoyou;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
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
public class ZhuoyouPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_KEY = "";

    private static String APP_SECRET = "";

    // private static String PAY_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/zhuoyou/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
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

        String[] vParam = sid.split("_");
        if (vParam.length < 1) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        String access_token = vParam[1];
        if (!verifyAccount(userId, access_token)) {
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
        LOG.error("pay zhouyou");
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

            String Recharge_Id = request.getParameter("Recharge_Id");
            String App_Id = request.getParameter("App_Id");
            String Uin = request.getParameter("Uin");
            String Urecharge_Id = request.getParameter("Urecharge_Id");
            String Extra = request.getParameter("Extra");
            String Recharge_Money = request.getParameter("Recharge_Money");
            String Recharge_Gold_Count = request.getParameter("Recharge_Gold_Count");
            String Pay_Status = request.getParameter("Pay_Status");
            String Create_Time = request.getParameter("Create_Time");
            String sign = request.getParameter("Sign");

            if (!"1".equals(Pay_Status)) {
                LOG.error("订单支付失败");
                return "failure";
            }

            // 按顺序排序得到签名原文
            // String signNation = "App_Id=" + App_Id + "&Create_Time=" +
            // Create_Time + "&Extra=" + Extra + "&Pay_Status=" + Pay_Status +
            // "&Recharge_Gold_Count="
            // + Recharge_Gold_Count + "&Recharge_Id=" + Recharge_Id +
            // "&Recharge_Money=" + Recharge_Money + "&Uin=" + Uin +
            // "&Urecharge_Id="
            // + Urecharge_Id + APP_KEY;
            String signNation = getSignNation(params) + APP_KEY;
            String toSign = MD5.md5Digest(signNation);

            LOG.error("[签名原文]" + signNation);
            LOG.error("[签名结果]" + sign + "|" + toSign);
            if (!sign.equals(toSign)) {
                LOG.error("签名失败");
                return "failure";
            }

            String[] infos = Extra.split("_");
            if (infos.length != 3) {
                LOG.error("传参不正确");
                return "failure";
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = Uin;
            payInfo.orderId = Recharge_Id;

            payInfo.serialId = Extra;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(Recharge_Money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int retcode = payToGameServer(payInfo);
            if (retcode == 0) {
                LOG.error("发货成功");
                return "success";
            } else {
                LOG.error("发货失败" + retcode);
                return "failure";
            }
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("支付异常");
            return "failure";
        }
    }

    public static String getSignNation(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;

        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("Sign") || k.equals("plat")) {
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

    private boolean verifyAccount(String userId, String access_token) {
        LOG.error("zhuoyou 开始调用sidInfo接口");

        String signNation = "uid=" + userId + "&access_token=" + access_token + "&app_id=" + APP_ID + "&key=" + APP_KEY;
        String sign = MD5.md5Digest(signNation);

        LOG.error("[签名原文]" + signNation);
        LOG.error("[签名结果]" + sign);

        String body = "uid=" + userId + "&access_token=" + access_token + "&app_id=" + APP_ID + "&sign=" + sign;

        LOG.error("[请求参数]" + body);
        LOG.error("[请求地址]" + serverUrl);

        String result = HttpUtils.sentPost(serverUrl, body);
        LOG.error("[响应结果]" + result);

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            if (rsp == null || !rsp.containsKey("code")) {
                LOG.error("zhouyou 登陆失败未取到结果");
                return false;
            }
            String code = rsp.getString("code");
            if ("0".equals(code.trim())) {
                return true;
            }
            LOG.error("zhouyou 登陆失败" + code + "|" + rsp.getString("message"));
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

    public String sortyMapByKey(Map<String, String> map) {
        List<String> keys = new ArrayList<String>();
        Iterator<Entry<String, String>> it = map.entrySet().iterator();
        while (it.hasNext()) {
            Entry<String, String> next = it.next();
            String key = next.getKey();
            keys.add(key);
        }
        Collections.shuffle(keys);

        return "";
    }

    public static void main(String[] args) {
        // Map<String, String> map = new HashMap<String, String>();
        // map.put("accc1", "accc1");
        // map.put("aacc1", "aacc1");
        // map.put("abcc1", "abcc1");
        // map.put("bc1", "bc1");
        // map.put("baccc1", "baccc1");
        // List<String> keys = new ArrayList<String>();
        // Iterator<Entry<String, String>> it = map.entrySet().iterator();
        // while (it.hasNext()) {
        // Entry<String, String> next = it.next();
        // String key = next.getKey();
        // keys.add(key);
        // }
        // Collections.shuffle(keys);
        // for (String e : keys) {
        // LOG.error(e);
        // }

        Map<String, String> params = new HashMap<String, String>();
        params.put("Create_Time", "1457580340");
        params.put("Extra", "1_1427970_1457580329714");
        params.put("Pay_Status", "1");
        params.put("Recharge_Gold_Count", "0");
        params.put("Recharge_Money", "10");
        params.put("App_Id", "2402");
        params.put("Uin", "11031833");
        params.put("Urecharge_Id", "1_1427970_1457580329714");
        params.put("Recharge_Id", "D160310112540240211030516760097");

        String s = getSignNation(params);
        //LOG.error("[签名原文]" + s);

        String pp = "App_Id=2402" + "&Create_Time=1457580340" + "&Extra=1_1427970_1457580329714" + "&Pay_Status=1" + "&Recharge_Gold_Count=0"
                + "&Recharge_Id=D160310112540240211030516760097" + "&Recharge_Money=10" + "&Uin=11031833" + "&Urecharge_Id=1_1427970_1457580329714";
        // pp = pp + "8e77550fd12797fe81aa6087055e0ac1";
        //LOG.error("[签名原文]" + pp);
        //LOG.error(MD5.md5Digest(pp));
    }
}
