package com.game.domain.s;

import java.util.List;

/**
 * 要塞战进修效果
 * 
 * @author wanyi
 *
 */
public class StaticFortressAttr {

	private int id;
	private int level;
	private String name;
	private int type;
	private List<List<Integer>> effect;
	private String _desc;
	private int price;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public List<List<Integer>> getEffect() {
		return effect;
	}

	public void setEffect(List<List<Integer>> effect) {
		this.effect = effect;
	}

	public String get_desc() {
		return _desc;
	}

	public void set_desc(String _desc) {
		this._desc = _desc;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}
	

}
