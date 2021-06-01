package com.account.plat.impl.chJhNew;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.chJhNew1.ChJhNew1Plat;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.impl.self.util.HttpUtils;
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

/**
 * 草花新版中间件参数和SDK文档稍后发你
 */
@Component
public class ChJhNewPlat extends PlatBase {

    private static String AppID;
    private static String AppKEY;
    private static String ServerKEY;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chJhNew/", "plat.properties");
        AppID = properties.getProperty("AppID");
        AppKEY = properties.getProperty("AppKEY");
        ServerKEY = properties.getProperty("ServerKEY");
    }

    @Override
    public int getPlatNo() {
        return 121;
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {

        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] split = sid.split("__");

        String userName = split[0];

        Account account = accountDao.selectByPlatId(getPlatNo(), userName);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userName);
            account.setAccount("0");
            account.setPasswd("0");
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
        response.setUserInfo(userName);


        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }


    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chJhNew payBack");
        LOG.error("chJhNew 接收到的参数" + content);

        JSONObject result = new JSONObject();

        try {
            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<String, String>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error("chJhNew " + paramName + ":" + request.getParameter(paramName));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("chJhNew 参数结束");

            List<String> list = new ArrayList<>();
            list.add("orderno");
            list.add("orderno_cp");
            list.add("userid");
            list.add("order_amt");
            list.add("pay_amt");
            list.add("pay_time");
            list.add("extra");
            Collections.sort(list);

            String extra = params.get("extra");

            boolean isChJhNew1 = false;

            if (extra != null && extra.indexOf("chJhNew1") != -1) {
                isChJhNew1 = true;
            }

            StringBuilder sb = new StringBuilder();
            for (String str : list) {
                sb.append(str);
                sb.append("=");
                sb.append(params.get(str));
                sb.append("&");
            }
            String md5Str = sb.toString().substring(0, sb.toString().length() - 1) + ServerKEY;
            String toMD5 = MD5Util.toMD5(md5Str).toUpperCase();

            LOG.error("chJhNew md5str =" + sb.toString() + " md5val=" + toMD5);
            if (!toMD5.equals(params.get("sign"))) {
                String newToMD5 = MD5Util.toMD5(sb.toString().substring(0, sb.toString().length() - 1) + ChJhNew1Plat.ServerKEY).toUpperCase();
                if (!newToMD5.equals(params.get("sign"))) {
                    LOG.error("chJhNew1 md5str =" + sb.toString() + " md5val=" + newToMD5);
                    result.put("code", 203);
                    result.put("msg", "签名校验失败 " + isChJhNew1);
                    return result.toString();
                }
            }

            String orderno_cp = params.get("orderno_cp");
            String[] infos = orderno_cp.split("_");

            if (infos.length < 3) {
                result.put("code", 204);
                result.put("msg", "游戏订单错误");
                return result.toString();
            }

            Long lordId = Long.valueOf(infos[1]);
            PayInfo payInfo = new PayInfo();

            if (isChJhNew1) {
                payInfo.platNo = ChJhNew1Plat.getNewPlatNo();
            } else {
                payInfo.platNo = getPlatNo();
            }

            payInfo.serialId = orderno_cp;
            payInfo.platId = params.get("userid");
            payInfo.orderId = params.get("orderno");
            payInfo.serverId = Integer.valueOf(infos[0]);
            payInfo.roleId = lordId;
            payInfo.realAmount = Integer.valueOf(params.get("pay_amt")) / 100.0;
            payInfo.amount = Integer.valueOf(params.get("order_amt")) / 100;
            int code = payToGameServer(payInfo);

            if (code == 1) {
                result.put("code", 200);
                result.put("msg", "成功");
                return result.toString();
            }

            if (code != 0) {
                LOG.error("chJhNew 充值发货失败！！ " + code);
                result.put("code", 205);
                result.put("msg", "系统错误");
                return result.toString();
            }


            LOG.error("chJhNew 充值发货成功 " + isChJhNew1);
            result.put("code", 200);
            result.put("msg", "成功");
            return result.toString();
        } catch (Exception e) {
            e.printStackTrace();
            result.put("code", 205);
            result.put("msg", "系统错误");
            return result.toString();
        }
    }


    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }
}
