package com.test.simula.handler;

import com.game.pb.GamePb1;
import com.game.pb.GamePb2;
import com.game.pb.GamePb5;
import com.game.pb.GamePb6;
import com.test.simula.handler.activity.redbag.*;
import com.test.simula.handler.activity.medalofhonor.GetActMedalofhonorInfoRsHandler;
import com.test.simula.handler.activity.monopoly.BuyOrBuseEnergyRsHandler;
import com.test.simula.handler.activity.monopoly.GetMonopolyRsHandler;
import com.test.simula.handler.activity.monopoly.ThrowDiceRsHandler;
import com.test.simula.handler.activity.simple.GetActLotteryExploreRsHandler;
import com.test.simula.handler.attackEffect.GetAttackEffectRsHandler;
import com.test.simula.handler.weapon.GetSecretWeaponInfoRsHandler;
import com.test.simula.handler.weapon.LockedWeaponBarRsHandler;
import com.test.simula.handler.weapon.StudyWeaponSkillRsHandler;
import com.test.simula.handler.weapon.UnlockWeaponBarRsHandler;
import com.test.simula.handler.world.AttackPosRsHandler;

import java.util.HashMap;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: SimulaMessageRegist
 * @Description:
 * @date 2017/5/12 18:46
 */
public class SimulaMessageRegist {
    public static Map<Integer, ISimulaHandler> handlers = new HashMap<>();

    static {
        handlers.put(GamePb1.BeginGameRs.EXT_FIELD_NUMBER, new SimulaBeginGameHandler());
        handlers.put(GamePb1.RoleLoginRs.EXT_FIELD_NUMBER, new SimulaRoleLoginRsHandler());
        handlers.put(GamePb1.GetLordRs.EXT_FIELD_NUMBER, new SimulaGetLordRsHandler());

        //荣誉勋章活动
        handlers.put(GamePb5.GetActMedalofhonorInfoRs.EXT_FIELD_NUMBER, new GetActMedalofhonorInfoRsHandler());

        //秘密武器
        handlers.put(GamePb6.GetSecretWeaponInfoRs.EXT_FIELD_NUMBER, new GetSecretWeaponInfoRsHandler());
        handlers.put(GamePb6.UnlockWeaponBarRs.EXT_FIELD_NUMBER, new UnlockWeaponBarRsHandler());
        handlers.put(GamePb6.LockedWeaponBarRs.EXT_FIELD_NUMBER, new LockedWeaponBarRsHandler());
        handlers.put(GamePb6.StudyWeaponSkillRs.EXT_FIELD_NUMBER, new StudyWeaponSkillRsHandler());

        //攻击特效
        handlers.put(GamePb6.GetAttackEffectRs.EXT_FIELD_NUMBER, new GetAttackEffectRsHandler());

        //大富翁活动
        handlers.put(GamePb5.GetMonopolyInfoRs.EXT_FIELD_NUMBER, new GetMonopolyRsHandler());
        handlers.put(GamePb5.BuyOrUseEnergyRs.EXT_FIELD_NUMBER, new BuyOrBuseEnergyRsHandler());
        handlers.put(GamePb5.ThrowDiceRs.EXT_FIELD_NUMBER, new ThrowDiceRsHandler());

        //世界地图
        handlers.put(GamePb2.AttackPosRs.EXT_FIELD_NUMBER, new AttackPosRsHandler());

        //探宝积分活动
        handlers.put(GamePb5.GetActLotteryExploreRs.EXT_FIELD_NUMBER, new GetActLotteryExploreRsHandler());

        //抢红包活动
        handlers.put(GamePb5.GetActRedBagInfoRs.EXT_FIELD_NUMBER, new GetActRedBagInfoRsHandler());
        handlers.put(GamePb5.DrawActRedBagStageAwardRs.EXT_FIELD_NUMBER, new DrawActRedBagStageAwardRsHandler());
        handlers.put(GamePb5.GetActRedBagListRs.EXT_FIELD_NUMBER, new GetActRedBagListRsHandler());
        handlers.put(GamePb5.GrabRedBagRs.EXT_FIELD_NUMBER, new GrabRedBagRsHandler());
        handlers.put(GamePb5.SendActRedBagRs.EXT_FIELD_NUMBER, new SendActRedBagRsHandler());
        handlers.put(GamePb6.SynSendActRedBagRq.EXT_FIELD_NUMBER, new SynSendActRedBagHandler());
    }

    public static ISimulaHandler getCommand(int cmd) {
        return handlers.get(cmd);
    }
}
