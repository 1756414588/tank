package com.test.simula.handler.attackEffect;

import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

import java.util.Arrays;
import java.util.List;

/**
 * @author zhangdh
 * @ClassName: GetAttackEffectRsHandler
 * @Description:
 * @date 2017-11-29 14:59
 */
public class GetAttackEffectRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb6.GetAttackEffectRs res = msg.getExtension(GamePb6.GetAttackEffectRs.ext);
        List<CommonPb.AttackEffectPb> list = res.getEffectList();
        for (CommonPb.AttackEffectPb pb : list) {
            LogUtil.info("兵种类型 : " + pb.getType());
            LogUtil.info("当前使用的 特效组ID : " + pb.getUseId());
            LogUtil.info("该兵种当前拥有的特效组 ：" + Arrays.toString(pb.getUnlockList().toArray()));
        }
    }
}
