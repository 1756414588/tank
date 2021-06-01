package com.account.plat.impl.downjoy;

import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import com.account.plat.impl.kaopu.MD5Util;
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
public class DownjoyPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;

    private static String APP_KEY = "";

    private static String PAY_KEY = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/downjoy/", "plat.properties");
        // if (properties != null) {
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
        PAY_KEY = properties.getProperty("PAY_KEY");
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

        String uid = vParam[0];
        String accessToken = vParam[1];
        if (!verifyAccount(uid, accessToken)) {
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
        Iterator<String> iterator = request.getParameterNames();
        LOG.error("pay downjoy");
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            LOG.error(paramName + ":" + request.getParameter(paramName));
        }
        LOG.error("[参数结束]");


        try {
            String result = request.getParameter("result");
            String money = request.getParameter("money");
            String order = request.getParameter("order");
            String mid = request.getParameter("mid");
            String time = request.getParameter("time");
            String ext = request.getParameter("ext");
            String signature = request.getParameter("signature");

            String cpOrder = request.getParameter("cpOrder");  // 新加参数

            if (!"1".equals(result)) {
                LOG.error("扣费不成功");
                return "failure";
            }
//			StringBuffer sb = new StringBuffer();
//			sb.append("result=").append(result).append("&");
//			sb.append("money:=").append(money).append("&");
//			sb.append("order=").append(order).append("&");
//			sb.append("mid=").append(mid).append("&");
//			sb.append("time=").append(time).append("&");
//			sb.append("ext=").append(ext).append("&");
//			sb.append("signature=").append(signature);
//			LOG.error("接收到参数:" + sb.toString());

            // order=xxxx&money=xxxx&mid=xxxx&time=xxxx&result=x&ext=xxx&key=xxxx
            String signSource;
            if (cpOrder == null) {  // 旧
                signSource = "order=" + order + "&money=" + money + "&mid="
                        + mid + "&time=" + time + "&result=" + result + "&ext="
                        + ext + "&key=" + PAY_KEY;
            } else { // 新
                signSource = "order=" + order + "&money=" + money + "&mid="
                        + mid + "&time=" + time + "&result=" + result
                        + "&cpOrder=" + cpOrder + "&ext=" + ext + "&key="
                        + PAY_KEY;
            }
            String orginSign = MD5.md5Digest(signSource);
            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + orginSign + " | " + signature);
            if (!orginSign.equals(signature)) {
                LOG.error("验签失败");
                return "failure";
            }
            String[] infos = ext.split("_");
            if (infos.length != 3) {
                return "failure";
            }
            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = mid;
            payInfo.orderId = order;

            payInfo.serialId = ext;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("返回充值成功");
            } else {
                LOG.error("返回充值失败" + code);
            }
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("支付异常:" + e.getMessage());
            return "failure";
        }
    }

    private boolean verifyAccount(String umid, String accessToken) {
        LOG.error("downjoy 开始调用sidInfo接口");

        // sig 加密规则：appId|appKey|token|umid
        String signSource = APP_ID + "|" + APP_KEY + "|" + accessToken + "|" + umid;// 组装签名原文
        String sign = MD5.md5Digest(signSource).toLowerCase();

        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        Map<String, String> parameter = new HashMap<>();
        parameter.put("appid", APP_ID);
        parameter.put("token", accessToken);
        parameter.put("umid", umid);
        parameter.put("sig", sign);
        String result = HttpUtils.sendGet(serverUrl, parameter);
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        try {
            JSONObject rsp = JSONObject.fromObject(result);
            long msg_code = rsp.getLong("msg_code");
            String msg_desc = rsp.getString("msg_desc");
            int valid = rsp.getInt("valid");
            // int interval = rsp.getInt("interval");
            // int times = rsp.getInt("times");
            // boolean roll = rsp.getBoolean("roll");

            if (msg_code == 2000L && valid == 1) {
                return true;
            }

            LOG.error("downjoy 登陆失败:" + msg_desc);
            return false;

        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常:" + e.getMessage());
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

    @Override
    public String order(WebRequest request, String content) {

        try {
            LOG.error("downjoy order content=" + content);

            HashMap<String, String> params = new HashMap<String, String>();
            String k, v;
            Iterator<String> iterator = request.getParameterMap().keySet().iterator();
            while (iterator.hasNext()) {
                k = iterator.next();
                String arr[] = request.getParameterMap().get(k);
                v = (String) arr[0];
                params.put(k, v);
                LOG.error("downjoy order " + k + "=" + v);
            }
            LOG.error("downjoy order 参数结束");

            //MD5(cpOrder|ext|money|roleId|umid|)

            String money = String.format("%.2f", Float.valueOf(params.get("money")));
            String md5Str = params.get("cpOrder") + "|" + params.get("ext") + "|" + money + "|" + params.get("roleId") + "|" + params.get("umid") + "|" + "xfdadd2tumUe";

            String md5 = MD5Util.toMD5(md5Str);
            LOG.error("downjoy order md5Str=" + md5Str + " md5=" + md5);
            return md5;
        } catch (Exception e) {
            e.printStackTrace();
            return "null";
        }
    }

    public static void main(String[] s) {

        //LOG.error(String.format("%.2f", 10.0));

    }
}
