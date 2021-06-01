package com.account.plat.impl.chJh_hjfc;

import java.net.URLDecoder;
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

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

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

@Component
public class ChjhHjfcPlat extends PlatBase {

	// sdk 登录验证地址 的接口地址
	private static String serverUrl = "";

	// 游戏编号
	private static int AppID;

	// 支付回调 签名 用
	private static String AppSecret = "";

	// 登录 签名用
	private static String appKey = "";

	@PostConstruct
	public void init() {
		Properties properties = loadProperties("com/account/plat/impl/chJh_hjfc/", "plat.properties");
		serverUrl = properties.getProperty("VERIRY_URL");// 签名验证地址
		AppID = Integer.valueOf(properties.getProperty("AppID"));
		AppSecret = properties.getProperty("AppSecret");
		appKey = properties.getProperty("App_key");

	}

	@Override
	public int getPlatNo() {
		return 194;
	}

	@Override
	public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
		try {
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

			// String userName = vParam[0];
			String uid = vParam[1];
			String accessToken = vParam[2];

			if (!verifyAccount(accessToken, uid)) {
				return GameError.SDK_LOGIN;
			}

			Account account = accountDao.selectByPlatId(getPlatNo(), uid);

			if (account == null) {
				String token = RandomHelper.generateToken();
				account = new Account();
				account.setPlatNo(this.getPlatNo());
				account.setChildNo(super.getPlatNo());
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
		} catch (Exception e) {
			LOG.error("chyh_hjfc 登录异常={}", e.getMessage());
			return GameError.PARAM_ERROR;
		}
	}

	private JSONObject packResponse(int ResultCode) {
		String signSource = AppID + String.valueOf(ResultCode) + AppSecret;
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
		JSONObject result = new JSONObject();
		try {
			Iterator<String> iterator = request.getParameterNames();
			Map<String, String> params = new HashMap<String, String>();
			while (iterator.hasNext()) {
				String paramName = iterator.next();
				LOG.error("chyh_hjfcPlat ={}", paramName + ":" + request.getParameter(paramName));
				params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
			}
			LOG.error("chyh_hjfcPlat 参数结束");
			List<String> list = new ArrayList<>();
			list.add("orderno");
			list.add("orderno_cp");
			list.add("userid");
			list.add("order_amt");
			list.add("pay_amt");
			list.add("pay_time");
			list.add("extra");
			Collections.sort(list);
			StringBuilder sb = new StringBuilder();
			for (String str : list) {
				sb.append(str);
				sb.append("=");
				sb.append(params.get(str));
				sb.append("&");
			}
			String md5Str = sb.toString().substring(0, sb.toString().length() - 1) + AppSecret;
			String toMD5 = MD5Util.toMD5(md5Str).toUpperCase();
			LOG.error("chyh_hjfc md5str =" + sb.toString() + " md5val=" + toMD5);
			if (!toMD5.equals(params.get("sign"))) {
				LOG.error("chyh_hjfc md5str ={},md5val={}", sb.toString(), toMD5);
				result.put("code", 202);
				result.put("msg", "签名校验失败 " + toMD5);
				return result.toString();
			}
			String orderno_cp = params.get("orderno_cp");
			String[] infos = orderno_cp.split("_");
			if (infos.length < 3) {
				result.put("code", 201);
				result.put("msg", "游戏订单错误");
				return result.toString();
			}
			int serverId = Integer.valueOf(infos[0]);
			Long lordId = Long.valueOf(infos[1]);
			PayInfo payInfo = new PayInfo();
			payInfo.platNo = getPlatNo();
			payInfo.childNo = super.getPlatNo();
			payInfo.serialId = orderno_cp;
			payInfo.platId = params.get("userid");
			payInfo.orderId = params.get("orderno");
			payInfo.serverId = serverId;
			payInfo.roleId = lordId;
			payInfo.realAmount = Integer.valueOf(params.get("pay_amt")) / 100.0;
			payInfo.amount = Integer.valueOf(params.get("order_amt")) / 100;
			int code = payToGameServer(payInfo);
			if (code == 1) {
				result.put("code", 200);
				result.put("msg", "成功");
				return result.toString();
			}
			LOG.info("chyh_hjfc 充值发货成功 ");
			result.put("code", 200);
			result.put("msg", "成功");
			return result.toString();

		} catch (Exception e) {
			LOG.error("chJh_hjfc 充值异常 = {}", e.getMessage());
			return packResponse(1).toString();
		}
	}

	private boolean verifyAccount(String accessToken, String uid) {
		LOG.info("chyh_hjfc 开始调用sidInfo接口");
		long time = System.currentTimeMillis();
		String signSource = "appid=" + AppID + "&times=" + time + "&token=" + accessToken + "&userid=" + uid + appKey;
		String sign = MD5.md5Digest(signSource).toUpperCase();// 签名原文
		String body = "appid=" + AppID + "&times=" + time + "&token=" + accessToken + "&userid=" + uid + "&sign=" + sign;
		LOG.info("chJh_hjfc 请求参数= {}", body);
		String result = HttpUtils.sentPost(serverUrl, body);
		LOG.info("chJh_hjfc 响应结果= {}", result);
		int code = 0;
		String resultMsg;
		try {
			JSONObject rsp = JSONObject.fromObject(result);
			code = rsp.getInt("code");
			resultMsg = rsp.getString("msg");
		} catch (Exception e) {
			LOG.error("接口返回异常={}", e.getMessage());
			return false;
		}
		LOG.info("调用sidInfo接口结束");
		if (code == 200) {
			LOG.info("chJh_hjfc登陆成功={}", accessToken);
			return true;
		} else {
			LOG.error("chJh_hjfc登陆失败={},原因={}", code, resultMsg);
			return false;
		}
	}

	@Override
	public GameError doLogin(JSONObject param, JSONObject response) {
		return GameError.OK;
	}

}
