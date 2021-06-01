package com.account.plat.impl.qbao;

import java.util.Date;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class QbaoPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String APP_ID;
    // 游戏编号
    private static String APP_KEY;

    // 分配给游戏合作商的接入密钥,请做好安全保密
    private static String SecretKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/wan/", "plat.properties");
        APP_ID = properties.getProperty("APP_ID");
        APP_KEY = properties.getProperty("APP_KEY");
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

        String[] vParam = sid.split("_");
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }

        String accessToken = vParam[0];
        String gid = vParam[1];
        String pid = vParam[2];

        JSONObject rets = verifyAccount(pid, gid, accessToken);
        if (rets == null || !rets.containsKey("uid")) {
            return GameError.SDK_LOGIN;
        }

        String uid = rets.getString("uid");

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
        String signSource = APP_ID + String.valueOf(ResultCode) + SecretKey;
        String Sign = MD5.md5Digest(signSource);

        JSONObject res = new JSONObject();
        res.put("AppID", APP_ID);
        res.put("ResultCode", ResultCode);
        res.put("ResultMsg", "");
        res.put("Sign", Sign);
        return res;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
//		LOG.error("pay 37wan");
        JSONObject rets = new JSONObject();
//		LOG.error("[接收到的参数]" + content);
//		try {
//			String responseCode = request.getParameter("responseCode");
//			String errorCode = request.getParameter("errorCode");
//			String errorMsg = request.getParameter("errorMsg");
//			String data = request.getParameter("data");
//			String signCode = request.getParameter("signCode");
//			String doid = request.getParameter("doid");
//			String dsid = request.getParameter("dsid");
//
//			String dext = request.getParameter("dext");
//			String drid = request.getParameter("drid");
//			String drname = request.getParameter("drname");
//			String drlevel = request.getParameter("drlevel");
//			String uid = request.getParameter("uid");
//			String money = request.getParameter("money");
//			String coin = request.getParameter("coin");
//			String remark = request.getParameter("remark");
//			String paid = request.getParameter("paid");
//
//			String signNation = time + SecretKey + oid + doid + dsid + uid + money + coin;
//			String toSign = MD5.md5Digest(signNation).toLowerCase();
//			LOG.error("[签名原文]" + signNation);
//			LOG.error("[签名结果]" + sign + "|" + toSign);
//
//			if (!sign.equals(toSign)) {
//				rets.put("state", 0);
//				rets.put("data", "");
//				rets.put("msg", "签名错误");
//				return rets.toString();
//			}
//			String[] infos = dext.split("_");
//			if (infos.length != 3) {
//				rets.put("state", 0);
//				rets.put("data", "");
//				rets.put("msg", "缺少参数");
//				return rets.toString();
//			}
//
//			int serverid = Integer.valueOf(infos[0]);
//			Long lordId = Long.valueOf(infos[1]);
//
//			PayInfo payInfo = new PayInfo();
//			payInfo.platNo = getPlatNo();
//			payInfo.platId = uid;
//			payInfo.orderId = oid;
//
//			payInfo.serialId = dext;
//			payInfo.serverId = serverid;
//			payInfo.roleId = lordId;
//			payInfo.amount = Double.valueOf(money).intValue();
//			int code = payToGameServer(payInfo);
//			if (code != 0) {
//				rets.put("state", 0);
//				rets.put("data", "");
//				rets.put("msg", "失败");
//				return rets.toString();
//			}
//		} catch (Exception e) {
//			e.printStackTrace();
//			rets.put("state", 0);
//			rets.put("data", "");
//			rets.put("msg", "缺少参数");
//			return rets.toString();
//		}
//		rets.put("state", 1);
//		rets.put("data", "");
//		rets.put("msg", "成功");
        return rets.toString();
    }

    private JSONObject verifyAccount(String userId, String gid, String token) {
        LOG.error("Qbao 开始调用sidInfo接口");

        long time = System.currentTimeMillis() / 1000;
        String signSource = gid + time + APP_KEY;// 组装签名原文
        String sign = MD5.md5Digest(signSource).toLowerCase();
        LOG.error("[签名原文]" + signSource);
        LOG.error("[签名结果]" + sign);
        // Map<String, String> param = new HashMap<String, String>();
        // param.put("pid", pid);
        // param.put("gid", gid);
        // param.put("time", String.valueOf(time));
        // param.put("token", token);
        // param.put("sign", sign);

        String url = serverUrl + "/verify/token";
        String body = "userId=" + userId + "&gid=" + gid + "&time=" + time + "&token=" + token + "&sign=" + sign;

        LOG.error("[请求地址]" + url);
        LOG.error("[请求参数]" + body);

        String result = HttpHelper.doGet(url + "?" + body);
        // post方式调用服务器接口,请求的body内容是参数json格式字符串
        LOG.error("[响应结果]" + result);// 结果也是一个json格式字符串

        int code = 0;
        String resultMsg;
        JSONObject data;
        try {
            JSONObject rsp = JSONObject.fromObject(result);
            code = rsp.getInt("state");
            data = rsp.getJSONObject("data");
            resultMsg = rsp.getString("msg");
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return null;
        }

        LOG.error("调用sidInfo接口结束");
        if (code == 1) {
            LOG.error("37wan登陆成功:" + token);
            return data;
        } else {
            LOG.error("37wan登陆失败:" + code + " 原因:" + resultMsg);
            return null;
        }
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    public String doLogin(WebRequest request, String content) {
        return "";
    }
}
