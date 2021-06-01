package com.account.plat.impl.yoyou;

import java.net.URLDecoder;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
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
import com.account.util.RandomHelper;
import com.account.util.StringHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

import net.sf.json.JSONObject;

@Component
public class YoyouPlat extends PlatBase {
    // sdk server的接口地址
    private static String VERIRY_URL;

    // 游戏编号
    private static String AppId;

    private static String AppKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/yoyou/", "plat.properties");
        AppId = properties.getProperty("AppId");
        AppKey = properties.getProperty("AppKey");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
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
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        if (!verifyAccount(userId, vParam[1])) {
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

    /**
     * 用户登录验证
     *
     * @param userId
     * @param sessionid
     * @return
     */
    private boolean verifyAccount(String userId, String sessionid) {
        LOG.error("youyou 开始调用sidInfo接口");

        String signSource = "appId=" + AppId + "&sessionid=" + sessionid + "&userid=" + userId + AppKey;// 组装签名原文
        String sign = md5(signSource.getBytes());
        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        String url = VERIRY_URL + "?appId=" + AppId + "&sessionid=" + sessionid + "&userid=" + userId + "&sign=" + sign;
        LOG.error("[请求url]" + url);

        String result = HttpUtils.sendGet(url, new HashMap<String, String>());
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        result = StringHelper.replaceBlank(result);
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            int ret = rsp.getInt("result");
            String msg = rsp.getString("error");
            LOG.error("[ret][msg]" + ret + " " + msg);
            if (ret == 1) {
                LOG.error("youyou 登录验证成功");
                return true;
            } else {
                LOG.error("youyou 登录验证失败, msg:" + msg);
                return false;
            }
        } catch (Exception e) {
            LOG.error("youyou 接口返回异常" + e.getMessage());
            return false;
        } finally {
            LOG.error("youyou 调用sidInfo接口结束");
        }
    }

    /**
     * 支付回调
     */
    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay youyou 支付回调");
        LOG.error("pay youyou content:" + content);
        LOG.error("[开始参数]");
        try {
            Iterator<String> iterator = request.getParameterNames();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + request.getParameter(paramName));
            }
            LOG.error("[结束参数]");

            content = URLDecoder.decode(content, "UTF-8").replace("=", " ");

            if (content.indexOf("&") >= 0) {
                String[] strs = content.split("&");
                for (String str : strs) {
                    if (!str.contains("plat")) {
                        content = str;
                    }
                }
            }

            content = content.substring(content.indexOf("&") + 1);

            LOG.error("content:" + content);

            JSONObject json = JSONObject.fromObject(content);
            String username = json.getString("username");
            String userid = json.getString("userid");
            String body = json.getString("body");
            String fee = json.getString("fee");
            String subject = json.getString("subject");
            String appId = json.getString("appId");
            String trade_sn = json.getString("trade_sn");
            String orderId = json.getString("orderId");
            String status = json.getString("status");
            String createTime = json.getString("createTime");
            String sign = json.getString("sign");

            Map<String, String> params = new HashMap<String, String>();
            params.put("username", username);
            params.put("userid", userid);
            params.put("body", body);
            params.put("fee", fee);
            params.put("subject", subject);
            params.put("appId", appId);
            params.put("trade_sn", trade_sn);
            params.put("orderId", orderId);
            params.put("status", status);
            params.put("createTime", createTime);
            // 排序key值
            List<String> keys = new ArrayList<String>(params.keySet());
            Collections.sort(keys);
            String signstr = "";
            for (int i = 0; i < keys.size(); i++) {
                String k = keys.get(i);
                String v = params.get(k);
                if ("sign".equals(k) || "sign_type".equals(k) || "".equals(v)) {
                    continue;
                }
                signstr = signstr + k + "=" + v + "&";
            }

            signstr = signstr.substring(0, signstr.lastIndexOf("&"));

            signstr = signstr + AppKey;
            LOG.error("signstr:" + signstr);
            String checkSign = md5(signstr.getBytes("UTF-8"));
            LOG.error("checkSign:" + checkSign);
            LOG.error("sign:" + sign);

            if (!checkSign.equals(sign)) {
                LOG.error("youyou sign error");
                return "fail";
            }

            String[] v = orderId.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = userid;
            payInfo.orderId = trade_sn;

            payInfo.serialId = orderId;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(fee);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("youyou 充值发货失败！！ " + code);
                return "fail";
            }
            LOG.error("youyou 充值发货成功！！ " + code);
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("youyou 充值异常！！" + e.getMessage());
            return "fail";
        } finally {
            LOG.error("youyou 调用充值回调接口结束");
        }
    }

    public static String md5(byte[] source) {
        String s = null;
        char hexDigits[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};// 用来将字节转换成16进制表示的字符
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            md.update(source);
            byte tmp[] = md.digest();// MD5 的计算结果是一个 128 位的长整数，
            // 用字节表示就是 16 个字节
            char str[] = new char[16 * 2];// 每个字节用 16 进制表示的话，使用两个字符， 所以表示成 16
            // 进制需要 32 个字符
            int k = 0;// 表示转换结果中对应的字符位置
            for (int i = 0; i < 16; i++) {// 从第一个字节开始，对 MD5 的每一个字节// 转换成 16
                // 进制字符的转换
                byte byte0 = tmp[i];// 取第 i 个字节
                str[k++] = hexDigits[byte0 >>> 4 & 0xf];// 取字节中高 4 位的数字转换,// >>>
                // 为逻辑右移，将符号位一起右移
                str[k++] = hexDigits[byte0 & 0xf];// 取字节中低 4 位的数字转换

            }
            s = new String(str);// 换后的结果转换为字符串

        } catch (NoSuchAlgorithmException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return s;
    }
}
