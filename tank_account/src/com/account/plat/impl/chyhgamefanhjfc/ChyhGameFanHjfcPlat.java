package com.account.plat.impl.chyhgamefanhjfc;

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
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.util.*;

@Component
public class ChyhGameFanHjfcPlat extends PlatBase {

    // sdk 登录验证地址 的接口地址
    private static String serverUrl = "";

    // 游戏编号
    private static String AppID;

    // 登录 签名用
    private static String appKey = "";

    // 登录 签名用
    private static String ygAppId = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chyhgamefanhjfc/", "plat.properties");
        serverUrl = properties.getProperty("VERIRY_URL");// 签名验证地址
        AppID = properties.getProperty("AppID");
        appKey = properties.getProperty("App_key");
        ygAppId = properties.getProperty("YG_APPID");


    }

    @Override
    public int getPlatNo() {
        return 209;
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
            if (vParam.length < 1) {
                return GameError.PARAM_ERROR;
            }
            String sessionId = vParam[0];
            String platformId = vParam[1];
            JSONObject jsonObject = verifyAccount(sessionId, platformId);
            if (jsonObject == null) {
                LOG.error("jsonObject 返回为空");
                return GameError.SDK_LOGIN;
            }
            int code = jsonObject.getInt("code");
            if (code != 0) {
                return GameError.SDK_LOGIN;
            }
            String uid = jsonObject.getString("userid");
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
            LOG.error("chyh_gamefan_hjfc 登录异常={}", e.getMessage());
            return GameError.PARAM_ERROR;
        }
    }

    private JSONObject packResponse(int ResultCode) {
        String signSource = AppID + String.valueOf(ResultCode);
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
                LOG.error("chyh_gamefan_hjfc ={}", paramName + ":" + request.getParameter(paramName));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("chyh_gamefan_hjfc 参数结束");
            List<String> list = new ArrayList<>();
            list.add("platformId");
            list.add("uid");
            list.add("zoneId");
            list.add("roleId");
            list.add("cpOrderId");
            list.add("orderId");
            list.add("orderStatus");
            list.add("amount");
            list.add("extInfo");
            list.add("payTime");
            list.add("paySucTime");
            list.add("notifyUrl");
            list.add("clientType");
            Collections.sort(list);
            StringBuilder sb = new StringBuilder();
            for (String str : list) {
                sb.append(str + "=" + params.get(str) + "&");
            }
            String md5Str = sb.toString().substring(0, sb.toString().length() - 1) + appKey;
            String toMD5 = MD5Util.toMD5(md5Str).toLowerCase();
            LOG.error("chyh_gamefan_hjfc md5str =" + sb.toString() + " md5val=" + toMD5);
            if (!toMD5.equals(params.get("sign"))) {
                LOG.error("chyh_gamefan_hjfc md5str ={},md5val={}", sb.toString(), toMD5);
                return "1";
            }
            String orderStatus = params.get("orderStatus");
            if (!orderStatus.equals("1")) {
                return "2";
            }
            String orderno_cp = params.get("cpOrderId");
            String[] infos = orderno_cp.split("_");
            if (infos.length < 3) {
                return "3";
            }
            int serverId = Integer.valueOf(infos[0]);
            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.childNo = super.getPlatNo();
            payInfo.serialId = orderno_cp;
            payInfo.platId = params.get("uid");
            payInfo.orderId = params.get("orderId");
            payInfo.serverId = serverId;
            payInfo.roleId = Long.parseLong(params.get("roleId"));
            payInfo.realAmount = Integer.valueOf(params.get("amount")) / 100.0;
            payInfo.amount = Integer.valueOf(params.get("amount")) / 100;
            int code = payToGameServer(payInfo);
            if (code == 1) {
                return "0";
            }
            LOG.info("chyh_gamefan_hjfc 充值发货成功 ");
            return "0";
        } catch (Exception e) {
            LOG.error("chyh_gamefan_hjfc 充值异常 = {}", e.getMessage());
            return packResponse(1).toString();
        }
    }

    private JSONObject verifyAccount(String sessionId, String platformId) {
        LOG.info("chyh_gamefan_hjfc 开始调用sidInfo接口");
        Map<String, Object> map = new HashMap<>();
        map.put("sessionId", sessionId);
        map.put("platformId", platformId);
        map.put("appId", ygAppId);
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, Object> stringObjectEntry : map.entrySet()) {
            sb.append(stringObjectEntry.getKey() + "=" + stringObjectEntry.getValue() + "&");
        }
        String str = sb.substring(0, sb.length() - 1);
        try {
            String result = HttpUtils.sentPost(serverUrl, str);
            LOG.info("chyh_gamefan_hjfc 响应结果= {}", result);
            JSONObject rsp = JSONObject.fromObject(result);
            return rsp;
        } catch (Exception e) {
            LOG.error("登录验证出错={}", e);
        }
        return null;
    }


    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    @Override
    public String order(WebRequest request, String content) {
        try {
            LOG.error("chyh_gamefan_hjfc 充值加签");
            int amount = Integer.parseInt(request.getParameter("amount"));
            //long appId = Long.parseLong(request.getParameter("appId"));
            String uid = request.getParameter("uid");
            String cpOrderId = request.getParameter("cpOrderId");
            String roleId = request.getParameter("roleId");
            String zoneId = request.getParameter("zoneId");
            Map<String, Object> map = new HashMap<>();
            map.put("amount", amount);
            map.put("appId", ygAppId);
            map.put("uid", uid);
            map.put("cpOrderId", cpOrderId);
            map.put("roleId", roleId);
            map.put("zoneId", zoneId);
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
            String str = sb.toString().substring(0, sb.length() - 1);
            str += appKey;
            LOG.error("充值加签 = {}", str);
            String sign = MD5Util.toMD5(str);
            LOG.error("充值加签sign = {}", str);
            return sign;
        } catch (Exception e) {
            LOG.error("充值加签出错={}", e);
            return "error";
        }
    }

    public static void main(String[] args) {
        Map<String, Object> map = new HashMap<>();
        map.put("sessionId", "36778f36-1643-4086-a28b-f5b121d99a1a");
        map.put("platformId", 4);
        map.put("appId", 7954);
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, Object> stringObjectEntry : map.entrySet()) {
            sb.append(stringObjectEntry.getKey() + "=" + stringObjectEntry.getValue() + "&");
        }
        String str = sb.substring(0, sb.length() - 1);
        try {
            String result = HttpUtils.sentPost("http://release.anjiu.cn/cp/getuseridinfo", str);
            System.err.println(result);
            JSONObject rsp = JSONObject.fromObject(result);
        } catch (Exception e) {
        }


    }
}
