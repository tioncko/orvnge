<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Configurações | OrangePay</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/config.css">
</head>
<body class="page-body">

  <!-- FRAGMENTO -->
  <main id="page-fragment" class="op-config-fragment">
    <section class="config-card">
      <h2 class="title">Informações do sistema</h2>

      <form id="formConfig" class="config-grid" autocomplete="off">
        <!-- Versão -->
        <div class="field">
          <label class="lbl" style="align-content: center">Versão</label>
          <p class="versao">v1.0.0</p>
        </div>
      </form>

      <div id="msg" class="msg" role="status"></div>
    </section>
  </main>

</body>
</html>
