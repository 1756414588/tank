package com.account.plat.impl.jqios;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.alibaba.fastjson.JSON;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

@Component
public class JqIosPlat extends PlatBase {

    private static String VERIRY_URL = "";

    private static String AppID;

    private static String AppKey;

    private static String VERIRY_URL_SANBOX;

    private static String PAY_VERIRY_URL;

    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    private void initRechargeMap() {
        MONEY_MAP.put(1, 6);
        MONEY_MAP.put(2, 30);
        MONEY_MAP.put(3, 98);
        MONEY_MAP.put(4, 198);
        MONEY_MAP.put(5, 328);
        MONEY_MAP.put(6, 648);
    }

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/jqios/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
        PAY_VERIRY_URL = properties.getProperty("PAY_VERIRY_URL");
        VERIRY_URL_SANBOX = properties.getProperty("PAY_VERIRY_URL_SANBOX");

        initRechargeMap();
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("__");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        if (!verifyAccount(vParam[0], vParam[2])) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(getPlatNo());
            account.setChildNo(super.getPlatNo());
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

    private boolean verifyAccount(String game_uin, String token) {
        LOG.error("jq_appstore 开始调用sidInfo接口");


        long t = System.currentTimeMillis() / 1000;
        String signStr = AppID + token + AppKey;
        LOG.error("jq_appstore待签名字符串:" + signStr);

        String sign = MD5.md5Digest(signStr);
        LOG.error("jq_appstore签名:" + sign);

        HashMap<String, String> params = new HashMap<>();
        params.put("user_id", game_uin);
        params.put("app_id", AppID);
        params.put("token", token);
        params.put("sign", sign);


        String url = VERIRY_URL + getParamsStr(params);
        LOG.error("jq_appstore签名 请求url:" + url);
        try {
            String result = HttpUtils.sendGet(url, new HashMap<String, String>());
            LOG.error("jq_appstore[响应结果]" + result);

            JSONObject res = new JSONObject();
            if (result != null) {
                res = JSONObject.fromObject(result);
            }

            if (res.containsKey("result") && res.getInt("result") == 1) {
                return true;
            }
            return false;
        } catch (Exception e) {
            LOG.error("jq_appstore 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用jq_appstore接口结束");
        }
    }

    private static String getParamsStr(HashMap<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;
        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (params.get(k) == null || params.get(k).equals("")) {
                continue;
            }
            v = (String) params.get(k);

            if (i != 0) {
                str += "&";
            }
            str += k + "=" + v;
        }
        return str;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay jq_appstore appstore content:" + content);

        try {

//            content = URLDecoder.decode(content, "UTF-8");
//            content = content.substring(content.indexOf("{"), content.lastIndexOf("}") + 1);
//            content = content.replace("=", "");

//            JSONObject json = JSONObject.fromObject(content);

            String data = request.getParameter("data");

            JSONObject params = new JSONObject();
            params.put("receipt-data", data);
            String body = params.toString();
            LOG.error("jq_appstore[请求参数]" + body);

            String result = HttpUtils.sentPost(PAY_VERIRY_URL, body);
            LOG.error("jq_appstore[appstore 返回]" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            int status = rsp.getInt("status");
            if (status != 0) {
                LOG.error("jq_appstore form status error");
                result = HttpUtils.sentPost(VERIRY_URL_SANBOX, body);
                JSONObject rsp1 = JSONObject.fromObject(result);
                LOG.error("jq_appstore [沙箱 返回]" + rsp1.getInt("status"));
                if (rsp1.getInt("status") != 0) {
                    return "FAILURE";
                }
                rsp = rsp1;
            }


            //透传参数  orderid： serverid  uid  时间戳
            //			extInfo： payId  amount  plat_id

            String orderid = request.getParameter("orderId");
            String extInfo = request.getParameter("extInfo");

            String[] str = orderid.split("__");
            String[] info = extInfo.split("__");
            JSONObject receipt = rsp.getJSONObject("receipt");
            String transaction_id = receipt.getString("transaction_id");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.childNo = super.getPlatNo();
            payInfo.platId = info[2];

            payInfo.orderId = transaction_id;
            payInfo.serialId = orderid;
            payInfo.serverId = Integer.valueOf(str[0]);
            payInfo.roleId = Long.valueOf(str[1]);

            int money = MONEY_MAP.get(Integer.valueOf(info[0]));
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("jq_appstore appstore 充值发货失败！！ " + code);
                return "0|" + (System.currentTimeMillis() / 1000);
            }

            return "1|" + (System.currentTimeMillis() / 1000);
        } catch (Exception e) {
            LOG.error("jq_appstore appstore 充值异常！！ ");
            e.printStackTrace();
            return "0|" + (System.currentTimeMillis() / 1000);
        }
    }


    @Override
    public String newPayBack(WebRequest request, String content, HttpServletResponse response, String type) {

        LOG.error("pay jqPayCallback appstore new");
        LOG.error("jqPayCallback [接收到的参数]" + content);
        com.alibaba.fastjson.JSONObject result = new com.alibaba.fastjson.JSONObject();


        try {
            Map<String, String> params = new HashMap<String, String>();
            params.put("app_id", request.getParameter("app_id"));
            params.put("app_orderid", request.getParameter("app_orderid"));
            params.put("order_id", request.getParameter("order_id"));
            params.put("player_id", request.getParameter("player_id"));
            params.put("user_id", request.getParameter("user_id"));
            params.put("coin", request.getParameter("coin"));
            params.put("money", request.getParameter("money"));
            params.put("createtime", request.getParameter("createtime"));
            params.put("serv_id", request.getParameter("serv_id"));
            params.put("sign", request.getParameter("sign"));

            String signstr = params.get("app_id") + params.get("player_id") + params.get("app_orderid") + params.get("coin") + params.get("money") + params.get("createtime") + AppKey;


            LOG.error("jqPayCallback signstr " + signstr);

            String sign = MD5Util.toMD5(signstr);
            LOG.error("jqPayCallback sign " + sign);

            if (!AppID.equals(params.get("app_id"))) {
                LOG.error("jqPayCallback appstore 充值应用ID不一致！！ ");

                result.put("err_code", 1);
                result.put("desc", " AppID 充值应用ID不一致！！");
                return result.toJSONString();

            }

            String originSign = params.get("sign");
            if (!sign.equalsIgnoreCase(originSign)) {
                LOG.error("jqPayCallback appstore 签名不一致！！ " + originSign + "|" + sign);
                result.put("err_code", 1);
                result.put("desc", " 签名不一致！！");
                return result.toJSONString();
            }

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = params.get("user_id");
            payInfo.orderId = params.get("order_id");
            payInfo.serialId = params.get("app_orderid");

            String[] v = payInfo.serialId.split("_");
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(params.get("money"));
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("jqPayCallback appstore 充值发货失败！！ " + code);
                result.put("err_code", 1);
                result.put("desc", "充值发货失败code " + code);
                return result.toJSONString();

            }
            result.put("err_code", 0);
            result.put("desc", "充值成功");
            return result.toJSONString();

        } catch (Exception e) {
            e.getMessage();
            LOG.error("jqPayCallback appstore 充值异常！！ " + e.getMessage());
            result.put("err_code", 1);
            result.put("desc", "system error");
            return result.toJSONString();
        }
    }
}
