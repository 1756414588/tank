package com.account.plat.impl.baiducl;

import java.util.Date;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.apache.commons.codec.binary.Base64;
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

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class BaiduclPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static int AppID;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/baiducl/", "plat.properties");
        AppID = Integer.valueOf(properties.getProperty("AppID"));
        SecretKey = properties.getProperty("SecretKey");
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

        String[] vParam = sid.split("&");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String accessToken = vParam[0];
        String uid = vParam[1];

        if (!verifyAccount(accessToken)) {
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

    private JSONObject packResponse(int ResultCode) {
        // MD5(AppID+ResultCode+SecretKey)
        String signSource = AppID + String.valueOf(ResultCode) + SecretKey;
        String Sign = MD5.md5Digest(signSource);

        JSONObject res = new JSONObject();
        res.put("AppID", AppID);
        res.put("ResultCode", ResultCode);
        res.put("ResultMsg", "");
        res.put("Sign", Sign);
        return res;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay baiducl");
        LOG.error("[接收到的参数]" + content);
        try {
            String AppID = request.getParameter("AppID");
            String OrderSerial = request.getParameter("OrderSerial");
            String CooperatorOrderSerial = request.getParameter("CooperatorOrderSerial");
            String Sign = request.getParameter("Sign");
            String conString = request.getParameter("Content");

            // String jsonStr = Base64.decode(URLDecoder.decode(conString,
            // "UTF-8"));
            // String jsonStr = Base64.decode(conString);
            // String jsonStr = Base64.decode(conString);
            String jsonStr = new String(Base64.decodeBase64(conString));
            LOG.error("jsonstr:" + jsonStr);
            JSONObject Content = JSONObject.fromObject(jsonStr);
            String UID = Content.getString("UID");
            double OrderMoney = Content.getDouble("OrderMoney");
            // String StartDateTime = Content.getString("StartDateTime");
            // String BankDateTime = Content.getString("BankDateTime");
            int OrderStatus = Content.getInt("OrderStatus");
            // String StatusMsg = Content.getString("StatusMsg");
            // int VoucherMoney = Content.getInt("VoucherMoney");
            String ExtInfo = Content.getString("ExtInfo");

            if (1 != OrderStatus) {
                LOG.error("OrderStatus failed");
                return packResponse(1).toString();
            }

            // MD5(AppID+OrderSerial+CooperatorOrderSerial+Content+SecretKey)
            String signSource = AppID + OrderSerial + CooperatorOrderSerial + conString + SecretKey;
            String orginSign = MD5.md5Digest(signSource);

            LOG.error("签名：" + orginSign + " | " + Sign);
            if (orginSign.equals(Sign)) {
                String[] infos = ExtInfo.split("_");
                if (infos.length != 3) {
                    LOG.error("自有参数不正确");
                    return packResponse(1).toString();
                }

                int serverid = Integer.valueOf(infos[0]);
                Long lordId = Long.valueOf(infos[1]);
                // int rechargeId = Integer.valueOf(infos[2]);
                // String exorderno = infos[3];

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = UID;
                payInfo.orderId = OrderSerial;

                payInfo.serialId = ExtInfo;
                payInfo.serverId = serverid;
                payInfo.roleId = lordId;
                payInfo.realAmount = OrderMoney;
                payInfo.amount = (int) OrderMoney;
                int code = payToGameServer(payInfo);

                if (code != 0) {
                    LOG.error("baiducl 充值发货失败！！ " + code);
                }
                return packResponse(1).toString();
            } else {
                return packResponse(0).toString();
            }
        } catch (Exception e) {
            LOG.error("baiducl 充值异常:" + e.getMessage());
            e.printStackTrace();
            return packResponse(1).toString();
        }
    }

    private boolean verifyAccount(String accessToken) {
        LOG.error("baidu 开始调用sidInfo接口");

        String signSource = AppID + accessToken + SecretKey;// 组装签名原文
        String sign = MD5.md5Digest(signSource).toLowerCase();
        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);

        String body = "AppID=" + AppID + "&AccessToken=" + accessToken + "&Sign=" + sign;
        LOG.error("[请求参数]" + body);

        String result = HttpUtils.sentPost(serverUrl, body);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        int code = 0;
        String resultMsg;
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            code = rsp.getInt("ResultCode");
            resultMsg = rsp.getString("ResultMsg");
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        }

        LOG.error("调用sidInfo接口结束");
        if (code == 1) {
            LOG.error("baidu登陆成功:" + accessToken);
            return true;
        } else {
            LOG.error("baidu登陆失败:" + code + " 原因:" + resultMsg);
            return false;
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

	 /*public static void main(String[] args){
		LOG.error("baidu 开始调用sidInfo接口");
		String accessToken = "kf_53517bc7fd22a985da9299709f1f9152";
		String SecretKey = "1oXWqbGRxBoLeez0OEsXvEahyGqguzyI";
		String serverUrl = "http://querysdkapi.baidu.com/query/cploginstatequery";
		String AppID = "8362050";

		String signSource = AppID + accessToken + SecretKey;// 组装签名原文
		String sign = MD5.md5Digest(signSource).toLowerCase();
		LOG.error("[签名原文]" + signSource);
		LOG.error("[签名结果]" + sign);

		String body = "AppID=" + AppID + "&AccessToken=" + accessToken + "&Sign=" + sign;
		LOG.error("[请求参数]" + body);

		String result = HttpUtils.sentPost(serverUrl, body);
		// post方式调用服务器接口,请求的body内容是参数json格式字符串
		LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

		int code = 0;
		String resultMsg;
		try {
			JSONObject rsp = JSONObject.fromObject(result);
			code = rsp.getInt("ResultCode");
			resultMsg = rsp.getString("ResultMsg");
		} catch (Exception e) {
			// TODO: handle exception
			LOG.error("接口返回异常");
			e.printStackTrace();
			// return false;
		}

	}*/
}
