package com.game.service;

import com.game.constant.Constant;
import com.game.datamgr.BaseDataMgr;
import com.game.datamgr.StaticIniDataMgr;
import com.game.domain.s.StaticSystem;
import com.game.server.GameContext;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class LoadService {
    @Autowired
    private StaticIniDataMgr staticIniDataMgr;

    /**
     * 重加载s_system表数据，并重新初始化相关数据
     */
    public void loadSystem() {

        LogUtil.info("开始加载ini配置 s_system表");

        staticIniDataMgr.initSystem();
        Constant.loadSystem(this);

        LogUtil.info("s_system表 加载完成 ");
    }

    /**
     * 加载全部ini配置
     */
    public void reloadAll() {
        Map<String, BaseDataMgr> beansOfType = GameContext.getAc().getBeansOfType(BaseDataMgr.class);

        for (Map.Entry<String, BaseDataMgr> dataMgr : beansOfType.entrySet()) {

            LogUtil.info("*************** 开始加载 {} ***************", dataMgr.getValue().getClass().getName());

            try {
                dataMgr.getValue().init();
            } catch (Exception e) {
                e.printStackTrace();
                LogUtil.error("加载出错 " + dataMgr.getValue().getClass().getName(), e);
            }
        }

        LogUtil.info("***************配置表全部加载完成***************");
    }


    /**
     * 根据systemId获取对应的值，以int类型返回
     *
     * @param systemId
     * @param defaultVaule 当表中找不到该配置项时，返回的默认值
     * @return
     */
    public int getIntegerSystemValue(int systemId, int defaultVaule) {
        StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
        if (null != ss) {
            return Integer.valueOf(ss.getValue());
        }
        return defaultVaule;
    }

    public long getLongSystemValue(int systemId, long defaultVaule) {
        StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
        if (null != ss) {
            return Long.valueOf(ss.getValue());
        }
        return defaultVaule;
    }

    public float getFloatSystemValue(int systemId, float defaultVaule) {
        StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
        if (null != ss) {
            return Float.valueOf(ss.getValue());
        }
        return defaultVaule;
    }

    public double getDoubleSystemValue(int systemId, double defaultVaule) {
        StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
        if (null != ss) {
            return Double.valueOf(ss.getValue());
        }
        return defaultVaule;
    }

    public String getStringSystemValue(int systemId, String defaultVaule) {
        StaticSystem ss = staticIniDataMgr.getSystemConstantById(systemId);
        if (null != ss) {
            return ss.getValue();
        }
        return defaultVaule;
    }
}
