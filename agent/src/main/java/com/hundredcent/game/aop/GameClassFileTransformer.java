package com.hundredcent.game.aop;

import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.security.ProtectionDomain;
import java.util.ArrayList;
import java.util.List;

import javassist.CannotCompileException;
import javassist.ClassPool;
import javassist.CtClass;

import com.hundredcent.game.aop.persistence.player.SavePlayerOptimizeUtil;
import com.hundredcent.game.aop.transformer.AbstractClassFileTransformer;
import com.hundredcent.game.aop.transformer.impl.TankPersistenceTransformer;
import com.hundredcent.game.util.AgentLogUtil;

/**
 * 游戏项目Class文件Transformer总入口
 *
 * @author Tandonghai
 * @date 2018-01-09 11:01
 */
public class GameClassFileTransformer implements ClassFileTransformer {
    protected List<AbstractClassFileTransformer> transformers;

    protected List<String> gameBasePackages;

    protected boolean inited;

    /**
     * ClassFileTransformer相关功能总开关，主要用于首次功能测试，避免影响其他功能；如果功能测试通过，该开关可以取消
     */
    private boolean mainSwitch = true;

    public GameClassFileTransformer() {
        SavePlayerOptimizeUtil.setMainTransformer(this);
    }

    public void setMainSwitch(boolean mainSwitch) {
        this.mainSwitch = mainSwitch;
    }

    protected synchronized void initData() {
        if (inited) {
            return;
        }

        // 注册所有的transformer
        transformers = new ArrayList<>();
        transformers.add(new TankPersistenceTransformer());

        // 统计所有transformer的包过滤路径
        gameBasePackages = new ArrayList<>();
        for (AbstractClassFileTransformer transformer : transformers) {
            gameBasePackages.add(transformer.basePackage());
        }
        inited = true;
    }

    @Override
    public byte[] transform(ClassLoader loader, String className, Class<?> classBeingRedefined,
            ProtectionDomain protectionDomain, byte[] classfileBuffer) throws IllegalClassFormatException {
        // 当开关关闭时，不做任何操作
        if (!mainSwitch) {
            return null;
        }

        if (!inited) {
            initData();
        }

        if (!classFilter(className)) {
            return null;
        }

        if (className.contains("/")) {
            className = className.replaceAll("/", ".");
        }

        try {
            CtClass cc = ClassPool.getDefault().get(className);

            boolean wasChanged = false;
            for (AbstractClassFileTransformer transformer : transformers) {
                if (transformer.transform(cc)) {
                    wasChanged = true;
                }
            }

            // Class没有被改变时，返回null
            if (!wasChanged) {
                return null;
            }

            return cc.toBytecode();
        } catch (CannotCompileException e) {
            AgentLogUtil.error("ClassFileTransformer出错", e);
        } catch (Exception e) {
            AgentLogUtil.error("ClassFileTransformer出错", e);
        }

        return null;
    }

    /**
     * 对传入类进行简单的目录检查，过滤掉不是游戏项目的类
     *
     * @param className
     * @return
     */
    protected boolean classFilter(String className) {
        if (null == className) {
            return false;
        }

        // 如果未设置包名限制，默认允许所有的类通过检查
        if (null == gameBasePackages || gameBasePackages.isEmpty()) {
            return true;
        }

        for (String packagePrefix : gameBasePackages) {
            if (className.startsWith(packagePrefix)) {
                return true;
            }
        }
        return false;
    }
}
