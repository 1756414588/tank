package com.account.plat.impl.chhjfcQy_appstore;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.util.HttpHelper;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.util.*;

@Component
public class ChhjfcQyAppStorePlat extends PlatBase {

    // 游戏编号
    private static String AppID;

    private static String AppKey;

    private static String SERVERURL;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chhjfcQy_appstore/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKey = properties.getProperty("AppKey");
        SERVERURL = properties.getProperty("ServerUrl");
    }

    @Override
    public int getPlatNo() {
        return 194;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        try {
            if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
                return GameError.PARAM_ERROR;
            }

            String clientToken = req.getSid();
            String baseVersion = req.getBaseVersion();
            String versionNo = req.getVersion();
            String deviceNo = req.getDeviceNo();
            JSONObject jsonObject = this.verifyAccount(clientToken);
            if (jsonObject == null) {
                return GameError.SDK_LOGIN;
            }
            int code = jsonObject.getInt("code");
            if (code != 0) {
                return GameError.SDK_LOGIN;
            }
            String userId = jsonObject.getString("userId");
            String userName = jsonObject.getString("username");

            Account account = accountDao.selectByPlatId(getPlatNo(), userId);
            if (account == null) {
                String token = RandomHelper.generateToken();
                account = new Account();
                account.setPlatNo(this.getPlatNo());
                account.setChildNo(super.getPlatNo());
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
            response.setUserInfo(userId + "_" + userName);
            if (isActive(account)) {
                response.setActive(1);
            } else {
                response.setActive(0);
            }
            return GameError.OK;
        } catch (Exception e) {
            LOG.error("ChhjfcQyAppStorePlat 登录异常={}", e.getMessage());
            return GameError.PARAM_ERROR;
        }
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay ChhjfcQyAppStorePlat");
        LOG.error("ChhjfcQyAppStorePlat 接收到的参数" + content);
        try {
            String sign = URLDecoder.decode(request.getParameter("sign"), "UTF-8");
            LOG.error("client sign ={}", sign);
            Map<String, String> map = new HashMap<>();
            Iterator<String> parameterNames = request.getParameterNames();
            while (parameterNames.hasNext()) {
                String name = parameterNames.next();
                map.put(name, URLDecoder.decode(request.getParameter(name), "UTF-8"));
            }

            List<String> list = new ArrayList<>();
            list.add("orderid");
            list.add("username");
            list.add("gameid");
            list.add("roleid");
            list.add("serverid");
            list.add("paytype");
            list.add("amount");
            list.add("paytime");
            list.add("attach");
            StringBuilder sb = new StringBuilder();
            for (String s : list) {
                sb.append(s + "=" + map.get(s) + "&");
            }
            String str = sb.toString().concat("appkey=" + AppKey);
            String mySign = MD5Util.toMD5(str).toLowerCase();
            LOG.error("sign ={} ", mySign);
            if (mySign.equals(sign)) {// 签名正确,做业务逻辑处理
                PayInfo payInfo = new PayInfo();
                payInfo.platNo = getPlatNo();
                payInfo.platId = map.get("userId");  //渠道用户id
                payInfo.orderId = map.get("orderid");
                payInfo.childNo = super.getPlatNo();
                payInfo.serialId = map.get("orderid");
                payInfo.serverId = Integer.parseInt(map.get("serverid"));
                payInfo.roleId = Long.valueOf(map.get("roleid")); //游戏角色id
                payInfo.realAmount = Double.valueOf(map.get("amount"));
                payInfo.amount = (int) payInfo.realAmount;
                int code = payToGameServer(payInfo);
                if (code == 0) {
                    return "success";
                }
                return "validateError";
            } else {
                LOG.error("ChhjfcQyAppStorePlat  签名验证失败");
                return "errorSign";
            }
        } catch (Exception e) {
            LOG.error("ChhjfcQyAppStorePlat 充值异常！！ " + e.getMessage());
            e.printStackTrace();
        }
        return "success";
    }

    /**
     * SDK服务器验证token
     *
     * @param token
     * @return
     */
    private JSONObject verifyAccount(String token) {
        LOG.error("ChhjfcQyAppStore 开始调用sidInfo接口");
        try {
            JSONObject ob = new JSONObject();
            ob.put("token", token);
            LOG.error("ChhjfcQyAppStorePlat verifyAccount={}", ob.toString());
            Map<String, String> map = new HashMap<>();
            map.put("Content-Type", "application/json");
            String result = HttpHelper.doPost(SERVERURL, ob.toString(), map);
            return JSONObject.fromObject(result);
        } catch (Exception e) {
            LOG.error("ChhjfcQyAppStore  验证token出错");
        }
        return null;
    }

    @Override
    public String order(WebRequest request, String content) {
        LOG.error("ChhjfcQyAppStorePlat pay order start");
        try {
            String uId = request.getParameter("uId");
            String roleId = request.getParameter("roleId");
            int money = Integer.parseInt(request.getParameter("money"));
            String serverId = request.getParameter("serverId");
            String attach = request.getParameter("attach");
            LOG.error("ChhjfcQyAppStorePlat order uid={},roleId={},money={},serverId={},attach={}", uId, roleId, money, serverId, attach);
            Map<String, Object> map = new HashMap<>();
            map.put("uId", uId);
            map.put("roleId", roleId);
            map.put("money", money);
            map.put("serverId", serverId);
            map.put("attach", attach);
            Map<String, Object> maps = new TreeMap<>(new Comparator<String>() {
                @Override
                public int compare(String o1, String o2) {
                    return o1.compareTo(o2);
                }
            });
            maps.putAll(map);
            StringBuilder sb = new StringBuilder();
            for (Map.Entry<String, Object> stringObjectEntry : maps.entrySet()) {
                sb.append(stringObjectEntry.getKey() + "=" + stringObjectEntry.getValue() + "&");
            }
            String signFture = sb.toString().concat(AppKey);
            String sign = MD5Util.toMD5(signFture).toLowerCase();
            LOG.error("ChhjfcQyAppStorePlat order sign ={}", sign);
            return sign;
        } catch (Exception e) {
            LOG.error("ChhjfcQyAppStorePlat pay sign error");
            return "error";
        }
    }


    public static void main(String[] args) {


        String uId = "2441629-1_29";
        String roleId = "111111";
        int money = 100;
        String serverId = "123";
        String attach = "353535";
        AppKey = "43f9370bcfe40ee330ee1dc38943e471";
        Map<String, Object> map = new HashMap<>();
        map.put("uId", uId);
        map.put("roleId", roleId);
        map.put("money", money);
        map.put("serverId", serverId);
        map.put("attach", attach);

        Map<String, Object> maps = new TreeMap<>(new Comparator<String>() {
            @Override
            public int compare(String o1, String o2) {
                return o1.compareTo(o2);
            }
        });
        maps.putAll(map);
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, Object> stringObjectEntry : maps.entrySet()) {
            sb.append(stringObjectEntry.getKey() + "=" + stringObjectEntry.getValue() + "&");
        }
        String sigf = sb.toString().concat(AppKey);
        System.err.println(sb.toString());
        System.err.println(MD5Util.toMD5(sigf).toLowerCase());
    }
}