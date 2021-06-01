package com.account.plat.impl.hiGame;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Date;
import java.util.HashMap;
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
import com.account.plat.impl.muzhiEn.Base64;
import com.account.plat.impl.mzIntouch.Rsa;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

//class UcAccount {
//	public int ucid;
//	public String nickName;
//}

@Component
public class HiGamePlat extends PlatBase {

    private static String AppMzKey;

//		private static String AppIntouchKey;

    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    private static String AppID;

//		private static String AppKey;

//		private static Map<Double, Integer> PRICE_MAP = new HashMap<Double, Integer>();
//		private static Map<Double, Integer> PACK_PRICE_MAP = new HashMap<Double, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/hiGame/", "plat.properties");
        AppMzKey = properties.getProperty("AppMzKey");
//			AppIntouchKey = properties.getProperty("AppIntouchKey");
        AppID = properties.getProperty("AppID");
//			AppKey = properties.getProperty("AppKey");
        initRechargeMap();
    }

    private void initRechargeMap() {
        MONEY_MAP.put(1, 30);

        MONEY_MAP.put(2, 68);

        MONEY_MAP.put(3, 128);

        MONEY_MAP.put(4, 328);

        MONEY_MAP.put(5, 648);

//			PRICE_MAP.put(4.99, 30);
//
//			PRICE_MAP.put(9.99, 68);
//
//			PRICE_MAP.put(19.99, 128);
//
//			PRICE_MAP.put(49.99, 328);
//			
//			PRICE_MAP.put(99.99, 648);
//			
//			PACK_PRICE_MAP.put(0.99, 1);
//			
//			PACK_PRICE_MAP.put(1.99, 2);
//			
//			PACK_PRICE_MAP.put(4.99, 3);
//			
//			PACK_PRICE_MAP.put(9.99, 4);
//			
//			PACK_PRICE_MAP.put(19.99, 5);
//			
//			PACK_PRICE_MAP.put(49.99, 6);
//			
//			PACK_PRICE_MAP.put(99.99, 7);
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
        if (vParam.length < 3) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        String userName = vParam[1];
        String sign = vParam[2];

        if (!verifyAccount(userId, userName, sign)) {
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
        LOG.error("pay hiGame");
        LOG.error("[接收到的参数]" + content);
        try {
            String contentParam = request.getParameter("content");
            String sign = request.getParameter("sign");
            contentParam = new String(Base64.decode(contentParam));
            LOG.error("[content]" + contentParam);
            String signStr = contentParam + "&key=" + AppMzKey;
            LOG.error("[signStr]" + signStr);
            String mysign = Rsa.getMD5(signStr);
            LOG.error("mysign=" + mysign);
            if (mysign.equals(sign)) {// 签名正确,做业务逻辑处理
                String pay_no;
                // String username;
                // String device_id;
                String game_id;
                // int server_id;
                String cp_order_id;
                // String pay_type;
                // String thir_pay_id;
                int amount;
                int payStatus;
                String user_id;

                JSONObject json = JSONObject.fromObject(contentParam);
                LOG.error("[订单参数]" + json);
                pay_no = json.getString("pay_no");
                // username = json.getString("username");
                // device_id = json.getString("device_id");
                // server_id = json.getInt("server_id");
                game_id = json.getString("game_id");
                cp_order_id = json.getString("cp_order_id");
                // pay_type = json.getString("pay_type");
                amount = json.getInt("amount");
                payStatus = json.getInt("payStatus");
                user_id = json.getString("user_id");
                if (!AppID.equals(game_id)) {
                    LOG.error("hiGame 充值回调错误！！gameid: " + game_id);
                    return "success";
                }

                if (payStatus == 0) {
                    // 1.下发游戏币,玩家实际付费以本通知的amount为准，不能使用订单生成的金额。
                    // 2.成功与否都返回success，SDK服务器只关心是否有通知到CP服务器

                    // serverId_roleId_timeStamp
                    Double price = Double.valueOf(amount) / 100;
                    String[] v = cp_order_id.split("_");
                    int rechargeId = Integer.valueOf(v[3]);
                    int rechargePackId = Integer.valueOf(v[4]);

//						if (rechargeId > 0 && PRICE_MAP.get(price).intValue() != MONEY_MAP.get(rechargeId).intValue()) {
//							LOG.error("mzIntouch 商品金额不匹配 充值发货失败  ！！ ");
//							return "fail";
//						}

//						if (rechargePackId > 0 && PACK_PRICE_MAP.get(price).intValue() != rechargePackId) {
//							LOG.error("mzIntouch 商品金额不匹配 充值发货失败  ！！ ");
//							return "fail";
//						}

                    PayInfo payInfo = new PayInfo();
                    payInfo.platNo = getPlatNo();
                    payInfo.platId = user_id;
                    payInfo.orderId = pay_no;

                    payInfo.serialId = cp_order_id;
                    payInfo.serverId = Integer.valueOf(v[0]);
                    payInfo.roleId = Long.valueOf(v[1]);
                    payInfo.realAmount = price;
                    if (rechargeId > 0)  // 购买金币
                        payInfo.amount = MONEY_MAP.get(rechargeId);
                    if (rechargePackId > 0)  // 购买礼包
                        payInfo.packId = rechargePackId;
                    int code = payToGameServer(payInfo);
                    if (code != 0) {
                        LOG.error("hiGame 充值发货失败！！ " + code);
                    } else {
                        LOG.error("hiGame 充值,发货成功");
                    }
                } else {
                    LOG.error("hiGame 充值,失败订单，跳过");
                }
            } else {
                LOG.error("hiGame 充值,签名验证失败 ");
            }
        } catch (Exception e) {
            LOG.error("hiGame 充值异常！！ ");
            LOG.error("hiGame 充值异常:" + e.getMessage());
            e.printStackTrace();
        }

        return "success";
//			Iterator<String> iterator = request.getParameterNames();
//			LOG.error("pay mzIntouch");
//			LOG.error("pay mzIntouch content:" + content);
//			while (iterator.hasNext()) {
//				String paramName = iterator.next();
//				LOG.error(paramName + ":" + request.getParameter(paramName));
//			}
//			LOG.error("[参数结束]");
//
//			try {
//				String Act = request.getParameter("Act");
//				String AppId = request.getParameter("AppId");
//				String ThirdAppId = request.getParameter("ThirdAppId");
//				String Uin = request.getParameter("Uin");
//				String ConsumeStreamId = request.getParameter("ConsumeStreamId");
//				String TradeNo = request.getParameter("TradeNo");
//				String Subject = request.getParameter("Subject");
//				String Amount = request.getParameter("Amount");
//				String ChargeAmount = request.getParameter("ChargeAmount");
//				String ChargeAmountIncVAT = request.getParameter("ChargeAmountIncVAT");
//				String ChargeAmountExclVAT = request.getParameter("ChargeAmountExclVAT");
//				String Country = request.getParameter("Country");
//				String Currency = request.getParameter("Currency");
//				String Share = request.getParameter("Share");
//				String Note = request.getParameter("Note");
//				String TradeStatus = request.getParameter("TradeStatus");
//				String CreateTime = request.getParameter("CreateTime");
//				String IsTest = request.getParameter("IsTest");
//				String PayChannel = request.getParameter("PayChannel");
//				String Sign = request.getParameter("Sign");
//				
//				if (!TradeStatus.equals("0")) {
//					LOG.error("mzIntouch 支付不成功" + TradeStatus);
//					return packResponse(0);
//				}
//				
//				String signSource = Act + AppId + ThirdAppId + Uin
//						+ ConsumeStreamId + TradeNo + Subject + Amount
//						+ ChargeAmount + ChargeAmountIncVAT + ChargeAmountExclVAT
//						+ Country + Currency + Share + Note + TradeStatus
//						+ CreateTime + IsTest + PayChannel + AppIntouchKey;
//				
//				String orginSign = MD5.md5Digest(signSource);
//				
//				if (orginSign.equals(Sign)) {
//					String[] infos = Note.split("_");
//					if (infos.length != 4) {
//						LOG.error("自有参数不正确");
//						return packResponse(0);
//					}
//
//					int serverid = Integer.valueOf(infos[0]);
//					Long lordId = Long.valueOf(infos[1]);
//					
//					int rechargeId = Integer.valueOf(infos[3]);
//					int money = MONEY_MAP.get(rechargeId);
//					
//					PayInfo payInfo = new PayInfo();
//					payInfo.platNo = getPlatNo();
//					payInfo.platId = Uin;
//					payInfo.orderId = ConsumeStreamId;
//
//					payInfo.serialId = Note;
//					payInfo.serverId = serverid;
//					payInfo.roleId = lordId;
//					payInfo.realAmount = Double.valueOf(ChargeAmountExclVAT);
//					payInfo.amount = money; 
//					int code = payToGameServer(payInfo);
//
//					if (code != 0) {
//						LOG.error("mzIntouch 充值发货失败 " + code);
//						return packResponse(0);
//					} else {
//						LOG.error("mzIntouch 充值发货成功" + code);
//						return packResponse(1);
//					}
//				} else {
//					LOG.error("mzIntouch 充值发货失败    Sign无效 ");
//					return packResponse(5);  // 5：Sign无效
//				}
//			} catch (Exception e) {
//				LOG.error("支付异常:" + e.getMessage());
//				e.printStackTrace();
//				return packResponse(0);
//			}
    }

//		private String packResponse(int ResultCode) {
//			JSONObject json = new JSONObject();
//			json.put("ErrorCode", ResultCode);
//			if (ResultCode == 1){
//				json.put("ErrorDesc", "Success");
//			} else {
//				json.put("ErrorDesc", "Fail");
//			}
//			return json.toString();
//		}

    private boolean verifyAccount(String userid, String usename, String sign) {
        LOG.error("hiGame 开始调用sidInfo接口");
        // String signSource = usename + AppKey;// 组装签名原文
        // String signGenerate = Rsa.getMD5(signSource).toLowerCase();

        try {
            String signSource = usename + AppMzKey;
            signSource = URLEncoder.encode(signSource, "utf-8");
            String signGenerate = Rsa.getMD5(signSource).toLowerCase();

            LOG.error("[签名原文]" + signSource);
            LOG.error("[签名结果]" + signGenerate);
            LOG.error("[签名传入]" + sign);

            if (sign.equals(signGenerate)) {
                return true;
            }
        } catch (UnsupportedEncodingException e) {
            LOG.error("hiGame 用户验证异常:" + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    public static void main(String[] args) {
        String content = "eyJwYXlfbm8iOiIxNzA1MDUxNzQ4MzExIiwidXNlcm5hbWUiOiJrY3c2NjY2NjYiLCJ1c2VyX2lkIjo0NzYsImRldmljZV9pZCI6Ijg2ODAyNDAyMzc0MzkwMCIsInNlcnZlcl9pZCI6Ijk5OSIsInBhY2tldF9pZCI6IjEwMDAwODAwMSIsImdhbWVfaWQiOiIwMDgiLCJjcF9vcmRlcl9pZCI6Ijk5OV8xNTNfMTQ5Mzk3NzkxMzA0N18xIiwicGF5X3R5cGUiOiJpbnRvdWNocGF5IiwiYW1vdW50Ijo1MDAsInBheVN0YXR1cyI6MH0=";

        String sign = "8fcc0320904d5776c0ba9bf26018acfa";

        content = new String(Base64.decode(content));

        String mysign = Rsa.getMD5(content + "&key=" + "zty008");
        if (mysign.equals(sign)) {// 签名正确,做业务逻辑处理
            String pay_no;
            // String username;
            // String device_id;
            String game_id;
            // int server_id;
            String cp_order_id;
            // String pay_type;
            // String thir_pay_id;
            int amount;
            int payStatus;
            String user_id;

            JSONObject json = JSONObject.fromObject(content);
            //LOG.error("[订单参数]" + json);
            pay_no = json.getString("pay_no");
            // username = json.getString("username");
            // device_id = json.getString("device_id");
            // server_id = json.getInt("server_id");
            game_id = json.getString("game_id");
            cp_order_id = json.getString("cp_order_id");
            // pay_type = json.getString("pay_type");
            amount = json.getInt("amount");
            payStatus = json.getInt("payStatus");
            user_id = json.getString("user_id");
            if (!AppID.equals(game_id)) {
                //LOG.error("hiGame 充值回调错误！！gameid: " + game_id);

            }

            if (payStatus == 0) {
                // 1.下发游戏币,玩家实际付费以本通知的amount为准，不能使用订单生成的金额。
                // 2.成功与否都返回success，SDK服务器只关心是否有通知到CP服务器

                // serverId_roleId_timeStamp
                Double price = Double.valueOf(amount) / 100;
                String[] v = cp_order_id.split("_");
                int rechargeId = Integer.valueOf(v[3]);
                int rechargePackId = Integer.valueOf(v[4]);

//					if (rechargeId > 0 && PRICE_MAP.get(price).intValue() != MONEY_MAP.get(rechargeId).intValue()) {
//						LOG.error("mzIntouch 商品金额不匹配 充值发货失败  ！！ ");
//						
//					}
//					
//					if (rechargePackId > 0 && PACK_PRICE_MAP.get(price).intValue() != rechargePackId) {
//						LOG.error("mzIntouch 商品金额不匹配 充值发货失败  ！！ ");
//						
//					}

            }
        }
    }
}
