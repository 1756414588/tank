package com.account.plat.impl.chQzZzzhg_xiaoqi;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.muzhi.Rsa;
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
public class ChQzZzzhgXiaoQiPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String AppKey = "";

    private static String PublicKey = "";

    public static String getPublicKey() {
        return PublicKey;
    }

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzZzzhg_xiaoqi/", "plat.properties");
        serverUrl = properties.getProperty("VERIRY_URL");
        AppKey = properties.getProperty("AppKey");
        PublicKey = properties.getProperty("PublicKey");
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

        String uid = verifyAccount(sid);
        if (uid == null) {
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
        response.setUserInfo(uid);
        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.SDK_LOGIN;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("chQzZzzhg_xiaoqi pay");
        LOG.error("chQzZzzhg_xiaoqi pay content:" + content);
        Map<String, String> params = new TreeMap<String, String>();
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                params.put(paramName, request.getParameter(paramName));
                LOG.error("chQzZzzhg_xiaoqi " + paramName + ":" + request.getParameter(paramName));
            }
            LOG.error("chQzZzzhg_xiaoqi [结束参数]");

            String sign = params.get("sign_data");
            params.remove("sign_data");
            params.remove("plat");

            Map<String, String> decryptMap = VerifyTest.check(params, sign, PublicKey);

            if (decryptMap == null) {
                String verify = VerifyNew.verify(params, sign);

                if (verify != null) {
                    LOG.error("chQzZzzhg_xiaoqi 验签失败");
                    return "failed";
                }

                decryptMap = VerifyNew.decode(params);
                if (decryptMap == null) {
                    LOG.error("chQzZzzhg_xiaoqi 解析数据失败");
                    return "failed:encryp_data_decrypt_failed";
                }
            }

            if (decryptMap.containsKey("payflag") && !decryptMap.get("payflag").equals("1")) {
                LOG.error("chQzZzzhg_xiaoqi payflag 错误");
                return "failed";
            }

            String cp_orderId = params.get("game_orderid");
            String platId = params.get("guid");

            if (platId == null) {
                platId = decryptMap.get("guid");
            }

            String orderId = params.get("xiao7_goid");
            String realAmount = decryptMap.get("pay");
            if (realAmount == null) {
                realAmount = decryptMap.get("pay_price");
            }


            String infos[] = cp_orderId.split("_");
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = platId;
            payInfo.orderId = orderId;
            payInfo.serialId = cp_orderId;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(realAmount);
            payInfo.amount = (int) payInfo.realAmount;
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("chQzZzzhg_xiaoqi 返回充值成功");
            } else {
                LOG.error("chQzZzzhg_xiaoqi 返回充值失败");
            }
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "success";
    }

    private String verifyAccount(String tokenkey) {
        LOG.error("chQzZzzhg_xiaoqi 开始调用sidInfo接口");

        String signStr = AppKey + tokenkey;
        LOG.error("chQzZzzhg_xiaoqi 签名原串" + signStr);
        String sign = MD5.md5Digest(signStr);
        LOG.error("chQzZzzhg_xiaoqi 签名结果" + sign);
        String url = serverUrl + "?" + "tokenkey=" + tokenkey + "&sign=" + sign;
        LOG.error("chQzZzzhg_xiaoqi 验证地址" + url);

        try {
            String result = HttpUtils.sendGet(url, new HashMap<String, String>());
            LOG.error("chQzZzzhg_xiaoqi 响应结果" + result);
            JSONObject rsp = JSONObject.fromObject(result);
            if (rsp.getString("errorno").equals("0")) {
                JSONObject data = rsp.getJSONObject("data");
                return data.getString("guid");
            }
            return null;
        } catch (Exception e) {
            LOG.error("chQzZzzhg_xiaoqi 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return null;
        }

    }

    @Override
    public String order(WebRequest request, String content) {
        LOG.error("chQzZzzhg_xiaoqi 获取订单");

        Map<String, String> params = new TreeMap<String, String>();

        Iterator<String> iterator = request.getParameterNames();
        while (iterator.hasNext()) {
            String paramName = iterator.next();

            if ("plat".equals(paramName)) {
                continue;
            }

            params.put(paramName, request.getParameter(paramName));
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }
        LOG.error("结束参数");

        if (params.size() == 0) {
            return "param is null";
        }

        List<String> param = new ArrayList();
        for (String patam : params.keySet()) {
            param.add(patam);
        }
        Collections.sort(param);

        LOG.error("chQzZzzhg_xiaoqi getXiao7GameSign param  " + JSON.toJSONString(params));

        StringBuilder sb = new StringBuilder();
        for (String str : param) {
            sb.append(str);
            sb.append("=");
            sb.append(params.get(str));
            sb.append("&");
        }
        String md5str = sb.substring(0, sb.length() - 1) + PublicKey;
        String mysign = Rsa.getMD5(md5str);
        LOG.error("chQzZzzhg_xiaoqi getXiao7GameSign md5Str " + md5str);
        LOG.error("chQzZzzhg_xiaoqi getXiao7GameSign md5v " + mysign);
        return mysign;
    }
}
