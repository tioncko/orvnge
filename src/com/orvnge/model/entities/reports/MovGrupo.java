package com.orvnge.model.entities.reports;

public class MovGrupo {
    private String nomeGrupo;
    private String totalGrupo;

    public MovGrupo() {}

    public MovGrupo(String nomeGrupo, String totalGrupo) {
        this.nomeGrupo = nomeGrupo;
        this.totalGrupo = totalGrupo;
    }

    public String getNomeGrupo() {
        return nomeGrupo;
    }

    public void setNomeGrupo(String nomeGrupo) {
        this.nomeGrupo = nomeGrupo;
    }

    public String getTotalGrupo() {
        return totalGrupo;
    }

    public void setTotalGrupo(String totalGrupo) {
        this.totalGrupo = totalGrupo;
    }
}
