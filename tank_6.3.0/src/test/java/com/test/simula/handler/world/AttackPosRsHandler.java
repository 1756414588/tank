package com.test.simula.handler.world;

import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb2;
import com.game.util.LogUtil;
import com.game.util.MapHelper;
import com.game.util.Tuple;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

/**
 * @author zhangdh
 * @ClassName: AttackPosRsHandler
 * @Description:
 * @date 2017-12-23 15:08
 */
public class AttackPosRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb2.AttackPosRs res = msg.getExtension(GamePb2.AttackPosRs.ext);
        CommonPb.Army army = res.getArmy();
        LogUtil.info("部队ID :" + army.getKeyId());
        Tuple<Integer, Integer> turple = MapHelper.reducePos(army.getTarget());
        LogUtil.info(String.format("部队目标 x :%d, y :%d", turple.getA(), turple.getB()));
    }
}
