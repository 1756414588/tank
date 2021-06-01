package com.account.plat.impl.chQzZzzhg360;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

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
public class ChQzZzzhg_360Plat extends PlatBase {
    private static String ServerUrl = "";
    private static String Secret = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzZzzhg360/", "plat.properties");
        ServerUrl = properties.getProperty("ServerUrl");
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

        String id = verifyAccount(sid);
        if (id == null) {
            LOG.error("GameError.SDK_LOGIN:" + GameError.SDK_LOGIN);
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), id);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setPlatId(id);
            account.setAccount(getPlatNo() + "_" + id);
            account.setPasswd(id);
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
        response.setUserInfo(id);

        if (isActive(account)) {
            response.setActive(1);

        } else {
            response.setActive(0);
        }
        return GameError.OK;
    }

    private String verifyAccount(String token) {
        try {
            LOG.error("ChQzZzzhg_360Plat 开始调用sidInfo接口");

            String url = ServerUrl + "?access_token=" + token;

            LOG.error("ChQzZzzhg_360Plat 请求url" + url);

            String result = HttpUtils.sendGet(url, new HashMap<String, String>());

            LOG.error("ChQzZzzhg_360Plat 响应结果" + result);

            JSONObject jsonObject = JSONObject.fromObject(result);

            if (jsonObject.containsKey("error_code")) {
                LOG.error("ChQzZzzhg_360Plat 登陆失败");
                return null;
            } else {
                LOG.error("ChQzZzzhg_360Plat 登陆成功 " + result);
                return jsonObject.getString("id");
            }
        } catch (Exception e) {
            LOG.error("ChQzZzzhg_360Plat 接口返回异常 " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("ChQzZzzhg_360Plat payBack开始 content=" + content);

        com.alibaba.fastjson.JSONObject json = new com.alibaba.fastjson.JSONObject();
        json.put("status", "error");
        json.put("delivery", "other");

        try {
            List<String> paramNames = new ArrayList<>();
            Iterator<String> it = request.getParameterNames();
            LOG.error("ChQzZzzhg_360Plat 支付回调请求参数信息打印开始");
            while (it.hasNext()) {
                String paramName = it.next();
                LOG.error("ChQzZzzhg_360Plat param" + paramName + ":" + request.getParameter(paramName));
                if ("sign_return".equals(paramName) || paramName.equals("plat") || "sign".equals(paramName)) {
                    continue;
                }
                paramNames.add(paramName);
            }
            LOG.error("ChQzZzzhg_360Plat 支付回调请求参数信息打印结束");

            Collections.sort(paramNames);
            StringBuilder sb = new StringBuilder();
            for (String paramName : paramNames) {
                sb.append(request.getParameter(paramName) + "#");
            }

            sb.append(Secret);
            LOG.error("ChQzZzzhg_360Plat 参与签名的字符串 " + sb.toString());

            String checkSign = MD5.md5Digest(sb.toString());
            LOG.error("ChQzZzzhg_360Plat 加密后的签名串 " + checkSign);

            String sign = request.getParameter("sign");
            LOG.error("ChQzZzzhg_360Plat 接收到的签名串 " + sign);

            if (!checkSign.equalsIgnoreCase(sign)) {
                LOG.error("ChQzZzzhg_360Plat 充值发货失败！！md5 验证不通过 ");
                json.put("delivery", "mismatch");
                json.put("msg", "md5签名验证失败");
                return json.toJSONString();
            }

            PayInfo payInfo = new PayInfo();
            // 游戏内部渠道号
            payInfo.platNo = getPlatNo();
            // 渠道订单号
            payInfo.orderId = request.getParameter("order_id");
            // 付费金额
            payInfo.realAmount = Float.valueOf(request.getParameter("amount")).intValue() / 100;
            payInfo.amount = (int) payInfo.realAmount;


            String[] param = request.getParameter("app_order_id").split("_");
            String serverid = param[0];
            String roleid = param[1];

            // 游戏内部订单号
            payInfo.serialId = request.getParameter("app_order_id");
            // 渠道id
            payInfo.platId = request.getParameter("app_uid");
            // 游戏区号
            payInfo.serverId = Integer.valueOf(serverid);
            // 玩家角色id
            payInfo.roleId = Long.valueOf(roleid);

            int code = payToGameServer(payInfo);
            if (code == 0 || code == 1) {
                LOG.error("ChQzZzzhg_360Plat 充值发货成功！！ " + code);
                json.put("status", "ok");
                json.put("delivery", "success");
                json.put("msg", "");
            } else {
                LOG.error("ChQzZzzhg_360Plat 充值发货失败！！ " + code);
                json.put("msg", "服务器未通过验证");
            }
            return json.toString();
        } catch (Exception e) {
            LOG.error("ChQzZzzhg_360Plat 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            json.put("msg", "服务器内部异常");
            return json.toString();
        }

    }
}
