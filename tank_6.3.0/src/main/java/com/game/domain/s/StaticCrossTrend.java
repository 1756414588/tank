package com.game.domain.s;

/**
* @ClassName: StaticCrossTrend 
* @Description: 对应s_sever_war_integral表 暂时没用到
* @author
 */
public class StaticCrossTrend {
	private int trendId;
	private int type;
	private String name;
	private String content;
	private String param;

	public int getTrendId() {
		return trendId;
	}

	public void setTrendId(int trendId) {
		this.trendId = trendId;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public String getParam() {
		return param;
	}

	public void setParam(String param) {
		this.param = param;
	}

	@Override
	public String toString() {
		return "StaticCrossTrend [trendId=" + trendId + ", type=" + type + ", name=" + name + ", content=" + content
				+ ", param=" + param + "]";
	}
}
