package com.gamemysql.cache;

import com.gamemysql.cache.local.DbThreadFactory;
import com.gamemysql.core.entity.DataEntity;
import com.gamemysql.core.entity.DataEntityOperator;
import com.gamemysql.dao.query.QueryFilter;
import com.gamemysql.jdbc.JdbcDataAccessor;
import com.gamemysql.jdbc.SqlJdbcDataAccessor;
import com.google.common.base.Preconditions;
import com.google.common.cache.CacheLoader;
import com.google.common.cache.LoadingCache;
import com.google.common.collect.HashMultiset;
import com.google.common.collect.Maps;
import com.google.common.collect.Multiset;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.util.*;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.ReentrantReadWriteLock;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/11 11:22 @Description :java类作用描述
 */
public class DataCacheManager {
    private static Logger logger = LoggerFactory.getLogger("SAVE");

    private static final long FLUSH_PERIOD_SECONDS = 180;
    private final DataSource dataSource;

    private final ConcurrentMap<Class<? extends DataEntity>, JdbcDataAccessor> mappers =
            Maps.newConcurrentMap();
    private final Multiset<Class<? extends DataEntity>> permanentCache = HashMultiset.create();
    private final ConcurrentMap<Class<? extends DataEntity>, LoadingCache> caches =
            Maps.newConcurrentMap();

    private final ConcurrentMap<Primary, EnumMap<EntityOperateType, AtomicInteger>> entityOperates =
            Maps.newConcurrentMap();

    private final ScheduledExecutorService scheduledExecutorService = Executors.newSingleThreadScheduledExecutor(new DbThreadFactory("db-flush"));

    private final ReentrantReadWriteLock operateLock = new ReentrantReadWriteLock();
    private final ReentrantReadWriteLock operateFlushLock = new ReentrantReadWriteLock();

    private final CacheLoader<Foreign, Map> cacheLoader =
            new CacheLoader<Foreign, Map>() {
                @Override
                public Map load(final Foreign ref) throws Exception {
                    if (ref != null) {
                        Map byForeign = getMapper(ref.getType()).getMapByForeign(ref.getRef());
                        return byForeign;
                    }
                    return null;
                }
            };

    public void init(Class<? extends DataEntity> clazz) {
        final JdbcDataAccessor mapper = getMapper(clazz);
        caches.put(
                clazz, CacheFactory.createCache(clazz, mapper.getEntityOperator().featchType, cacheLoader));
        mapper.checkDatabaseTableWithEntity();
    }

    public LoadingCache<Foreign, Map> getCache(Class<? extends DataEntity> type) {
        return caches.get(type);
    }

    public DataCacheManager(DataSource dataSource) {
        this.dataSource = dataSource;
        this.scheduledExecutorService.scheduleWithFixedDelay(
                new Runnable() {
                    @Override
                    public void run() {
                        try {
                            flush();
                        } catch (Exception e) {
                            logger.error("loop flush error", e);
                        }
                    }
                },
                FLUSH_PERIOD_SECONDS,
                FLUSH_PERIOD_SECONDS,
                TimeUnit.SECONDS);
    }

    public JdbcDataAccessor getMapper(final Class<? extends DataEntity> type) {
        JdbcDataAccessor dao = mappers.get(type);
        if (null == dao) {
            dao = new SqlJdbcDataAccessor<>(new DataEntityOperator<>(type), dataSource);
            JdbcDataAccessor old = mappers.putIfAbsent(type, dao);
            if (old != null) {
                dao = old;
            }
        }
        return dao;
    }

    private void addOperate(Primary primary, EntityOperateType type) {
        this.addOperate(primary, type, 1);
    }

    private void addOperate(Primary primary, EntityOperateType type, int times) {
        operateLock.readLock().lock();
        EnumMap<EntityOperateType, AtomicInteger> enumMap = entityOperates.get(primary);
        if (enumMap == null) {
            operateLock.readLock().unlock();
            operateLock.writeLock().lock();
            if (enumMap == null) {
                EnumMap<EntityOperateType, AtomicInteger> tmp = new EnumMap<>(EntityOperateType.class);
                for (EntityOperateType operateType : EntityOperateType.values()) {
                    tmp.put(operateType, new AtomicInteger());
                }
                EnumMap<EntityOperateType, AtomicInteger> old = entityOperates.putIfAbsent(primary, tmp);
                if (old == null) {
                    enumMap = tmp;
                } else {
                    enumMap = old;
                }
            }
            operateLock.readLock().lock();
            operateLock.writeLock().unlock();
        }
        enumMap.get(type).addAndGet(times);
        if (type == EntityOperateType.INSERT) { // 如果是插入操作就将之前的删除操作取消掉,防止系统反复使用同一ID的数据
            enumMap.get(EntityOperateType.DELETE).set(0);
        }

        operateLock.readLock().unlock();
    }

    public <K, R, V extends DataEntity<K, R>> boolean insert(final V record) {
        Preconditions.checkNotNull(record, "insert target not null");

        Class<? extends DataEntity> type = record.getClass();
        JdbcDataAccessor<K, R, V> mapper = getMapper(type);
        K primary = mapper.getEntityOperator().getPrimary(record);
        R foreign = mapper.getEntityOperator().getForeign(record);

        Preconditions.checkNotNull(primary, "insert primary not null");
        if ((primary instanceof Long)) {
            if ((Long) primary == 0) {
                //                logger.debug(String.format(" insert primary is 0,cache add %s: %s",
                // type.getSimpleName(), JSON.toJSONString(record)));
            }
        }
        Map<K, V> byForeign = gets(type, foreign);
        byForeign.put(primary, record);
        addOperate(new Primary(type, primary, foreign), EntityOperateType.INSERT);
        //        logger.debug(String.format("cache add %s:%s-%s", type.getSimpleName(), foreign,
        // primary));
        return true;
    }

    public <K, R, V extends DataEntity<K, R>> Map<K, V> gets(final Class<V> type) {
        Map<K, V> ret = Collections.EMPTY_MAP;
        try {
            final ConcurrentMap<Foreign, Map> map = getCache(type).asMap();
            if (!map.isEmpty()) {
                ret = new HashMap<>(map.size());
                for (Map.Entry<Foreign, Map> entry : map.entrySet()) {
                    ret.putAll(entry.getValue());
                }
            }
            //            logger.debug(String.format("cache all hit %s", type.getSimpleName()));
        } catch (Throwable e) {
            logger.error(String.format("cache all miss %s", type.getSimpleName()));
            logger.error("", e);
        }
        return ret;
    }

    public <K, R, V extends DataEntity<K, R>> Map<K, V> gets(
            final Class<V> type, final QueryFilter<K, R, V> filter) {
        Map<K, V> ret = new HashMap<>();
        Map<K, V> values = gets(type);
        if (values != null && !values.isEmpty()) {
            for (Map.Entry<K, V> entry : values.entrySet()) {
                if (filter.stopped()) {
                    break;
                }
                if (filter.check(entry.getValue())) {
                    ret.put(entry.getKey(), entry.getValue());
                }
            }
        }
        return ret;
    }

    public <K, R, V extends DataEntity<K, R>> Map<K, V> gets(
            final Class<? extends DataEntity> type, final R ref) {
        Map<K, V> ret = null;
        try {
            ret = (Map<K, V>) getCache(type).getUnchecked(new Foreign(type, ref));
            //            logger.debug(String.format("cache hit %s:%s", type.getSimpleName(), ref));
        } catch (Throwable e) {
            logger.error(String.format("cache miss %s:%s", type.getSimpleName(), ref));
            if (!(e instanceof CacheLoader.InvalidCacheLoadException)) {
                logger.error("getById", e);
            }
        }
        return ret;
    }

    public <K, R, V extends DataEntity<K, R>> V get(final Class<V> type, final R ref, final K key) {
        V v = null;

        Map<K, V> ret = gets(type, ref);
        if (ret != null && !ret.isEmpty()) {
            v = ret.get(key);
        }

        return v;
    }

    public <K, R, V extends DataEntity<K, R>> List<V> getList(final Class<V> type) {
        List<V> ret = new LinkedList<>();
        Map<K, V> values = gets(type);
        if (values != null && !values.isEmpty()) {
            for (Map.Entry<K, V> entry : values.entrySet()) {
                ret.add(entry.getValue());
            }
        }

        return ret;
    }

    public <K, R, V extends DataEntity<K, R>> Map<K, V> gets(
            final Class<V> type, final R ref, final QueryFilter<K, R, V> filter) {
        Map<K, V> ret = new HashMap<>();
        Map<K, V> values = gets(type, ref);
        if (values != null && !values.isEmpty()) {
            for (Map.Entry<K, V> entry : values.entrySet()) {
                if (filter.stopped()) {
                    break;
                }
                if (filter.check(entry.getValue())) {
                    ret.put(entry.getKey(), entry.getValue());
                }
            }
        }
        return ret;
    }

    public <K, R, V extends DataEntity<K, R>> List<V> getList(
            final Class<V> type, final R ref, final QueryFilter<K, R, V> filter) {
        List<V> ret = new LinkedList<>();
        Map<K, V> values = gets(type, ref);
        if (values != null && !values.isEmpty()) {
            for (Map.Entry<K, V> entry : values.entrySet()) {
                if (filter.stopped()) {
                    break;
                }
                if (filter.check(entry.getValue())) {
                    ret.add(entry.getValue());
                }
            }
        }

        return ret;
    }

    public <K, R, V extends DataEntity<K, R>> List<V> getList(final Class<V> type, final R ref) {
        List<V> ret = new LinkedList<>();
        Map<K, V> values = gets(type, ref);
        if (values != null && !values.isEmpty()) {
            for (Map.Entry<K, V> entry : values.entrySet()) {
                ret.add(entry.getValue());
            }
        }

        return ret;
    }

    public <K, R, V extends DataEntity<K, R>> V get(
            final Class<V> type, final R ref, final QueryFilter<K, R, V> filter) {
        Map<K, V> values = gets(type, ref);
        if (values != null && !values.isEmpty()) {
            for (Map.Entry<K, V> entry : values.entrySet()) {
                if (filter.stopped()) {
                    break;
                }
                if (!filter.stopped() && filter.check(entry.getValue())) {
                    return entry.getValue();
                }
            }
        }

        return null;
    }

    public <K, R, V extends DataEntity<K, R>> boolean update(final V record) {
        Preconditions.checkNotNull(record, "update target not null");

        Class<? extends DataEntity> type = record.getClass();
        JdbcDataAccessor<K, R, V> mapper = getMapper(type);
        K primary = mapper.getEntityOperator().getPrimary(record);
        R foreign = mapper.getEntityOperator().getForeign(record);

        Map<K, V> byForeign = gets(type, foreign);
        byForeign.put(primary, record);
        addOperate(new Primary(type, primary, foreign), EntityOperateType.UPDATE);
        //        logger.debug(String.format("cache update %s:%s-%s", type.getSimpleName(), foreign,
        // primary));
        return true;
    }

    public <K, R, V extends DataEntity<K, R>> boolean delete(final V record) {
        Preconditions.checkNotNull(record, "delete target not null");
        Class<? extends DataEntity> type = record.getClass();
        JdbcDataAccessor<K, R, V> mapper = getMapper(type);
        K primary = mapper.getEntityOperator().getPrimary(record);
        R foreign = mapper.getEntityOperator().getForeign(record);

        Map<K, V> byForeign = gets(type, foreign);
        byForeign.remove(primary);
        addOperate(new Primary(type, primary, foreign), EntityOperateType.DELETE);
        //        logger.debug(String.format("cache invalidate %s:%s-%s", type.getSimpleName(), foreign,
        // primary));
        return true;
    }

    public void shutdown() throws InterruptedException {
        this.scheduledExecutorService.shutdown();
        this.scheduledExecutorService.awaitTermination(FLUSH_PERIOD_SECONDS, TimeUnit.SECONDS);
        for (int i = 0; i < 5; i++) {
            this.flush();
            Thread.sleep(1000 * 2);
        }
    }

    @SuppressWarnings("unchecked")
    public void flush() {

        logger.info(" ===== DataCacheManager flush data to db ==================");

        operateLock.writeLock().lock();
        @SuppressWarnings("rawtypes")
        Map<Primary, EnumMap<EntityOperateType, AtomicInteger>> entityOperates =
                Maps.newHashMap(this.entityOperates);
        this.entityOperates.clear();
        operateLock.writeLock().unlock();
        try {
            long recordNum = 0;
            long insertNum = 0;
            long updateNum = 0;
            long deleteNum = 0;
            long lastInsertNum = 0;
            long lastUpdateNum = 0;
            long lastDeleteNum = 0;

            operateFlushLock.writeLock().lock();

            for (@SuppressWarnings("rawtypes")
                    Map.Entry<Primary, EnumMap<EntityOperateType, AtomicInteger>> mapEntry :
                    entityOperates.entrySet()) {
                recordNum++;
                @SuppressWarnings("rawtypes")
                Primary primary = mapEntry.getKey();
                EnumMap<EntityOperateType, AtomicInteger> operates = mapEntry.getValue();
                // 数据状态
                // 1.新数据 有insert 但也有可能有update或delete操作
                // 2.旧数据 没有insert操作 但是有update或delete操作
                int insert = operates.get(EntityOperateType.INSERT).get();
                int update = operates.get(EntityOperateType.UPDATE).get();
                int delete = operates.get(EntityOperateType.DELETE).get();

                insertNum += insert;
                updateNum += update;
                deleteNum += delete;

                @SuppressWarnings("rawtypes")
                Class type = primary.getType();
                @SuppressWarnings("rawtypes")
                JdbcDataAccessor mapper = getMapper(type);
                Object id = primary.getId();
                Object ref = primary.getRef();
                @SuppressWarnings({"rawtypes", "unchecked"})
                DataEntity dbEntity = get(type, ref, id);

                try {
                    if (delete > 0) { // 如果有删除操作 1:检查是否是insert的新数据 直接可以忽略掉 2:老数据
                        // 删除操作
                        if (insert > 0) {
                            // 新数据被删除可以直接忽略,因为还没有写入持久化存储
                        } else {
                            mapper.delete(mapper.getEntityOperator().newInstance(id, ref));
                            lastDeleteNum++;
                        }
                    } else if (insert > 0 || update > 0) { // 如果是插入或者更新操作
                        // 1:检查是否是insert的新数据
                        // 插入持久化存储 2:老数据
                        // 更新持久化存储
                        if (dbEntity != null) {
                            if (insert > 0) {
                                mapper.insert(dbEntity);
                                lastInsertNum++;
                            } else {
                                mapper.update(dbEntity);
                                lastUpdateNum++;
                            }
                            // } else {
                            // 数据可能在后续操作中被删除
                        }
                    }
                } catch (Throwable e) {
                    logger.error("flush entity error " + primary, e);
                }
            }
            logger.info(
                    "flush recordNum:{"
                            + recordNum
                            + "},insertNum:{"
                            + insertNum
                            + "},updateNum:{"
                            + updateNum
                            + "},deleteNum:{"
                            + deleteNum
                            + "},lastInsertNum:{"
                            + lastInsertNum
                            + "},lastUpdateNum:{"
                            + lastUpdateNum
                            + "},lastDeleteNum:{"
                            + lastDeleteNum
                            + "}");

        } catch (Throwable e) {
            logger.error("flush error", e);
        } finally {
            operateFlushLock.writeLock().unlock();
        }
    }
}
