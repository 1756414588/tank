package com.hundredcent.game.aop.transformer.impl;

import com.hundredcent.game.aop.transformer.AbstractPersisitenceTransformer;

/**
 * Tank相关项目数据持久化相关Transformer
 *
 * @author Tandonghai
 * @date 2018-01-12 15:42
 */
public class TankPersistenceTransformer extends AbstractPersisitenceTransformer {

    private static final String TANK_GAME_PACKAGE_PREFIX = "com/game/";

    /**
     * 坦克项目需要监听的持久化类所在包路径
     */
    private static final String TANK_DOMAIN_PACKAGE = "com.game.domain";

    @Override
    public String basePackage() {
        return TANK_GAME_PACKAGE_PREFIX;
    }

    @Override
    public String[] requiredPackages() {
        return new String[] { TANK_DOMAIN_PACKAGE };
    }
}
