package com.orvnge.service.interfaces;

import org.json.JSONArray;

public interface IRelatorio {
    public JSONArray ListarEspelho(String cpf, int idCli);
    public JSONArray ListarMovGrupo(String cpf, int idCli, String mes, int tipoMov);
    public JSONArray ListarMovMes(String cpf, int idCli, String mes, int tipoMov);
    public JSONArray ListarMovTipo(String cpf, int idCli, String mes, int tipoMov);
    public JSONArray ListarTotalMov(String cpf, int idCli, String mes, int tipoMov);
}
