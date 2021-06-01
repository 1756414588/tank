package com.hundredcent.game.aop.transformer;

import com.hundredcent.game.util.AgentLogUtil;
import javassist.CtClass;
import javassist.NotFoundException;

/**
 * @author Tandonghai
 * @date 2018-01-20 13:31
 */
abstract class AbstractPrepareTransformer {

    protected boolean hassAssignedInterface(CtClass cc, String interfaceName) {
        try {
            for (CtClass ctClass : cc.getInterfaces()) {
                if (ctClass.getName().equals(interfaceName)) {
                    return true;
                }
            }
        } catch (NotFoundException e) {
            AgentLogUtil.error(String.format("检查类是否实现了指定接口出错, class:%s, interface:%s", cc.getName(), interfaceName), e);
        }
        return false;
    }

    /**
     * 具体执行逻辑
     *
     * @param cc
     * @return
     */
    protected abstract boolean doPrepareTransformer(CtClass cc);

}
