package com.orvnge.model.entities.reports;

public class MovTipo {
    private int id;
    private String mesAno;
    private String nomeGrupo;
    private String infoDesc;
    private String valor;

    public MovTipo() {}

    public MovTipo(int id, String mesAno, String nomeGrupo, String infoDesc, String valor) {
        this.id = id;
        this.mesAno = mesAno;
        this.nomeGrupo = nomeGrupo;
        this.infoDesc = infoDesc;
        this.valor = valor;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMesAno() {
        return mesAno;
    }

    public void setMesAno(String mesAno) {
        this.mesAno = mesAno;
    }

    public String getNomeGrupo() {
        return nomeGrupo;
    }

    public void setNomeGrupo(String nomeGrupo) {
        this.nomeGrupo = nomeGrupo;
    }

    public String getInfoDesc() {
        return infoDesc;
    }

    public void setInfoDesc(String infoDesc) {
        this.infoDesc = infoDesc;
    }

    public String getValor() {
        return valor;
    }

    public void setValor(String valor) {
        this.valor = valor;
    }
}
