package com.game.common;

/**
 * @ClassName TankException.java
 * @Description 坦克项目自定义异常类
 * @author TanDonghai
 * @date 创建时间：2017年3月17日 上午11:50:42
 *
 */
public class TankException extends Exception {
	private static final long serialVersionUID = 1L;

	private int code; // 错误码

	public TankException() {
		super();
	}

	public TankException(String message) {
		super(message);
	}

	public TankException(int code, String message) {
		super(message);
		this.code = code;
	}

	public TankException(String message, Throwable t) {
		super(message, t);
	}

	public int getCode() {
		return code;
	}

	public void setCode(int code) {
		this.code = code;
	}

	@Override
	public String toString() {
		return "TankException [code=" + code + "]";
	}

}
