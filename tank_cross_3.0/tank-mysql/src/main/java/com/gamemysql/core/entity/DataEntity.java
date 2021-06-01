package com.gamemysql.core.entity;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:16 @Description :java类作用描述 * 缺省实体类型 *
 *     <p>* K:主键类型(要保证分组内唯一标识) * R:外键类型(仅用于对数据分组如果需要整表缓存可以不指定使用Object标识) *
 *     <p>* 实体类根据业务需求分为三类 * 1 以外键分组的以外键为组进行数据缓存或查询 * 2 以主键分组的或者理解为不分组的直接以主键进行缓存或查询 * 3
 *     整表分组的提供整表查询和整表缓存 *
 *     <p>* 分别对应相应的dao
 */
public interface DataEntity<K, R> {}
