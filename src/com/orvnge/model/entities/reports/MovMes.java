package com.orvnge.model.entities.reports;

public class MovMes {
    private String mesAno;
    private String totalMes;

    public MovMes() {}

    public MovMes(String mesAno, String totalMes) {
        this.mesAno = mesAno;
        this.totalMes = totalMes;
    }

    public String getMesAno() {
        return mesAno;
    }

    public void setMesAno(String mesAno) {
        this.mesAno = mesAno;
    }

    public String getTotalMes() {
        return totalMes;
    }

    public void setTotalMes(String totalMes) {
        this.totalMes = totalMes;
    }
}
