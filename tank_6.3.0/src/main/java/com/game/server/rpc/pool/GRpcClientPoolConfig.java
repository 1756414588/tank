package com.game.server.rpc.pool;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/8 11:49
 * @Description :RpcClient 池的配置
 */
public class GRpcClientPoolConfig extends GenericObjectPoolConfig {

    public GRpcClientPoolConfig() {
        super();
        //当连接池资源耗尽时，等待时间，超出则抛异常，默认为-1即永不超时
        this.setMaxWaitMillis(1000);
        //链接池中最大连接数,默认为8
        this.setMaxTotal(2);
        //链接池中最大空闲的连接数,默认也为8
        this.setMaxIdle(2);
        //连接池中最少空闲的连接数,默认为0
        this.setMinIdle(2);
        //默认false，在evictor线程里头，当evictionPolicy.evict方法返回false时，而且testWhileIdle为true的时候则检测是否有效，如果无效则移除
        this.setTestWhileIdle(true);
        // 一次最多检查三个，清理三个
        this.setNumTestsPerEvictionRun(2);
        // 每隔160s 检查一次
        this.setTimeBetweenEvictionRunsMillis(30000L);
        // 闲置时间超过 6小时则为过期 暂时为永久不失效
        this.setMinEvictableIdleTimeMillis(21600000L);

        this.setSoftMinEvictableIdleTimeMillis(21600000L);

    }

    @Override
    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
