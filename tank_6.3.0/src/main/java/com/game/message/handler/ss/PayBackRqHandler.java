/**   
 * @Title: PayBackRsHandler.java    
 * @Package com.game.message.handler.ss    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年11月7日 上午11:09:11    
 * @version V1.0   
 */
package com.game.message.handler.ss;

import java.util.Date;

import com.game.dao.impl.p.PayDao;
import com.game.domain.p.Pay;
import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.PayBackRq;
import com.game.server.GameServer;
import com.game.service.PayService;

/**
 * @ClassName: PayBackRsHandler
 * @Description:
 * @author ZhangJun
 * @date 2015年11月7日 上午11:09:11
 * 
 */
public class PayBackRqHandler extends ServerHandler {

    /**
     * Overriding: action
     * 
     * @see com.game.server.ICommand#action()
     */
    @Override
    public void action() {
        // Auto-generated method stub
        // LogUtil.info("PayBackRqHandler action");
        PayBackRq req = msg.getExtension(PayBackRq.ext);
        PayService payService = GameServer.ac.getBean(PayService.class);
        if (!req.getOrderId().startsWith(PayService.ODERID_NBBD)) {
            PayDao payDao = GameServer.ac.getBean(PayDao.class);
            Pay pay = payDao.selectPay(req.getPlatNo(), req.getOrderId());
            if (pay != null) {
                return;
            }

            // LogUtil.info("PayBackRqHandler action");

            pay = new Pay();
            pay.setPlatNo(req.getPlatNo());
            pay.setPlatId(req.getPlatId());
            pay.setOrderId(req.getOrderId());
            pay.setSerialId(req.getSerialId());
            pay.setServerId(req.getServerId());
            pay.setRoleId(req.getRoleId());
            pay.setAmount(req.getAmount());
            pay.setPayTime(new Date());
            payDao.createPay(pay);
        }

        // LogUtil.info("PayBackRqHandler pay logic");
        payService.payBackRq(req, this);
    }

}
