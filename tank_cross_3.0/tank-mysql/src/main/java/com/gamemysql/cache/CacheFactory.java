package com.gamemysql.cache;

import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.DataEntity;
import com.google.common.cache.*;
import org.apache.log4j.Logger;

import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/11 12:05 @Description :定时清除缓存
 */
public class CacheFactory {
    public static Logger logger = Logger.getLogger("ERROR");
    private static final int CACHE_EXPIRE_HOURS = 1;

    /**
     * 如果是启动就加载到数据库的 就使用永久缓存 是使用时候加载数据的 就定时一小时清除
     *
     * @param clazz
     * @param featchType
     * @param cacheLoader
     * @return
     */
    public static final LoadingCache createCache(Class<? extends DataEntity> clazz, Table.FeatchType featchType, CacheLoader<Foreign, Map> cacheLoader) {
        if (featchType == Table.FeatchType.START) {
            return CacheBuilder.newBuilder().build(cacheLoader);
        } else {
            return CacheBuilder.newBuilder().expireAfterAccess(CACHE_EXPIRE_HOURS, TimeUnit.HOURS).removalListener(new RemovalListener<Foreign, Map>() {
                @Override
                public void onRemoval(RemovalNotification<Foreign, Map> notification) {
                    logger.info("cache removal,cause:{" + notification.getCause() + "},key:{" + notification.getKey() + "}");
                }
            }).build(cacheLoader);
        }
    }
}