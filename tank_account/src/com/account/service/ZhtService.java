package com.account.service;

import java.net.URLEncoder;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.context.request.WebRequest;

import com.account.dao.impl.AccountDao;
import com.account.dao.impl.ZhtDao;
import com.account.domain.Account;
import com.account.domain.ZhtAdvertise;
import com.account.domain.ZhtIdfa;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.CheckNull;
import com.account.util.PrintHelper;
import com.caucho.util.Base64;

public class ZhtService {

    public Logger LOG = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private ZhtDao zhtDao;

    @Autowired
    private AccountDao accountDao;


    /**
     * 有效期 七天
     */
    private final long VALID_TIME = 7 * 24 * 60 * 60 * 1000;

    /**
     * 检测时间延迟 一小时
     */
    private final long DELAY_TIME = 60 * 60 * 1000;

    /**
     * 签名秘钥
     */
    private final String SIGN_KEY = "c6083ddc5b44dc72";

    /**
     * 异或秘钥
     */
    private final String ENCRYPT_KEY = "33ba08d631083dc9";

    /**
     * 获取地址
     */
    private String getURL(String appId) {
        return "http://jump.t.l.qq.com/conv/app/" + appId + "/conv?";
    }

    /**
     * 智汇推推广信息推送
     *
     * @param platNo
     * @param request
     * @return
     */
    public String zhtInfo(int platNo, WebRequest request) {
        Iterator<String> iterator = request.getParameterNames();
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            PrintHelper.println(paramName + ":" + request.getParameter(paramName));
        }
        String muid = request.getParameter("muid");

        if (CheckNull.isNullTrim(muid)) {
            return "MUID NULL";
        }

        String click_time = request.getParameter("click_time");
        String click_id = request.getParameter("click_id");
        String app_type = request.getParameter("app_type");
        String appid = request.getParameter("appid");
        String advertiser_id = request.getParameter("advertiser_id");

        JSONObject result = new JSONObject();
        Date now = new Date();
        muid = muid.trim();
        ZhtAdvertise zhtAdvertise = zhtDao.selectZhtAdvertise(platNo, muid);
        if (zhtAdvertise != null) {
            result.put("ret", -1);
            result.put("msg", "该设备已登记");
            return result.toString();
        } else {
            zhtAdvertise = new ZhtAdvertise();
            zhtAdvertise.setMuid(muid);
            zhtAdvertise.setPlatNo(platNo);
            zhtAdvertise.setClickTime(click_time);
            zhtAdvertise.setClickId(click_id);
            zhtAdvertise.setAppType(app_type);
            zhtAdvertise.setAppid(appid);
            zhtAdvertise.setAdvertiserId(advertiser_id);
            zhtAdvertise.setCreateTime(now);
            zhtDao.insertZhtAdvertise(zhtAdvertise);
        }
        ZhtIdfa zhtIdfa = zhtDao.selectZhtIdfa(platNo, muid);
        if (zhtIdfa != null) { // 该设备号已经登记过
            if (zhtAdvertise.getCheckTime() == null) {
                zhtAdvertise.setCheckTime(zhtIdfa.getCreateTime());
                zhtDao.updateZhtAdvertise(zhtAdvertise); // 更新处理时间
                long time = zhtIdfa.getCreateTime().getTime() + DELAY_TIME; // 推送延时1小时 检测时间添加1小时
                if (time >= zhtAdvertise.getCreateTime().getTime()) { // 1小时内  设为推广成功
                    zhtPost(zhtAdvertise); // 向智汇推提交信息
                    List<Account> list = accountDao.selectByDeviceNo(zhtIdfa.getDeviceNo(), platNo);
                    for (Account account : list) {
                        if (account != null) {
                            account.setChildNo(1); // 标记为智汇推用户
                            accountDao.updateChildNo(account);
                        }
                    }
                }
            }
        }
        result.put("ret", 0);
        result.put("msg", "接收成功");
        return result.toString();
    }

    /**
     * 设备激活
     *
     * @param platNo
     * @param deviceNo
     */
    public String checkZhtIdfa(int platNo, String deviceNo) {
        if (CheckNull.isNullTrim(deviceNo)) {
            return "MUID NULL";
        }
        String muid = idfaMD5(platNo, deviceNo);
        ZhtIdfa zhtIdfa = zhtDao.selectZhtIdfa(platNo, muid);
        Date now = new Date();
        if (zhtIdfa == null) { // 没有记录设备 先记录设备
            zhtIdfa = new ZhtIdfa();
            zhtIdfa.setPlatNo(platNo);
            zhtIdfa.setDeviceNo(deviceNo);
            zhtIdfa.setMuid(muid);
            zhtIdfa.setCreateTime(now);
            zhtDao.insertZhtIdfa(zhtIdfa);
        }
        ZhtAdvertise zhtAdvertise = zhtDao.selectZhtAdvertise(platNo, muid);
        if (zhtAdvertise == null) { // 广告方还未推送 不做处理
            return "NO ADVERTISE";
        }
        if (zhtAdvertise.getCheckTime() != null) { // 已经处理过
            return "IS OVER";
        }
        zhtAdvertise.setCheckTime(now);
        zhtDao.updateZhtAdvertise(zhtAdvertise); // 更新处理时间

        if (!isValid(zhtIdfa.getCreateTime().getTime(), zhtAdvertise.getCreateTime().getTime())) {
            return "TIME OUT";
        }

        zhtPost(zhtAdvertise); // 向智汇推提交信息
        return "SUC";
    }

    /**
     * 创建账号判断是否是智汇推用户
     *
     * @param platNo
     * @param deviceNo
     * @return
     */
    public void checkZhtIdfa(Account account) {
        try {
            String deviceNo = account.getDeviceNo();
            int platNo = account.getPlatNo();
            if (CheckNull.isNullTrim(deviceNo)) {
                return;
            }
            String muid = idfaMD5(platNo, deviceNo);
            ZhtIdfa zhtIdfa = zhtDao.selectZhtIdfa(platNo, muid);
            Date now = new Date();
            if (zhtIdfa == null) { // 没有记录设备 先记录设备
                zhtIdfa = new ZhtIdfa();
                zhtIdfa.setPlatNo(platNo);
                zhtIdfa.setDeviceNo(deviceNo);
                zhtIdfa.setMuid(muid);
                zhtIdfa.setCreateTime(now);
                zhtDao.insertZhtIdfa(zhtIdfa);
            }
            ZhtAdvertise zhtAdvertise = zhtDao.selectZhtAdvertise(platNo, muid);
            if (zhtAdvertise == null) { // 广告方还未推送 不做处理
                return;
            }
            boolean isPost = false;
            if (zhtAdvertise.getCheckTime() == null) { // 还未处理 先设置处理时间
                zhtAdvertise.setCheckTime(now);
                zhtDao.updateZhtAdvertise(zhtAdvertise);
                isPost = true;
            }

            if (!isValid(zhtIdfa.getCreateTime().getTime(), zhtAdvertise.getCreateTime().getTime())) {
                return;
            }

            if (isPost) {
                zhtPost(zhtAdvertise); // 向智汇推提交信息
            }
            account.setChildNo(1); // 标记为智汇推用户
        } catch (Exception e) {
            System.err.println("检测智汇推设备异常    ：" + e);
        }
    }

    /**
     * 向智汇推 推送激活信息
     *
     * @param advertise
     * @return
     */
    public boolean zhtPost(ZhtAdvertise zhtAdvertise) {
        try {
            String urlInfo = getURL(zhtAdvertise.getAppid());
            LOG.error("智汇推info:");
            String query_string = "muid=" + zhtAdvertise.getMuid() + "&conv_time=" + System.currentTimeMillis() / 1000;
            LOG.error("query_string=" + query_string);
            String page = urlInfo + query_string;
            LOG.error("page=" + page);
            String encode_page = URLEncoder.encode(page, "UTF-8");
            LOG.error("encode_page=" + encode_page);
            String property = SIGN_KEY + "&GET&" + encode_page;
            LOG.error("property=" + property);
            String signature = MD5.md5Digest(property);
            LOG.error("signature=" + signature);
            String base_data = query_string + "&sign=" + URLEncoder.encode(signature, "UTF-8");
            LOG.error("base_data=" + base_data);
            String data = Base64.encode(xorWithKey(base_data, ENCRYPT_KEY));
            LOG.error("data=" + data);
            String attachment = "conv_type=MOBILE_APP_ACTIVITE&app_type=" + zhtAdvertise.getAppType() + "&advertiser_id=" + zhtAdvertise.getAdvertiserId();
            LOG.error("attachment=" + attachment);
            String url = urlInfo + "v=" + data + "&" + attachment;
            LOG.error("url=" + url);

            String result = HttpUtils.sendGet(url, new HashMap<String, String>());
            LOG.error("notice zht result:" + result);
            if (result != null) {
                JSONObject rsp = JSONObject.fromObject(result);
                if (rsp.getInt("ret") == 0) {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error("noticeAdvertise Exception, platNo:"
                    + zhtAdvertise.getPlatNo() + ", MUID:" + zhtAdvertise.getMuid()
                    + ", exception:" + e.getMessage());
            return false;
        }
    }

    /**
     * 判断是否激活有效
     *
     * @param idfaTime      设备激活时间
     * @param advertiseTime 广告推送时间
     * @return
     */
    private boolean isValid(long idfaTime, long advertiseTime) {
        if (idfaTime >= advertiseTime && idfaTime - advertiseTime > VALID_TIME) { // 过期
            return false;
        }
        if (advertiseTime > idfaTime && advertiseTime - idfaTime > DELAY_TIME) { // 老用户
            return false;
        }
        return true;
    }

    /**
     * 智汇推设备号MD5
     *
     * @param platNo
     * @param deviceNo
     * @return
     */
    private String idfaMD5(int platNo, String deviceNo) {
        if (platNo == 94 || platNo == 95 || platNo >= 500) {
            //IOS 设备-muid 加密规则：IDFA 码（需转大写），进行 md5sum以后得到的 32位全小写MD5表现字符串。
            deviceNo = MD5.md5Digest(deviceNo.trim().toUpperCase()).toLowerCase();
        } else {
            //Android 设备-muid 加密规则：IMEI 号(需转小写)，进行 md5sum 以后得到的 32 位全小写 MD5 表现字符串。
            deviceNo = MD5.md5Digest(deviceNo.trim().toLowerCase()).toLowerCase();
        }
        return deviceNo;
    }

    /**
     * 字符串异或
     *
     * @param a
     * @param key
     * @return
     */
    private static byte[] xorWithKey(String txt, String key) {
        byte[] a = txt.getBytes();
        byte[] b = key.getBytes();
        byte[] out = new byte[a.length];
        for (int i = 0; i < a.length; i++) {
            out[i] = (byte) (a[i] ^ b[i % b.length]);
        }
        return out;
    }

}
