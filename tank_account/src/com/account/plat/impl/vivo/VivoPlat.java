package com.account.plat.impl.vivo;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.util.*;

@Component
public class VivoPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";
    // 游戏合作商编号
    private static String cpId;
    private static String AppId;
    private static String ORDERID_URL;
    // 分配给游戏合作商的接入密钥,请做好安全保密
    private static String API_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/vivo/", "plat.properties");
        cpId = properties.getProperty("CP_ID");
        API_KEY = properties.getProperty("API_KEY");
        AppId = properties.getProperty("App_Id");
        ORDERID_URL = properties.getProperty("ORDERID_URL");
        serverUrl = properties.getProperty("VERIRY_URL");

    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        //登录：  SID = userName + "__" + openId + "__" + authToken;  中间是双下划线

        String[] split = sid.split("__");

        String userName = split[0];

        boolean issucc = verifyAccount(split[2]);
        if (!issucc) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userName);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userName);
            account.setAccount(getPlatNo() + "_" + userName);
            account.setPasswd(userName);
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
        response.setUserInfo(userName);


        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String order(WebRequest request, String content) {
        LOG.error("order vivo");

        LOG.error("vivo [接收到的参数]" + content);
        try {
            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<String, String>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error("vivo " + paramName + ":" + request.getParameter(paramName));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("vivo [参数结束]");


            String cpOrderNumber = params.get("cpOrderNumber");
            String notifyUrl = params.get("notifyUrl");
            String orderTime = params.get("orderTime");
            String orderAmount = params.get("orderAmount");
            String orderTitle = params.get("orderTitle");
            String orderDesc = params.get("orderDesc");
            String extInfo = params.get("extInfo");


            Map<String, String> p = new HashMap<>();
            p.put("version", "1.0.0");
            p.put("cpId", cpId);
            p.put("appId", AppId);
            p.put("cpOrderNumber", cpOrderNumber);
            p.put("notifyUrl", notifyUrl);
            p.put("orderTime", orderTime);
            p.put("orderAmount", orderAmount);
            p.put("orderTitle", orderTitle);
            p.put("orderDesc", orderDesc);
            p.put("extInfo", extInfo);

            List<String> list = new ArrayList<>();
            list.add("version");
            list.add("cpId");
            list.add("appId");
            list.add("cpOrderNumber");
            list.add("notifyUrl");
            list.add("orderTime");
            list.add("orderAmount");
            list.add("orderTitle");
            list.add("orderDesc");
            list.add("extInfo");
            Collections.sort(list);

            StringBuilder sb = new StringBuilder();
            for (String str : list) {
                sb.append(str);
                sb.append("=");
                sb.append(p.get(str));
                sb.append("&");
            }
            sb.append(MD5Util.toMD5(API_KEY));

            LOG.error("vivo md5str " + sb.toString());
            p.put("signature", MD5Util.toMD5(sb.toString()));
            p.put("signMethod", "MD5");

            StringBuilder paramStr = new StringBuilder();
            for (Map.Entry<String, String> e : p.entrySet()) {
                paramStr.append(e.getKey());
                paramStr.append("=");
                paramStr.append(e.getValue());
                paramStr.append("&");
            }

            com.alibaba.fastjson.JSONObject result = new com.alibaba.fastjson.JSONObject();

            String resultStr = HttpUtils.sentPost(ORDERID_URL, paramStr.toString().substring(0, paramStr.toString().length() - 1));

            LOG.error("vivo order " + resultStr);
            com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(resultStr);
            if (jsonObject.containsKey("retcode") && jsonObject.getIntValue("retcode") != 200) {
                result.put("status", jsonObject.getIntValue("retcode"));
                result.put("msg", jsonObject.getString("respMsg"));
                return result.toJSONString();
            }

            result.put("status", 0);
            result.put("orderNumber", jsonObject.getString("orderNumber"));
            result.put("accessKey", jsonObject.getString("accessKey"));
            return result.toJSONString();
        } catch (Exception e) {
            e.printStackTrace();
            return "FAILURE";
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay vivo payBack");
        LOG.error("vivopayBack [接收到的参数]" + content);
        try {

            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<String, String>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error("vivopayBack " + paramName + ":" + request.getParameter(paramName));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("vivopayBack [参数结束]");


            String signature = params.get("signature");

            List<String> list = new ArrayList<>();
            list.add("respCode");
            list.add("respMsg");
            list.add("tradeType");
            list.add("tradeStatus");
            list.add("cpId");
            list.add("appId");
            list.add("uid");
            list.add("cpOrderNumber");
            list.add("orderNumber");
            list.add("orderAmount");
            list.add("extInfo");
            list.add("payTime");
            Collections.sort(list);


            StringBuilder sb = new StringBuilder();
            for (String str : list) {
                sb.append(str);
                sb.append("=");
                sb.append(params.get(str));
                sb.append("&");
            }
            sb.append(MD5Util.toMD5(API_KEY));
            String toMD5 = MD5Util.toMD5(sb.toString());

            LOG.error("vivopayBack md5str =" + sb.toString() + " md5val=" + toMD5);
            if (!signature.equals(toMD5)) {
                return "fail md5 error";
            }
            String cpOrderNumber = params.get("cpOrderNumber");
            String[] infos = cpOrderNumber.split("_");
            if (infos.length != 3) {
                return "fail";
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = params.get("uid");
            payInfo.orderId = params.get("orderNumber");

            payInfo.serialId = cpOrderNumber;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = (Double.valueOf(params.get("orderAmount"))) / 100;
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("vivopayBack 充值发货失败！！ " + code);
                return "fail";
            }
            LOG.error("vivopayBack 充值发货成功");
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }

    private boolean verifyAccount(String authToken) {

        String body = "authtoken=" + authToken;
        String result = HttpUtils.sentPost(serverUrl, body);
        if (result == null) {
            return false;
        }
        LOG.error("vivo verifyAccount " + result);
        com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(result);
        if (jsonObject.containsKey("retcode") && jsonObject.getIntValue("retcode") != 0) {
            return false;
        }
        return true;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }
}
