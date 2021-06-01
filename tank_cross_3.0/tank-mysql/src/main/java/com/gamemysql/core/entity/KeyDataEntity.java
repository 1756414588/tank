package com.gamemysql.core.entity;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:27 @Description : * 无分组实体类型 *
 *     <p>* K:主键类型 *
 *     <p>* 此时Primary和Foreign注解应标记在同一元素上
 */
public interface KeyDataEntity<K> extends DataEntity<K, K> {}
