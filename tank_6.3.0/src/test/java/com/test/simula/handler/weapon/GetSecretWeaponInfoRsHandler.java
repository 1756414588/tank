package com.test.simula.handler.weapon;

import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: GetSecretWeaponInfoRsHandler
 * @Description:
 * @date 2017-11-15 10:10
 */
public class GetSecretWeaponInfoRsHandler implements ISimulaHandler {

    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb6.GetSecretWeaponInfoRs res = msg.getExtension(GamePb6.GetSecretWeaponInfoRs.ext);
        List<CommonPb.SecretWeapon> weaponList = res.getWeaponList();
        for (CommonPb.SecretWeapon weapon : weaponList) {
            LogUtil.info("秘密武器ID :" + weapon.getId());
            LogUtil.info("洗练栏信息 :");
            int idx = 1;
            for (CommonPb.SecretWeaponBar bar : weapon.getBarList()) {
                LogUtil.info(String.format("栏目 :%d, 技能ID :%d, 是否锁定 ：%s", idx++, bar.getSid(), bar.getLocked()));
            }
        }
    }
}
