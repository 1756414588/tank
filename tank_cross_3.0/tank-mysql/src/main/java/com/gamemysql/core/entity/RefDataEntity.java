package com.gamemysql.core.entity;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:28 @Description :java类作用描述
 *     <p>分组实体类型
 *     <p>K:主键类型 R:外键类型(仅用于对数据分组如果不需要分组可指定主键同时为外键)
 *     <p>此时Primary和Foreign注解不应标记在同一元素上
 */
public interface RefDataEntity<K, R> extends DataEntity<K, R> {}
