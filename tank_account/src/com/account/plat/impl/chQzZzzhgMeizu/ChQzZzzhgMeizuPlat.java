package com.account.plat.impl.chQzZzzhgMeizu;

import java.util.*;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

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

import net.sf.json.JSONObject;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
@Component
public class ChQzZzzhgMeizuPlat extends PlatBase {

    private static String ServerUrl = "";
    private static String AppId = "";
    private static String Secret = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzZzzhgMeizu/", "plat.properties");
        ServerUrl = properties.getProperty("ServerUrl");
        AppId = properties.getProperty("AppId");
        Secret = properties.getProperty("Secret");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK; // GameError.INVALID_PARAM
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("ChQzZzzhg_360Plat GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();
        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            LOG.error("vParam.length:" + vParam.length);
            return GameError.PARAM_ERROR;
        }

        String uid = vParam[0];
        String session = vParam[1];

        boolean backboolean = verifyAccount(session, uid);
        if (!backboolean) {
            LOG.error("GameError.SDK_LOGIN:" + GameError.SDK_LOGIN);
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
            LOG.error("authorityRs:" + authorityRs);
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

    private boolean verifyAccount(String session, String uid) {
        try {
            LOG.error("ChQzZzzhg_meizu 开始调用sidInfo接口");

            String url = ServerUrl;

            LOG.error("ChQzZzzhg_meizu 账号验证请求url=" + url);

            String ts = System.currentTimeMillis() + "";

            String msg = "app_id=" + AppId + "&session_id=" + session + "&ts=" + ts + "&uid="
                    + uid + ":" + Secret;

            String sign = MD5.md5Digest(msg);

            LOG.error("ChQzZzzhg_meizu 账号验证签名内容 " + sign);

            String content = "app_id=" + AppId + "&session_id=" + session + "&sign=" + sign + "&sign_type=md5" + "&ts="
                    + ts + "&uid=" + uid;

            LOG.error("ChQzZzzhg_meizu 账号验证请求参数 " + content);

            String result = HttpUtils.sentPost(url, content);

            LOG.error("ChQzZzzhg_meizu 账号验证响应结果 " + result);

            JSONObject jsonObject = JSONObject.fromObject(result);

            if (!"200".equals(jsonObject.getString("code"))) {
                LOG.error("ChQzZzzhg_meizu 登陆失败");
                return false;
            } else {
                LOG.error("ChQzZzzhg_meizu 登陆成功");
                return true;
            }
        } catch (Exception e) {
            LOG.error("ChQzZzzhg_meizu 接口返回异常 " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("ChQzZzzhg_meizu payBack开始  content= " + content);

        com.alibaba.fastjson.JSONObject json = new com.alibaba.fastjson.JSONObject();

        String tarde_status = request.getParameter("trade_status");
        if (!"3".equals(tarde_status)) {
            json.put("code", "120014");
            json.put("message", "尚未支付或支付不成功");
            return json.toJSONString();
        }

        try {
            List<String> paramNames = new ArrayList<>();
            Iterator<String> it = request.getParameterNames();
            LOG.error("ChQzZzzhg_meizu 支付回调请求参数信息打印开始 ");
            while (it.hasNext()) {
                String paramName = it.next();
                LOG.error("ChQzZzzhg_meizu param " + paramName + "=" + request.getParameter(paramName));
                if ("sign_type".equals(paramName) || "sign".equals(paramName) || "plat".equals(paramName)) {
                    continue;
                }
                paramNames.add(paramName);
            }
            LOG.error("ChQzZzzhg_meizu 支付回调请求参数信息打印结束 ");

            Collections.sort(paramNames);
            StringBuilder sb = new StringBuilder();
            for (String paramName : paramNames) {
                sb.append(paramName + "=" + request.getParameter(paramName) + "&");
            }

            sb.deleteCharAt(sb.length() - 1);
            sb.append(":" + Secret);

            LOG.error("ChQzZzzhg_meizu 参与签名的字符串 " + sb);

            String checkSign = MD5.md5Digest(sb.toString());
            LOG.error("ChQzZzzhg_meizu 加密后的签名串  " + checkSign);

            String sign = request.getParameter("sign");
            LOG.error("ChQzZzzhg_meizu 接收到的签名串  " + sign);

            if (!checkSign.equalsIgnoreCase(sign)) {
                LOG.error("ChQzZzzhg_meizu 充值发货失败！！md5 验证不通过 ");
                json.put("code", "120014");
                json.put("message", "md5签名验证失败");
                return json.toJSONString();
            }

            PayInfo payInfo = new PayInfo();
            // 游戏内部渠道号
            payInfo.platNo = getPlatNo();
            // 渠道订单号
            payInfo.orderId = request.getParameter("order_id");
            // 付费金额
            payInfo.amount = Float.valueOf(request.getParameter("total_price")).intValue();
            payInfo.realAmount = payInfo.amount;

            String[] param = request.getParameter("cp_order_id").split("_");
            String serverid = param[0];
            String roleid = param[1];

            // 游戏内部订单号
            payInfo.serialId = request.getParameter("cp_order_id");
            // 渠道id
            payInfo.platId = request.getParameter("uid");
            // 游戏区号
            payInfo.serverId = Integer.valueOf(serverid);
            // 玩家角色id
            payInfo.roleId = Long.valueOf(roleid);

            int code = payToGameServer(payInfo);
            if (code == 0 || code == 1) {
                LOG.error("ChQzZzzhg_meizu 充值发货成功！！ " + code);
                json.put("code", "200");
            } else {
                LOG.error("ChQzZzzhg_meizu 充值发货失败！！ " + code);
                json.put("code", "120014");
                json.put("message", "服务器未通过验证");
            }

            return json.toString();

        } catch (Exception e) {
            LOG.error("ChQzZzzhg_meizu 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            json.put("code", "900000");
            json.put("message", "服务器发生异常");
            return json.toString();
        }
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
                LOG.error("ChQzZzzhg_meizu " + k + "=" + v);
            }
            LOG.error("参数结束");

            String sign = getSign(params, Secret);
            return packOrderResponse(0, sign).toString();
        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
            return packOrderResponse(1, "服务器异常").toString();
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

    private JSONObject packOrderResponse(int code, String sign) {
        JSONObject res = new JSONObject();
        res.put("code", code);
        res.put("sign", sign);
        return res;
    }

}
