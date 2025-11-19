package com.orvnge.database.model;

public class jsonDB {
    private connectionString conn;

    public jsonDB() {}
    public connectionString getConn() {
        return conn;
    }
    public void setConn(connectionString conn) {
        this.conn = conn;
    }

    public static class connectionString {
        private String server;
        private String database;
        private int port;
        private String user;
        private String password;

        public connectionString() {}

        public String getServer() {
            return server;
        }
        public void setServer(String server) {
            this.server = server;
        }

        public String getDatabase() {
            return database;
        }
        public void setDatabase(String database) {
            this.database = database;
        }

        public int getPort() {
            return port;
        }
        public void setPort(int port) {
            this.port = port;
        }

        public String getUser() {
            return user;
        }
        public void setUser(String user) {
            this.user = user;
        }

        public String getPassword() {
            return password;
        }
        public void setPassword(String password) {
            this.password = password;
        }
    }
}
