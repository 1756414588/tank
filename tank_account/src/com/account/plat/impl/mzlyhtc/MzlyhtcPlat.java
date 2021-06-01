package com.account.plat.impl.mzlyhtc;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.apache.commons.lang.StringUtils;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;


@Component
public class MzlyhtcPlat extends PlatBase {
    private static String public_key = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzlyhtc/", "plat.properties");
        public_key = properties.getProperty("public_key");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return null;
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        //String  userId = verifyAccount(sid);
        String userId = sid;
        if (userId == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
//			if (!checkIpConfine(response.getIp())){
//				return GameError.IPCONFINE_MAX;
//			}
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

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay htc");
        LOG.error("[接收到的参数]" + content);
        try {
            Map<String, String> params = new HashMap<String, String>();
            if (StringUtils.isNotBlank(content)) {
                String[] paramertes = content.split("&");
                for (String parameter : paramertes) {
                    String[] p = parameter.split("=");
                    params.put(p[0], p[1].replaceAll("\"", ""));
                }
            }
            String signType = params.get("sign_type");//签名类型，一般是RSA
            String sign = java.net.URLDecoder.decode(params.get("sign"), "utf-8");// 签名
            String order = params.get("order");

            LOG.error("signType=" + signType);
            LOG.error("sign=" + sign);
            LOG.error("order1=" + order);

            String orderDecoderToJson = java.net.URLDecoder.decode(order, "utf-8");// urlDecoder
            LOG.error("order2=" + orderDecoderToJson);

            boolean isOk = RSASignature.doCheck(orderDecoderToJson, sign, public_key);
            LOG.error("isOk:" + isOk);

            if (isOk) {
//					String resultCode= request.getParameter("result_code");//1成功 0失败
////					String resultMsg= request.getParameter("result_msg");//支付信息
////					String gameCode= request.getParameter("game_code");//游戏编号
//					String realAmount= request.getParameter("real_amount");//付款成功金额，单位人民币分
//					String cpOrderId= request.getParameter("game_order_id");//cp自身的订单号
//					String joloOrderId= request.getParameter("jolo_order_id");//jolo订单
////					String createTime= request.getParameter("gmt_create");//创建时间 订单创建时间 yyyy-MM-dd  HH:mm:ss
////					String payTime= request.getParameter("gmt_payment");//支付时间 订单支付时间  yyyy-MM-dd  HH:mm:ss
                JSONObject jsonObject = JSONObject.fromObject(orderDecoderToJson);
                int resultCode = jsonObject.getInt("result_code");//1成功 0失败
                LOG.error("resultCode:" + resultCode);
//					String resultMsg=(String)jsonObject.get("result_msg");//支付信息
//					String gameCode=(String)jsonObject.get("game_code");//游戏编号
                int realAmount = (int) jsonObject.getInt("real_amount");//付款成功金额，单位人民币分
                LOG.error("resultCode:" + resultCode);
                String cpOrderId = (String) jsonObject.get("game_order_id");//cp自身的订单号
                LOG.error("cpOrderId:" + cpOrderId);
                String joloOrderId = (String) jsonObject.get("jolo_order_id");//jolo订单
                LOG.error("joloOrderId:" + joloOrderId);
//					String createTime=(String)jsonObject.get("gmt_create");//创建时间 订单创建时间 yyyy-MM-dd  HH:mm:ss
//					String payTime=(String)jsonObject.get("gmt_payment");//支付时间 订单支付时间  yyyy-MM-dd  HH:mm:ss
                String plat = request.getParameter("plat");
                if (resultCode != 1) {
                    LOG.error("扣费不成功");
                    return "failure";
                }

                String[] infos = cpOrderId.split("_");
                if (infos.length != 3) {
                    LOG.error("传参不正确");
                    return "failure";
                }
                int serverid = Integer.valueOf(infos[0]);
                Long lordId = Long.valueOf(infos[1]);

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = plat;
                payInfo.orderId = cpOrderId;

                payInfo.serialId = joloOrderId;
                payInfo.serverId = serverid;
                payInfo.roleId = lordId;

                payInfo.amount = realAmount / 100;
                payInfo.realAmount = (double) payInfo.amount;
                int retcode = payToGameServer(payInfo);
                if (retcode == 0) {
                    LOG.error("返回充值成功");
                } else {
                    LOG.error("充值成功,发货失败" + retcode);
                }
                return "success";
            }
            return "failure";
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("支付异常");
            return "failure";
        }
    }

    public static void main(String args[]) {
		/* String public_key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDbRLzWfCD4pQb1mjeGLy6gw+AfOKZ1dpNbMUyZml+p3stTSdTyHHpkuPPsaOqsT9gFDSmXz5KRBt4w6KCeLj/R61KA5rmMJipDnSJV19kld0z6NW47kiEQHslaalDBCST94TUIcCzjhaiG3yTChDCTFo3v47qyt6j3YvVpih8UNQIDAQAB";
		 String orderDecoderToJson ="{\"result_code\":1,\"gmt_create\":\"2017-05-17 17:47:48\",\"real_amount\":1000,\"result_msg\":\"支付成功\",\"game_code\":\"2987537477156\",\"game_order_id\":\"1_136307_1495014467535\",\"jolo_order_id\":\"ZF10255196956d8fe89da11a325\",\"gmt_payment\":\"2017-05-17 17:48:40\"}" ;
		 String sign = "nbmyOwQHoE3jAnoIOVJdlOl693GhvW7tqP3fgkWwgNIyZ9ghBwQSBHDLYZoUa3YzswS89/7OcXM4DgAoY4KgQvA6WFv9tpr/z2LsJcq8ctb+gYQxx9DPjLlopR/XMi5+uxg6537BToQ7nfNL5bGwwA/QbcUgrmdpKXUiBs8jLMo=";
		 boolean isOk = RSASignature.doCheck(orderDecoderToJson, sign, public_key);
		 LOG.error(isOk);*/
    }
}
