package com.account.plat.impl.chQzZzzhg_caohua;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.Http;
import com.account.util.HttpHelper;
import com.account.util.ParamUtil;
import com.account.util.RandomHelper;
import com.alibaba.fastjson.JSON;
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
public class ChQzZzzhgCaoHua extends PlatBase {
    private static String key;
    private static String secret;
    private static String appid;
    private static String veriry_url;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzZzzhg_caohua/", "plat.properties");
        veriry_url = properties.getProperty("veriry_url");
        key = properties.getProperty("key");
        secret = properties.getProperty("secret");
        appid = properties.getProperty("appid");
    }

    @Override
    public int getPlatNo() {
        return 82;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
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
        String userId = vParam[0];
        String ext_data = vParam[3];
        String platform_id = vParam[4];

        if (!verifyAccount(platform_id, ext_data)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
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

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("chQzZzzhg_caohua payBack " + content);

        Map<String, String> param = new HashMap<>();
        com.alibaba.fastjson.JSONObject json = new com.alibaba.fastjson.JSONObject();

        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();

                LOG.error("chQzZzzhg_caohua payBack " + paramName + ":" + request.getParameter(paramName));

                if (!paramName.equals("plat") && !paramName.equals("sign")) {
                    param.put(paramName, request.getParameter(paramName));
                }

            }

            String signSource = ParamUtil.getAzStr(param);
            signSource += secret;
            String sign = request.getParameter("sign");

            String md5 = MD5.md5Digest(signSource).toUpperCase();


            if (!md5.equals(sign)) {
                LOG.error("chQzZzzhg_caohua payBack 签名原文" + signSource);
                LOG.error("chQzZzzhg_caohua payBack 签名结果" + md5 + "|" + sign);
                LOG.error("chQzZzzhg_caohua sign error");
                json.put("code", 201);
                json.put("msg", "签名校验失败");
                return json.toJSONString();
            }

            String[] v = param.get("extra").split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = param.get("userid");
            payInfo.orderId = param.get("orderno");
            payInfo.childNo = super.getPlatNo();
            payInfo.serialId = param.get("orderno_cp");
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(param.get("order_amt")) / 100;
            payInfo.amount = (int) (payInfo.realAmount);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("chQzZzzhg_caohua payBack 充值发货失败！！ " + code);
                json.put("code", 203);
                json.put("msg", "签名校验失败");
                return json.toJSONString();
            }
            json.put("code", 200);
            json.put("msg", "充值成功");
            return json.toJSONString();
        } catch (Exception e) {
            LOG.error("chQzZzzhg_caohua payBack 充值异常:" + e.getMessage());
            e.printStackTrace();
            json.put("code", 203);
            json.put("msg", "服务器异常");
            return json.toJSONString();
        }
    }


    private boolean verifyAccount(String platform_id, String ext_data) {
        try {
            LOG.error("chQzZzzhg_caohua verifyAccount 开始调用sidInfo接口");

            if (ext_data == null || ext_data.equals("")) {
                return true;
            }

            Map<String, String> param = new HashMap<>();
            param.put("app_id", appid);
            param.put("platform_id", platform_id);
            param.put("ext_data", ext_data);

            String azStr = ParamUtil.getAzStr(param);
            azStr += key;

            String sign = MD5.md5Digest(azStr).toUpperCase();

            LOG.error("chQzZzzhg_caohua verifyAccount 签名原文" + azStr);
            LOG.error("chQzZzzhg_caohua verifyAccount 签名结果" + sign);
            param.put("sign", sign);

            StringBuffer sb = new StringBuffer();
            Set<Map.Entry<String, String>> entries = param.entrySet();
            for (Map.Entry<String, String> e : entries) {
                sb.append(e.getKey());
                sb.append("=");
                sb.append(e.getValue());
                sb.append("&");
            }

            String result = HttpUtils.sentPost(veriry_url, sb.substring(0, sb.length() - 1));
            LOG.error("chQzZzzhg_caohua verifyAccount 响应结果" + result);// 结果也是一个json格式字符串
            com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(result);
            return jsonObject.containsKey("code") && jsonObject.getIntValue("code") == 200;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

}
