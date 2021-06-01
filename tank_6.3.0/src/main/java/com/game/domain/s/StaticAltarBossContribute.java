package com.game.domain.s;

public class StaticAltarBossContribute {
//	CREATE TABLE `s_altar_boss_contribute` (
//			  `id` int(11) NOT NULL,
//			  `type` int(11) NOT NULL COMMENT 'type:1铁 2石油 3铜 4钛 5水晶',
//			  `count` int(11) NOT NULL COMMENT 'count:可捐献次数',
//			  `exp` int(11) NOT NULL COMMENT 'exp:捐献获得的经验值',
//			  `contribute` int(11) NOT NULL COMMENT 'contribute:捐献获得的贡献值',
//			  `price` int(11) NOT NULL COMMENT 'price:捐献消耗',
//			  `desc` varchar(255) NOT NULL COMMENT 'desc：描述',
//			  PRIMARY KEY (`id`)
//			) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	
	
	private int id;
	private int type;
	private int count;
	private int exp;
	private int contribute;
	private int price;
	private String desc;
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getType() {
		return type;
	}
	public void setType(int type) {
		this.type = type;
	}
	
	public int getCount() {
		return count;
	}
	public void setCount(int count) {
		this.count = count;
	}
	public int getExp() {
		return exp;
	}
	public void setExp(int exp) {
		this.exp = exp;
	}
	public int getContribute() {
		return contribute;
	}
	public void setContribute(int contribute) {
		this.contribute = contribute;
	}
	public int getPrice() {
		return price;
	}
	public void setPrice(int price) {
		this.price = price;
	}
	public String getDesc() {
		return desc;
	}
	public void setDesc(String desc) {
		this.desc = desc;
	}
	@Override
	public String toString() {
		return "StaticAltarBossContribute [id=" + id + ", type=" + type + ", count=" + count + ", exp=" + exp
				+ ", contribute=" + contribute + ", price=" + price + ", desc=" + desc + "]";
	}

	
	
	
}
