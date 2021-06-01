package com.account.plat.impl.muzhi;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Date;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.impl.muzhi1.Muzhi1Plat;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.util.Http;
import com.account.util.HttpHelper;
import com.account.util.LogUtil;
import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class MuzhiPlat extends PlatBase {
    // sdk server的接口地址
    // private static String serverUrl = "";

    // 游戏编号
    private static String AppID;

    public static String AppKey;

    private static String VERIRY_URL;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    // private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/muzhi/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        VERIRY_URL = properties.getProperty("VERIRY_URL");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
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
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        String userName = vParam[1];
        String sign = vParam[2];
        String timestamp = vParam.length == 4 ? vParam[3] : null;

        if (!verifyAccount(userId, userName, sign, timestamp)) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userId);
            account.setAccount(getPlatNo() + "_" + userId);
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

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay muzhi");
        LOG.error("pay muzhi 接收到的参数" + content);
        try {
            String contentParam = request.getParameter("content");
            String sign = request.getParameter("sign");
            contentParam = new String(Base64.decode(contentParam));
            LOG.error("pay muzhi content " + contentParam);

            String mysign = Rsa.getMD5(contentParam + "&key=" + AppKey);
            if (!mysign.equals(sign)) {
                String mysign739 = Rsa.getMD5(contentParam + "&key=" + Muzhi1Plat.AppKey);
                if (!mysign739.equals(sign)) {
                    LOG.error("muzhi 充值,签名验证失败 ");
                    return "success";
                }
            }


            String pay_no;
            String game_id;
            String cp_order_id;
            int amount;
            int payStatus;
            String user_id;

            JSONObject json = JSONObject.fromObject(contentParam);
            LOG.error("pay muzhi 订单参数]" + json);
            pay_no = json.getString("pay_no");

            game_id = json.getString("game_id");
            cp_order_id = json.getString("cp_order_id");

            amount = json.getInt("amount");
            payStatus = json.getInt("payStatus");
            user_id = json.getString("user_id");
//            if (!AppID.equals(game_id)) {
//                LOG.error("pay muzhi 充值回调错误！！gameid: " + game_id);
//                return "success";
//            }

            if (payStatus == 0) {

                String[] v = cp_order_id.split("_");

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = user_id;
                payInfo.orderId = pay_no;

                payInfo.serialId = cp_order_id;
                payInfo.serverId = Integer.valueOf(v[0]);
                payInfo.roleId = Long.valueOf(v[1]);
                payInfo.realAmount = Double.valueOf(amount) / 100.0;
                payInfo.amount = amount / 100;
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("pay muzhi 充值发货失败！！ " + code);
                } else {
                    LOG.error("pay muzhi 充值,发货成功");
                }
            } else {
                LOG.error("pay muzhi 充值,失败订单，跳过");
            }
        } catch (Exception e) {
            LOG.error("pay muzhi 充值异常！！ ");
            LOG.error("pay muzhi 充值异常:" + e.getMessage());
            e.printStackTrace();
        }

        return "success";
    }

    private boolean verifySgin(String signSource, String sign) {

        try {
            signSource = URLEncoder.encode(signSource, "utf-8");
            String signGenerate = Rsa.getMD5(signSource).toLowerCase();
            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + signGenerate);
            LOG.error("[签名传入]" + sign);
            return sign.equals(signGenerate);
        } catch (UnsupportedEncodingException e) {
            LOG.error("muzhi 用户验证异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }


    /**
     * 新的验证方式 兼容老方式
     *
     * @param userid
     * @param usename
     * @param sign
     * @param timestamp
     * @return boolean
     */
    private boolean verifyAccount(String userid, String usename, String sign, String timestamp) {

        String body = null;
        try {
            body = "userId=" + userid + "&gameId=" + AppID + "&sign=" + sign;

            if (timestamp != null) {
                body += "&timestamp=" + timestamp;
            }

            String result = HttpUtils.sentPost(VERIRY_URL, body);

            com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(result);
            return jsonObject.containsKey("result") && jsonObject.getBoolean("result");
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("muzhi 登录请求sdk验证异常！！ " + body);
            return false;
        }

//        if (timestamp == null) {
//            return verifyAccount(userid, usename, sign);
//        }
//        LOG.error("muzhi 开始调用新的sidInfo接口");
//        return verifySgin(userid + AppKey + timestamp, sign);
    }


    /**
     * 老验证方式
     *
     * @param userid
     * @param usename
     * @param sign
     * @return boolean
     */
    private boolean verifyAccount(String userid, String usename, String sign) {
        LOG.error("muzhi 开始调用老的sidInfo接口");
        // String signSource = usename + AppKey;// 组装签名原文
        // String signGenerate = Rsa.getMD5(signSource).toLowerCase();
        return verifySgin(usename + AppKey, sign);
//		try {
//			String signSource = usename + AppKey;
//			signSource = URLEncoder.encode(signSource, "utf-8");
//			String signGenerate = Rsa.getMD5(signSource).toLowerCase();
//
//			LOG.error("[签名原文]" + signSource);
//			LOG.error("[签名结果]" + signGenerate);
//			LOG.error("[签名传入]" + sign);
//
//			if (sign.equals(signGenerate)) {
//				return true;
//			}
//		} catch (UnsupportedEncodingException e) {
//			LOG.error("muzhi 用户验证异常:" + e.getMessage());
//			e.printStackTrace();
//		}
//
//		return false;
    }

    public static void main(String[] args) {
        String result = null;
        String body = null;
        try {
            body = "userId=" + 49101810 + "&gameId=" + 337 + "&sign=" + "48f47bce579c9c3163362a66ce453bd5";
//            body += "&timestamp=" + "1534746607648";
            result = HttpUtils.sentPost("http://gm.91muzhi.com:8080/sdk/outsideController/validateUserData.do", body);

            com.alibaba.fastjson.JSONObject jsonObject = com.alibaba.fastjson.JSONObject.parseObject(result);
            //LOG.error(result);
            //LOG.error(body);

            //LOG.error(jsonObject.containsKey("result") && jsonObject.getBoolean("result"));

        } catch (Exception e) {
            e.printStackTrace();
            //LOG.error("muzhi 登录请求sdk验证异常！！ " + body);
        }
    }
}
