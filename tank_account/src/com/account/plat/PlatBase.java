package com.account.plat;

import com.account.common.ServerSetting;
import com.account.constant.GameError;
import com.account.constant.PlatType;
import com.account.dao.impl.AccountDao;
import com.account.dao.impl.PayDao;
import com.account.dao.impl.RoleInfoDao;
import com.account.domain.Account;
import com.account.domain.Pay;
import com.account.domain.form.RoleLog;
import com.account.plat.interfaces.LogRoleCreate2sdk;
import com.account.plat.interfaces.LogRoleLogin2sdk;
import com.account.plat.interfaces.LogRoleUp2sdk;
import com.account.service.WxAdService;
import com.account.service.ZhtService;
import com.account.util.DateHelper;
import com.account.util.HttpHelper;
import com.account.util.LogUtil;
import com.account.util.PbHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb.PayBackRq;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PropertiesLoaderUtils;
import org.springframework.web.context.request.WebRequest;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Properties;

abstract public class PlatBase implements PlatInterface {

    protected Logger LOG = LoggerFactory.getLogger(this.getClass());

    /**
     * 内部补单不记录数据库 内部补单单号前缀
     */
    public static final String ODERID_NBBD = "BL1705_NBBD";
    @Autowired
    protected AccountDao accountDao;

    @Autowired
    protected PayDao payDao;

    @Autowired
    protected ServerSetting serverSetting;

    @Autowired
    protected ZhtService zhtService;

    @Autowired
    protected WxAdService wxAdService;

    @Autowired
    private RoleInfoDao roleInfoDao;

    private String platName;
    private int platNo;

    /**
     * 这个获取的是当前渠道号 由于getPlatNo获取的有可能是母渠道号
     *
     * @return
     */
    public int getPlatNo2() {
        return platNo;
    }

    private String desc;
    // 渠道类型
    private PlatType platType;

    public void setPlatType(PlatType platType) {
        this.platType = platType;
    }

    public PlatType getPlatType() {
        return platType;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    @Override
    public String order(WebRequest request, String content) {
        return "";
    }

    @Override
    public String balance(WebRequest request, String content) {
        return "";
    }

    public String doLogin(WebRequest request, String content) {
        return "";
    }

    public String newPayBack(WebRequest request, String content, HttpServletResponse response, String type) {
        return "";
    }

    public String getPlatName() {
        return platName;
    }

    public void setPlatName(String platName) {
        this.platName = platName;
    }

    public int getPlatNo() {
        return platNo;
    }

    public void setPlatNo(int platNo) {
        this.platNo = platNo;
    }

    private boolean isWhiteName(Account account) {
        return account.getWhite() == 0;
    }

    private boolean isForbid(Account account) {
        return account.getForbid() != 0;
    }

    public boolean isActive(Account account) {
        if (serverSetting.isNeedActive() && account.getActive() == 0) {
            return false;
        } else {
            return true;
        }
    }

    protected GameError checkAuthority(Account account) {
        if (serverSetting.isOpenWhiteName() && isWhiteName(account)) {
            return GameError.NOT_WHITE_NAME;
        }

        if (isForbid(account)) {
            return GameError.FORBID_ACCOUNT;
        }

        return GameError.OK;
    }

    /**
     * appota获取userid
     *
     * @param target
     * @return
     */
    protected static String getPlatIdInTarget(String target) {
        String[] array = target.split("\\|");
        for (int i = 0; i < array.length; i++) {
            String[] item = array[i].split(":");
            if (item != null && "userid".equals(item[0])) {
                return item[1];
            }
        }
        return "";
    }

    protected List<Integer> getRecentServers(Account account) {
        List<Integer> list = new ArrayList<Integer>();
        list.add(account.getFirstSvr());
        list.add(account.getSecondSvr());
        list.add(account.getThirdSvr());
        return list;
    }

    static public Base createPayBackRq(PayInfo payInfo) {
        PayBackRq.Builder builder = PayBackRq.newBuilder();
        builder.setPlatNo(payInfo.platNo);
        builder.setPlatId(payInfo.platId);
        builder.setOrderId(payInfo.orderId);
        builder.setSerialId(payInfo.serialId);
        builder.setServerId(payInfo.serverId);
        builder.setRoleId(payInfo.roleId);
        builder.setAmount(payInfo.amount);
        builder.setPackId(payInfo.packId);
        Base msg = PbHelper.createRqBase(PayBackRq.EXT_FIELD_NUMBER, null, PayBackRq.ext, builder.build());
        return msg;
    }

    public int payToGameServer(PayInfo payInfo) {
        RoleLog role = this.roleInfoDao.queryRoleByLordId(payInfo.roleId);
        if (role == null) {
            LOG.error("pay error role is null roleId={},platNo={},platId={},orderId={},serialId={}", payInfo.roleId, payInfo.platNo, payInfo.platId, payInfo.orderId, payInfo.serialId);
            return 10;
        }
        if (role.getPlatNo() != payInfo.platNo) {
            LOG.error("pay error role platNo error  roleId={},rolePlatNo={},platNo={},platId={},childNo={},realAmount={},orderId={},serialId={}", role.getRoleId(), role.getPlatNo(), payInfo.platNo, payInfo.platId, payInfo.childNo,
                    payInfo.realAmount, payInfo.orderId, payInfo.serialId);
            return 10;
        }
        Pay pay = null;
        if (!payInfo.orderId.startsWith(ODERID_NBBD)) {
            pay = payDao.selectPay(payInfo.platNo, payInfo.orderId);
            // 之前回调过
            if (pay != null && pay.getState() == 1) {
                return 1;
            }

            if (pay == null) {
                pay = createPay(payInfo);
            }
        }
        String url = serverSetting.getServerUrl(payInfo.serverId);
        // 无法取到游戏服地址
        if (url == null) {
            return 2;
        }
        try {
            Base msg = createPayBackRq(payInfo);
            LOG.error("充值通知游戏服 url {}|packets {}", url, msg);
            Base back = HttpHelper.sendMsgToGame(url, msg);
            if (back.getCode() == 200) {
                try {
                    if (pay != null) {
                        LogUtil.pay("pay|" + pay.getServerId() + "|" + pay.getRoleId() + "|" + pay.getPlatNo() + "|" + pay.getPlatId() + "|" + pay.getOrderId() + "|" + pay.getSerialId() + "|" + pay.getAmount() + "|" + DateHelper.displayDateTime(pay.getPayTime()) + "|" + pay.getChildNo());
                    }
                } catch (Exception e) {
                    LOG.error("调用游戏服充值错误 1", e);
                }
                return 0;
            }

            return 3;
        } catch (Exception e) {
            LOG.error("调用游戏服充值错误 2", e);
            return 100;
        }

    }


    /**
     * createPay
     *
     * @param payInfo
     * @return
     */
    protected Pay createPay(PayInfo payInfo) {
        if (payInfo.serialId == null) {
            payInfo.serialId = "";
        }
        Pay pay = new Pay();
        pay.setPlatNo(payInfo.platNo);
        pay.setChildNo(payInfo.childNo);
        pay.setPlatId(payInfo.platId);
        pay.setOrderId(payInfo.orderId);
        pay.setSerialId(payInfo.serialId);
        pay.setServerId(payInfo.serverId);
        pay.setRoleId(payInfo.roleId);
        pay.setState(0);
        pay.setAmount(payInfo.amount);
        pay.setRealAmount(payInfo.realAmount);
        pay.setPackId(payInfo.packId);
        pay.setPayTime(new Date());
        payDao.createPay(pay);
        return pay;
    }

    protected Properties loadProperties(String path, String name) {
        try {
            Resource resource = new ClassPathResource(path + name);
            Properties properties = PropertiesLoaderUtils.loadProperties(resource);
            return properties;
        } catch (IOException e) {
            LOG.error("", e);
        }
        return null;
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        return null;
    }

    /**
     * 角色升级时将角色日志发送到sdk
     */
    public void logRole2sdk(RoleLog role) {
        if (role.getSubject() != null) {
            switch (role.getSubject()) {
                case LogRoleLogin2sdk.EVENT_SUBJECT:
                    if (this instanceof LogRoleLogin2sdk) {
                        ((LogRoleLogin2sdk) this).logRoleLogin2sdk(role);
                    }
                    break;
                case LogRoleCreate2sdk.EVENT_SUBJECT:
                    if (this instanceof LogRoleCreate2sdk) {
                        ((LogRoleCreate2sdk) this).logRoleCreate2sdk(role);
                    }
                    break;
                case LogRoleUp2sdk.EVENT_SUBJECT:
                    if (this instanceof LogRoleUp2sdk) {
                        ((LogRoleUp2sdk) this).logRoleUp2sdk(role);
                    }
                    break;
                default:
                    break;
            }
        }
    }

    public String getAppId() {
        return null;
    }

}
