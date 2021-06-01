package com.game.domain.s;

/**
* @ClassName: StaticPendant 
* @Description: 挂件表
* @author
 */
public class StaticPendant {

	private int pendantId;
	private String name;
	private int type;
	private int value;
	private int duration;

	public int getPendantId() {
		return pendantId;
	}

	public void setPendantId(int pendantId) {
		this.pendantId = pendantId;
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

	public int getValue() {
		return value;
	}

	public void setValue(int value) {
		this.value = value;
	}

	public int getDuration() {
		return duration;
	}

	public void setDuration(int duration) {
		this.duration = duration;
	}

}
