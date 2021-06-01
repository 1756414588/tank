package com.game.domain.s;

/**
 * @ClassName StaticSystem.java
 * @Description 全局常量配置信息
 * @author TanDonghai
 * @date 创建时间：2016年9月3日 上午11:23:53
 *
 */
public class StaticSystem {
	private int id;// 配置参数唯一标识
	private String name;// 名称，说明
	private String value;// 参数的值

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	@Override
	public String toString() {
		return "StaticSystem [id=" + id + ", name=" + name + ", value=" + value + "]";
	}
}
