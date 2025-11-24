<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>OrangePay Login</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/login.css">
</head>
<body>
<div class="layout">
    <main class="auth-side">
      <section class="login-card">
        <form id="loginForm" novalidate action="<%= request.getContextPath() %>/login" method="post">
          <div class="field">
            <label for="user">Usuário</label>
            <input id="user" type="text" name="user" required />
          </div>

          <div class="field">
            <label for="senha">Senha</label>
            <input id="senha" type="password" name="senha" required />
          </div>

          <div class="actions-row">
            <a class="create-link" href="<%= request.getContextPath() %>/pages/cadastroUsuario.jsp">Criar Conta</a>
            <a class="create-link" href="<%= request.getContextPath() %>/pages/recuperarUsuario.jsp">Esqueceu a Senha?</a>
            <button class="btn-entrar" type="submit">Entrar</button>
          </div>
        </form>

        <div id="alertPlaceholder" class="alert-login"></div>

        <script>
          const contextPath = '<%= request.getContextPath() %>/pages/dashboard.jsp';

          const serverMessage = '<%=
              request.getAttribute("empty") != null ? request.getAttribute("empty") :
              request.getAttribute("null") != null ? request.getAttribute("null") :
              request.getAttribute("error") != null ? request.getAttribute("error") : "" %>';
        </script>
      </section>
    </main>
  </div>
  <script src="<%=request.getContextPath()%>/js/scripts.js"></script>
</body>
</html>
