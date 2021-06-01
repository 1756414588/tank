package com.hotfix;

import com.hundredcent.game.aop.GameClassFileTransformer;
import com.hundredcent.game.aop.annotation.SaveLevel;
import com.hundredcent.game.aop.transformer.AbstractPersisitenceTransformer;

import java.lang.instrument.Instrumentation;

/**
 * @author zhangdh
 * @ClassName: GameAgent
 * @Description:
 * @date 2017-09-21 15:28
 */
public class GameAgent {
    public static Instrumentation inst;

    public GameAgent() {
    }

    public static void agentmain(String agentArgs, Instrumentation inst) {
        System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>UGame Agent start....");
        GameAgent.inst = inst;
    }

    public static void premain(String agentArgs, Instrumentation inst) {
        System.out.println("ugame premain agent start....");
        GameAgent.inst = inst;
        System.out.println(">>>>>>>>>>>>>>>>" + GameAgent.inst);
        System.out.println("UGameAgent loader : " + GameAgent.class.getClassLoader());
        registPartySave();
        registPlayerSave();
        inst.addTransformer(new GameClassFileTransformer());
    }

    private static void registPartySave() {
        /**
         * 注册立即保存军团数据的方法
         */
        AbstractPersisitenceTransformer.registInsertMethod(SaveLevel.IMMEDIATE_PARTY, "com.hundredcent.game.aop.persistence.party.SavePartyOptimizeUtil.immediateSaveParty(%s);");
        AbstractPersisitenceTransformer.registObjectidName("partyId");
    }

    private static void registPlayerSave() {
        /**
         * 注册立即保存玩家数据的方法
         */
        AbstractPersisitenceTransformer.registInsertMethod(SaveLevel.IMMEDIATE, "com.hundredcent.game.aop.persistence.player.SavePlayerOptimizeUtil.immediateSavePlayer(%s);");
        /**
         * 注册闲时保存玩家数据
         */
        AbstractPersisitenceTransformer.registInsertMethod(SaveLevel.IDLE, "com.hundredcent.game.aop.persistence.player.SavePlayerOptimizeUtil.idleSavePlayer(%s, \"%s\");");
        /**
         * 注册触发保存的对象唯一标示 用于调用上面方法时传参
         */
        AbstractPersisitenceTransformer.registObjectidName("lordId");
        AbstractPersisitenceTransformer.registObjectidName("roleId");
    }
}
