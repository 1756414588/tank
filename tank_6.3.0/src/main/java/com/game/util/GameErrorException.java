/**
 * 
 */
package com.game.util;

import com.game.constant.GameError;

/**
 * @author 丁文渊
 * 下午2:56:10
 */
public class GameErrorException extends Exception {
    /**
     * 
     */
    private static final long serialVersionUID = 1L;
    /**
     * 
     */
    private GameError gameError;
    public GameErrorException(GameError gameError) {
        super();
        this.gameError = gameError;
    }
    /**
     * @return the gameError
     */
    public GameError getGameError() {
        return gameError;
    }
    /**
     * @param gameError the gameError to set
     */
    public void setGameError(GameError gameError) {
        this.gameError = gameError;
    }

}
