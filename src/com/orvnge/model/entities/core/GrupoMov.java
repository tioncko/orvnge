package com.orvnge.model.entities.core;

public class GrupoMov {
    private int idGrupoMov;
    private String nome;
    private TipoMov tipoMov;

    public GrupoMov() {}

    public GrupoMov(int idGrupoMov, String nome, TipoMov tipoMov) {
        this.idGrupoMov = idGrupoMov;
        this.nome = nome;
        this.tipoMov = tipoMov;
    }

    public int getIdGrupoMov() {
        return idGrupoMov;
    }

    public void setIdGrupoMov(int idGrupoMov) {
        this.idGrupoMov = idGrupoMov;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public TipoMov getTipoMov() {
        return tipoMov;
    }

    public void setTipoMov(TipoMov tipoMov) {
        this.tipoMov = tipoMov;
    }

    @Override
    public String toString() {
        return "GrupoMov [idGrupoMov=" + idGrupoMov + ", nome=" + nome + ", tipoMov=" + tipoMov + "]";
    }
}
