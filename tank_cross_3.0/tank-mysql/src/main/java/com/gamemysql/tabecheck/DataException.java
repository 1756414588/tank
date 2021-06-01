package com.gamemysql.tabecheck;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 15:42 @Description :数据层异常
 */
public class DataException extends RuntimeException {
  public DataException(String message, Throwable cause) {
    super(message, cause);
  }

  public DataException(String message) {
    super(message);
  }

  public DataException(Throwable cause) {
    super(cause);
  }
}
