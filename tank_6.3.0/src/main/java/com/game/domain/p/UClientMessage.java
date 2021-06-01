package com.game.domain.p;

import java.util.Date;
/**
* @ClassName: UClientMessage 
* @Description: 客户端消息记录 目前没用到
* @author
 */
public class UClientMessage {
	private long keyId;
	private long lordId;
	private String plat;
	private String version;
	private String definition;
	private String msgData;
	private Date createDate;

	public long getKeyId() {
		return keyId;
	}

	public void setKeyId(long keyId) {
		this.keyId = keyId;
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public String getPlat() {
		return plat;
	}

	public void setPlat(String plat) {
		this.plat = plat;
	}

	public String getVersion() {
		return version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	public String getDefinition() {
		return definition;
	}

	public void setDefinition(String definition) {
		this.definition = definition;
	}

	public String getMsgData() {
		return msgData;
	}

	public void setMsgData(String msgData) {
		this.msgData = msgData;
	}

	public Date getCreateDate() {
		return createDate;
	}

	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}


}
