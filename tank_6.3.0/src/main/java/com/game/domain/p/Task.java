package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-15 下午4:32:41
 * @Description: 任务
 */

public class Task {

	private int taskId;
	private long schedule;
	private int status;
	private int accept;

	public int getTaskId() {
		return taskId;
	}

	public void setTaskId(int taskId) {
		this.taskId = taskId;
	}

	public long getSchedule() {
		return schedule;
	}

	public void setSchedule(long schedule) {
		this.schedule = schedule;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public int getAccept() {
		return accept;
	}

	public void setAccept(int accept) {
		this.accept = accept;
	}

	public Task(int taskId) {
		this.taskId = taskId;
	}
}
