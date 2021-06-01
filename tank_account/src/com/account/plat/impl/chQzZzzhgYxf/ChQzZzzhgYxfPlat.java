package com.account.plat.impl.chQzZzzhgYxf;

import java.util.Date;
import java.util.Iterator;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

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

import net.sf.json.JSONObject;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
@Component
public class ChQzZzzhgYxfPlat extends PlatBase {
    private static String AppKey = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chQzZzzhgYxf/", "plat.properties");
        AppKey = properties.getProperty("AppKey");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            LOG.error("ChQzZzzhgYxfPlat GameError.PARAM_ERROR");
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();
        String[] vParam = sid.split("&");
        if (vParam.length < 4) {
            LOG.error("ChQzZzzhgYxfPlat" + vParam.length);
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        String username = vParam[1];
        String logintime = vParam[2];
        String sign = vParam[3];

        Boolean back = verifyAccount(username, logintime, sign);
        if (!back) {
            LOG.error("GameError.SDK_LOGIN:" + GameError.SDK_LOGIN);
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

    private Boolean verifyAccount(String username, String logintime, String sign) {
        try {
            LOG.error("ChQzZzzhgYxfPlat 开始调用sidInfo接口");
            LOG.error("ChQzZzzhgYxfPlat 接收到的sign " + sign);
            String param = "username=" + username + "&appkey=" + AppKey + "&logintime=" + logintime;
            String checkSign = MD5.md5Digest(param);
            LOG.error("ChQzZzzhgYxfPlat 组装参数加密后的sign " + checkSign);

            if (!checkSign.equalsIgnoreCase(sign)) {
                LOG.error("ChQzZzzhgYxfPlat 登陆失败！！ md5 验证不通过 ");
                return false;
            }
            return true;
        } catch (Exception e) {
            LOG.error("ChQzZzzhgYxfPlat 接口返回异常 " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("ChQzZzzhgYxfPlat payBack开始 content=" + content);


        //220有异常充值 关闭掉

        return "error";


//		try {
//			Iterator<String> it = request.getParameterNames();
//			LOG.error("ChQzZzzhgYxfPlat payBack 支付回调参数信息打印开始");
//			while (it.hasNext()) {
//				String paramName = it.next();
//				LOG.error("ChQzZzzhgYxfPlat param " + paramName + "=" + request.getParameter(paramName));
//			}
//			LOG.error("ChQzZzzhgYxfPlat payBack 支付回调参数信息打印结束");
//
//			String[] order = new String[] { "orderid", "username", "gameid", "roleid", "serverid", "paytype", "amount",
//					"paytime", "attach" };
//
//			StringBuilder sb = new StringBuilder();
//			for (String paramName : order) {
//				sb.append(paramName + "=" + request.getParameter(paramName) + "&");
//			}
//
//			sb.append("appkey=" + AppKey);
//			LOG.error("ChQzZzzhgYxfPlat payBack 参与签名的字符串 " + sb.toString());
//
//			String checkSign = MD5.md5Digest(sb.toString());
//			LOG.error("ChQzZzzhgYxfPlat payBack 加密后的签名串 " + checkSign);
//
//			String sign = request.getParameter("sign");
//			LOG.error("ChQzZzzhgYxfPlat payBack 接收到的签名串 " + sign);
//
//			if (!checkSign.equalsIgnoreCase(sign)) {
//				LOG.error("ChQzZzzhgYxfPlat payBack 充值发货失败！！md5 验证不通过 ");
//				return "errorSign";
//			}
//
//			PayInfo payInfo = new PayInfo();
//			// 游戏内部渠道号
//			payInfo.platNo = getPlatNo();
//			// 渠道订单号
//			payInfo.orderId = request.getParameter("orderid");
//			// 付费金额
//			payInfo.amount = Float.valueOf(request.getParameter("amount")).intValue();
//			payInfo.realAmount = payInfo.amount;
//
//			String[] param = request.getParameter("attach").split("_");
//			String serverid = param[0];
//			String roleid = param[1];
//
//			// 游戏内部订单号
//			payInfo.serialId = request.getParameter("attach");
//			// 渠道id
//			payInfo.platId = request.getParameter("username");
//			// 游戏区号
//			payInfo.serverId = Integer.valueOf(serverid);
//			// 玩家角色id
//			payInfo.roleId = Long.valueOf(roleid);
//
//			int code = payToGameServer(payInfo);
//			if (code == 0 || code == 1) {
//				LOG.error("ChQzZzzhgYxfPlat payBack 充值发货成功！！ " + code);
//				return "success";
//			} else {
//				LOG.error("ChQzZzzhgYxfPlat payBack 充值发货失败！！ " + code);
//				return "error";
//			}
//
//		} catch (Exception e) {
//			LOG.error("ChQzZzzhgYxfPlat payBack 充值异常！！ " + e.getMessage());
//			e.printStackTrace();
//			return "error";
//		}
//
    }
}
