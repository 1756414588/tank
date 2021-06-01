package com.game.server.rpc.pool;

import org.apache.commons.pool2.PooledObjectFactory;
import org.apache.commons.pool2.impl.GenericObjectPool;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;

/**
 * 连接池
 *
 * @param <T>
 */
public abstract class Pool<T> {

    private final GenericObjectPool<T> internalPool;

    public Pool(final GenericObjectPoolConfig poolConfig, PooledObjectFactory<T> factory) {
        this.internalPool = new GenericObjectPool<>(factory, poolConfig);
    }

    /**
     * 借出对象
     *
     * @return
     */
    public T getResource() {
        try {
            return internalPool.borrowObject();
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            throw new ServiceException("无法从连接池获得连接，可能是目标服务没有开启", e);
        }
    }

    /**
     * 归还对象
     *
     * @param resource
     */
    public void returnResource(final T resource) {
        try {
            if (resource != null) {
                internalPool.returnObject(resource);
            }
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            throw new ServiceException("无法把连接归还到连接池", e);
        }
    }

    /**
     * 销毁对象
     *
     * @param resource
     */
    public void invalidateObject(final T resource) {
        try {
            internalPool.invalidateObject(resource);
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            throw new ServiceException("无法把连接归还到连接池", e);
        }
    }

    /**
     * 关闭连接池
     */
    public void destroy() {
        try {
            internalPool.close();
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            throw new ServiceException("无法销毁连接池", e);
        }
    }

    public GenericObjectPool<T> getPool() {
        return internalPool;
    }
}