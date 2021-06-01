/**
 * @Title: PayConfirm.java
 * @Package com.account.msg.impl.server
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年11月7日 下午4:14:24
 * @version V1.0
 */
package com.account.msg.impl.server;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.dao.impl.PayDao;
import com.account.msg.MessageBase;
import com.account.util.LogUtil;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.InnerPb.PayConfirmRq;
import com.game.pb.InnerPb.PayConfirmRs;

/**
 * @ClassName: PayConfirm
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年11月7日 下午4:14:24
 *
 */
@Component
public class PayConfirm implements MessageBase {
    @Autowired
    private PayDao payDao;

    /**
     * Overriding: execute
     *
     * @param request
     * @return
     * @see com.account.msg.MessageBase#execute(net.sf.json.JSONObject)
     */
    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        return null;
    }

    /**
     * Overriding: execute
     *
     * @param req
     * @param builder
     * @return
     * @see com.account.msg.MessageBase#execute(java.lang.Object, com.game.pb.BasePb.Base.Builder)
     */
    @Override
    public GameError execute(Object req, Builder builder) {
        // TODO Auto-generated method stub
        PayConfirmRq msg = (PayConfirmRq) req;

        LogUtil.pay("PayConfirm|" + msg.getPlatNo() + "|" + msg.getOrderId() + "|" + msg.getAddGold());
        payDao.updateState(msg.getPlatNo(), msg.getOrderId(), 1, msg.getAddGold());

        PayConfirmRs.Builder rsBuilder = PayConfirmRs.newBuilder();
        PayConfirmRs rs = rsBuilder.build();
        builder.setExtension(PayConfirmRs.ext, rs);
        return GameError.OK;
    }

}
