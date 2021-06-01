package com.game.domain.p.corss;
/**没用到*/
public class CompteRound {

	private int roundNum;

	private int win;

	private int reportKey;

	private int detail;

	public int getRoundNum() {
		return roundNum;
	}

	public void setRoundNum(int roundNum) {
		this.roundNum = roundNum;
	}

	public int getWin() {
		return win;
	}

	public void setWin(int win) {
		this.win = win;
	}

	public int getReportKey() {
		return reportKey;
	}

	public void setReportKey(int reportKey) {
		this.reportKey = reportKey;
	}

	public CompteRound(int roundNum, int win, int reportKey, int detail) {
		super();
		this.roundNum = roundNum;
		this.win = win;
		this.reportKey = reportKey;
		this.detail = detail;
	}

	public int getDetail() {
		return detail;
	}

	public void setDetail(int detail) {
		this.detail = detail;
	}

	public CompteRound() {
		super();
	}
}
