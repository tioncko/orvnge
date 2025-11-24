<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Recuperar senha | OrangePay</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/cadastroUsuario.css">
</head>
<body class="page-body">
  <main class="wrap">
    <section class="card">
      <h2>Conta de usuário</h2>
      <p class="subtitle">Tem certeza que quer deletar sua conta?</p>

      <form id="recForm">
        <div class="actions">
          <button type="button" class="btn btn-accent" onclick="deletarUsuario()">Sim</button>
          <a class="btn btn-outline" href="<%= request.getContextPath()%>/pages/dashboard.jsp">Não</a>
        </div>
      </form>
    </section>
  </main>
  <script>
    const cpf = ${sessionScope.usr.cpf};

    function deletarUsuario() {
      fetch("<%= request.getContextPath() %>/deletar-usuario?cpf=" + cpf, {
        method: "DELETE"
      })
              .then(response => {
                if(response.ok) {
                  alert("Conta deletada com sucesso!");
                  window.location.href = "<%= request.getContextPath() %>/pages/login.jsp";
                } else {
                  alert("Erro ao deletar conta!");
                }
              }).catch(error => {
                console.error("Erro ao deletar conta:", error);
                alert("Erro ao deletar conta!");
              });
    }
  </script>
</body>
</html>
