package com.orvnge.database.service;

import com.orvnge.database.model.jsonDB;
import com.orvnge.database.model.jsonDB.*;
import org.json.JSONObject;

import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static String URL;

    public static Connection getConnection() throws SQLException {
        try {
            jsonDB json = new jsonDB();
            json.setConn(getConnString());
            //connectionString conn = getConnString();
            URL = "jdbc:postgresql://" + json.getConn().getServer() + ":" + json.getConn().getPort() + "/" + json.getConn().getDatabase();

            Class.forName("org.postgresql.Driver");
            return DriverManager.getConnection(URL, json.getConn().getUser(), json.getConn().getPassword());
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver PostgreSQL não encontrado", e);
        }
    }

    public static connectionString getConnString() {
        connectionString jsonDB = new connectionString();

        String way = "com/orvnge/resources/json/appConfig.json";
        InputStream file = DBConnection.class.getClassLoader().getResourceAsStream(way);
        if (file != null) {
            try {
                InputStreamReader fread = new InputStreamReader(file);
                BufferedReader reader = new BufferedReader(fread);

                StringBuilder sb = new StringBuilder();
                String line = "";

                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }

                JSONObject json = new JSONObject(sb.toString());
                JSONObject obj = json.getJSONObject("ConnectionString");
                jsonDB.setServer(obj.getString("Server"));
                jsonDB.setDatabase(obj.getString("Database"));
                jsonDB.setPort(obj.getInt("Port"));
                jsonDB.setUser(obj.getString("User"));
                jsonDB.setPassword(obj.getString("Password"));

                reader.close();
                fread.close();
            } catch (IOException e) {
               throw new RuntimeException("Erro ao ler o arquivo de configuração", e);
            }
        }
        return jsonDB;
    }
}
