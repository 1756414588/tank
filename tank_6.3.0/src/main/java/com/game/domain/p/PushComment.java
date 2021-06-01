package com.game.domain.p;

/**
 * IOS 推送信息
 * 
 * @author wanyi <br>
 *         创建角色24小时候推送评论，做没有评价，一个星期后继续推送
 */
public class PushComment {
	private int state; // 推送状态: 0未推送 1推送
	private int lastCommentTime; // 最后一次提交推送的时间
	private int shouldPushTime; // 应该推送的时间

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public int getLastCommentTime() {
		return lastCommentTime;
	}

	public void setLastCommentTime(int lastCommentTime) {
		this.lastCommentTime = lastCommentTime;
	}

	public int getShouldPushTime() {
		return shouldPushTime;
	}

	public void setShouldPushTime(int shouldPushTime) {
		this.shouldPushTime = shouldPushTime;
	}

}
