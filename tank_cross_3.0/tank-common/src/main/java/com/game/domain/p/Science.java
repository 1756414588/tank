package com.game.domain.p;

import com.game.grpc.proto.team.CrossTeamProto;

/**
 * @author ChenKui
 * @version 创建时间：2015-8-28 下午3:25:02
 * @declare
 */
public class Science {
    private int scienceId;
    private int scienceLv;

    public int getScienceId() {
        return scienceId;
    }

    public void setScienceId(int scienceId) {
        this.scienceId = scienceId;
    }

    public int getScienceLv() {
        return scienceLv;
    }

    public void setScienceLv(int scienceLv) {
        this.scienceLv = scienceLv;
    }

    public Science() {
    }

    public Science(int scienceId, int scienceLv) {
        this.scienceId = scienceId;
        this.scienceLv = scienceLv;
    }

    public Science(CrossTeamProto.Science science) {
        this.scienceId = science.getScienceId();
        this.scienceLv = science.getScienceLv();
    }
}
