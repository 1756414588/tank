package com.game.service.teaminstance;

import com.game.domain.CrossPlayer;
import com.game.util.LogUtil;
import com.google.common.cache.Cache;
import com.google.common.cache.CacheBuilder;
import com.google.common.cache.RemovalListener;
import com.google.common.cache.RemovalNotification;

import java.util.concurrent.TimeUnit;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/22 18:37
 * @description：cross player 缓存
 */
public class CrossPlayerCacheLoader {
    private static final Cache<Long, CrossPlayer> crossPlayerCache = CacheBuilder.newBuilder().maximumSize(100000L).initialCapacity(1000).expireAfterAccess(1, TimeUnit.HOURS).removalListener(new RemovalListener<Long, CrossPlayer>() {
        @Override
        public void onRemoval(RemovalNotification<Long, CrossPlayer> removalNotification) {
            //LogUtil.crossInfo("cache crossPlayerCache,cause:{},key:{}", removalNotification.getCause(), removalNotification.getKey());
        }
    }).build();


    public static void put(CrossPlayer crossPlayer) {
        crossPlayerCache.put(crossPlayer.getRoleId(), crossPlayer);
    }

    public static CrossPlayer get(long roleId) {
        return crossPlayerCache.getIfPresent(roleId);
    }

}