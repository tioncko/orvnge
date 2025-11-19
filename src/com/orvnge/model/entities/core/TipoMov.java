package com.orvnge.model.entities.core;

public class TipoMov {
    private int idTipoMov;
    private String nomeTipoMov;

    public TipoMov() {
    }

    public TipoMov(int idTipoMov, String nomeTipoMov) {
        this.idTipoMov = idTipoMov;
        this.nomeTipoMov = nomeTipoMov;
    }

    public int getIdTipoMov() {
        return idTipoMov;
    }

    public void setIdTipoMov(int idTipoMov) {
        this.idTipoMov = idTipoMov;
    }

    public String getNomeTipoMov() {
        return nomeTipoMov;
    }

    public void setNomeTipoMov(String nomeTipoMov) {
        this.nomeTipoMov = nomeTipoMov;
    }

    @Override
    public String toString() {
        return "TipoMov [idTipoMov=" + idTipoMov + ", nomeTipoMov=" + nomeTipoMov + "]";
    }
}
