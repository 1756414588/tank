package com.hundredcent.game.aop.transformer;

import javassist.CannotCompileException;
import javassist.CtClass;
import javassist.CtMethod;
import com.hundredcent.game.aop.domain.IPlayerSave;
import com.hundredcent.game.util.AgentLogUtil;

/**
 * @author Tandonghai
 * @date 2018-01-20 13:33
 */
class PlayerPrepareTransformer extends AbstractPrepareTransformer {
    /**
     * 玩家登录操作
     */
    public static final String MOD_PLAYER_LOGIN = "com.hundredcent.game.aop.persistence.player.SavePlayerOptimizeUtil.playerLogin(%s, %s);";
    /**
     * 玩家离线操作
     */
    public static final String MOD_PLAYER_LOGOUT = "com.hundredcent.game.aop.persistence.player.SavePlayerOptimizeUtil.playerLogout(%s);";

    @Override
    public boolean doPrepareTransformer(CtClass cc) {
        if (hassAssignedInterface(cc, IPlayerSave.class.getName())) {
            return doPlayerTransform(cc);
        }
        return false;
    }

    private boolean doPlayerTransform(CtClass cc) {
        boolean reslut = false;
        for (CtMethod method : cc.getDeclaredMethods()) {
            if ("playerLogin".equals(method.getName())) {
                AgentLogUtil.debug("进入PlayerPrepareTransformer playerLogin");
                String insertMethod = String.format(MOD_PLAYER_LOGIN, "objectId()", "now");
                try {
                    AgentLogUtil.debug(String.format("playerLogin注入, method:%s.%s(), insertMethod:%s", cc.getName(), method.getName(), insertMethod));
                    method.insertBefore(insertMethod);
                    reslut = true;
                } catch (CannotCompileException e) {
                    AgentLogUtil.error(String.format("playerLogin注入出错, method:%s.%s(), insertMethod:%s", cc.getName(), method.getName(), insertMethod), e);
                }
            } else if ("playerLogout".equals(method.getName())) {
                String insertMethod = String.format(MOD_PLAYER_LOGOUT, "objectId()");
                try {
                    AgentLogUtil.debug(String.format("playerLogout注入, method:%s.%s(), insertMethod:%s", cc.getName(), method.getName(), insertMethod));
                    method.insertAfter(insertMethod);
                    reslut = true;
                } catch (CannotCompileException e) {
                    AgentLogUtil.error(String.format("playerLogout注入出错, method:%s.%s(), insertMethod:%s", cc.getName(), method.getName(), insertMethod), e);
                }
            }
        }
        return reslut;
    }
}