package com.account.plat.impl.afJsyd_appstore;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.security.NoSuchAlgorithmException;
import java.util.*;

class AnfanAccount {
    public String ucid;// id
    public String uid; // name
    public String phone;
    public String uuid; // 授权码
}

@Component
public class AfJsyd_appstorePlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String SIGN_KEY;
    private static String APP_ID;

    //有内购参数的需要添加2个MAP在封装参数
    private static Map<Integer, String> RECHARGE_MAP = new HashMap<Integer, String>();
    private static Map<Integer, Integer> MONEY_MAP = new HashMap<Integer, Integer>();

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/afJsyd_appstore/", "plat.properties");
        SIGN_KEY = properties.getProperty("SIGN_KEY");
        serverUrl = properties.getProperty("VERIRY_URL");
        APP_ID = properties.getProperty("APP_ID");
        initRechargeMap();
    }

    private void initRechargeMap() {

        RECHARGE_MAP.put(1, "com.tank.mjdzh60");
        MONEY_MAP.put(1, 6);

        RECHARGE_MAP.put(2, "com.tank.mjdzh300");
        MONEY_MAP.put(2, 30);

        RECHARGE_MAP.put(3, "com.tank.mjdzh980");
        MONEY_MAP.put(3, 98);

        RECHARGE_MAP.put(4, "com.tank.mjdzh1980");
        MONEY_MAP.put(4, 198);

        RECHARGE_MAP.put(5, "com.tank.mjdzh3280");
        MONEY_MAP.put(5, 328);

        RECHARGE_MAP.put(6, "com.tank.mjdzh6480");
        MONEY_MAP.put(6, 648);
    }

    public int getPlatNo() {  // 角色与安峰老包互通
        return 95;
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

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

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

        String openid = vParam[0];
        String token = vParam[1];

        boolean flag = verifyAccount(openid, token);
        if (!flag) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), openid);
        if (account == null) {
            //String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setChildNo(super.getPlatNo());
            account.setPlatId(openid);
            account.setAccount(getPlatNo() + "_" + openid);
            account.setPasswd(openid);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            accountDao.insertWithAccount(account);
            response.setUserInfo("1");
        } else {
            //String token = RandomHelper.generateToken();
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

    private boolean verifyAccount(String openid, String token) {
        try {
            LOG.error("afNewMjdzh1_appstore开始调用sidInfo接口:" + serverUrl);

            String postdatasb = "app_id=" + APP_ID + "&open_id=" + openid + "&token=" + token + "&sign_key=" + SIGN_KEY;
            LOG.error("待签名字符串： " + postdatasb);
            // 对排序后的参数附加开发商签名密钥
            String sign = md5(postdatasb.toString().getBytes());
            LOG.error("签名值：" + sign);

            String postdata = "app_id=" + APP_ID + "&open_id=" + openid + "&token=" + token + "&sign=" + sign;
            LOG.error("需要发送到服务器的数据为：" + postdata);

            String result = HttpUtils.sentPost(serverUrl, postdata);

            LOG.error("收到到服务器的数据为：" + result);

            JSONObject rsp = JSONObject.fromObject(result);
            if (!rsp.containsKey("code")) {
                return false;
            }

            int code = rsp.getInt("code");
            if (code != 0) {
                LOG.error("服务端拒绝提供服务");
                return false;
            }

            JSONObject data = rsp.getJSONObject("msg");
            LOG.error("调用sidInfo接口结束");
            return true;
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("接口返回异常");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Overriding: doLogin
     *
     * @param param
     * @param response
     * @return
     * @see com.account.plat.PlatInterface#doLogin(JSONObject,
     * JSONObject)
     */
    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        // TODO Auto-generated method stub
        LOG.error("pay afNewMjdzh1_appstore");
        LOG.error("[接收到的参数]" + content);
        try {
            Map<String, String> params = new HashMap<String, String>();
            String[] kvs = content.split("&");
            for (String kv : kvs) {
                String[] k2v = kv.split("=");
                params.put(k2v[0], URLDecoder.decode(k2v[1], "UTF-8"));
            }

            // for (Iterator<String> it = params.keySet().iterator();
            // it.hasNext();) {
            // String k = (String) it.next();
            // String v = (String) params.get(k);
            // }

            // 排序key值
            List<String> keys = new ArrayList<String>(params.keySet());
            Collections.sort(keys);
            String signstr = "";
            for (int i = 0; i < keys.size(); i++) {
                String k = keys.get(i);
                String v = params.get(k);
                if (!k.equalsIgnoreCase("sign") && !k.equalsIgnoreCase("plat")) {
                    signstr = signstr + k + "=" + v + "&";
                }
            }

            signstr = signstr + "sign_key=" + SIGN_KEY;
            LOG.error("signstr " + signstr);
            String sign = md5(signstr.getBytes());
            LOG.error("sign " + sign);

            if (!APP_ID.equals(params.get("vid"))) {
                LOG.error("afNewMjdzh1_appstore 充值应用ID不一致！！ ");
                return "ERROR";
            }

            String originSign = params.get("sign");
            if (sign.equalsIgnoreCase(originSign)) {

                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.childNo = super.getPlatNo();
                payInfo.platId = params.get("open_id");
                payInfo.orderId = params.get("sn");
                payInfo.serialId = params.get("vorder_id");

                // serverId_roleId_timeStamp
                String[] v = payInfo.serialId.split("_");
                payInfo.serverId = Integer.valueOf(v[0]);
                payInfo.roleId = Long.valueOf(v[1]);
                payInfo.realAmount = Double.valueOf(params.get("fee"));
                payInfo.amount = (int) (payInfo.realAmount / 1);
                int code = payToGameServer(payInfo);
                if (code != 0) {
                    LOG.error("afNewMjdzh1_appstore 充值发货失败！！ " + code);
                }
                return "SUCCESS";
            } else {
                LOG.error("afNewMjdzh1_appstore 签名不一致！！ " + originSign + "|" + sign);
                return "ERROR";
            }
        } catch (Exception e) {
            LOG.error("afNewMjdzh1_appstore 充值异常！！ " + e.getMessage());
            e.printStackTrace();
            return "ERROR";
        }
    }
}
