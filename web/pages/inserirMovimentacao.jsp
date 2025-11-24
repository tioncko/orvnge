<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Cadastro | OrangePay</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/cadastro.css">
</head>
<body class="page-body">

<!-- FRAGMENTO -->
<main id="page-fragment" class="op-cadastro-fragment">
  <div class="op-wrap cadastro-container">
    <section class="op-card">

      <header class="card-head">
        <div>
          <span class="op-chip">INSERIR DADO</span>
          <h1 class="op-title">Cadastro de Transação</h1>
          <p class="op-subtitle">Registre despesas ou receitas para alimentar seu dashboard.</p>
        </div>

        <nav class="head-actions">
          <a href="<%= request.getContextPath()%>/pages/cadastroMovimentacao.jsp"
             data-page="<%= request.getContextPath()%>/pages/cadastroMovimentacao.jsp"
             class="btn btn-outline" onclick="window.location.href='cadastroMovimentacao.jps'">Tabela
          </a>
        </nav>
      </header>

      <form id="formTransacao" class="op-form" autocomplete="off" novalidate method="post" action="<%= request.getContextPath()%>/cadastrar-mov?">
        <div class="grid">

          <div class="field">
            <label for="data">Data</label>
            <input type="date" id="data" required name="dataMov">
            <small class="err" data-for="data"></small>
          </div>

          <div class="field">
            <label for="valor">Valor</label>
            <div class="money">
              <span>R$</span>
              <input type="text" id="valor" name="valor" required>
            </div>
            <small class="err" data-for="valor"></small>
          </div>

          <div class="grid">

            <div class="field">
              <label for="operacao">Conta</label>
              <select id="operacao" required name="idConta">
                <option value="">- Selecione -</option>
              </select>
              <small class="err" data-for="operacao"></small>

              <!--pensar no conceito dessa tela aqui-->
            </div>

            <div class="field" style="grid-column: span 2;">
              <label for="obs">Observação</label>
              <input id="obs" name="descricao" placeholder="Ex.: Cartão Nubank">
            </div>

            <div class="field" style="grid-column: span 2;">
              <label for="tipo">Centro de custo / Grupo</label>
              <select id="tipo" required name="idGrupoMov">
                <option value="">- Selecione -</option>
              </select>
              <small class="err" data-for="tipo"></small>
            </div>

          </div>
        </div>

        <div class="actions">
          <button type="submit" class="btn btn-accent" id="btnSalvar">Salvar</button>
          <button type="button" class="btn btn-danger" id="btnCancelarEdit" style="display:none;">Cancelar edição</button>
        </div>

        <div id="msg" class="msg" role="status"></div>
      </form>
    </section>
  </div>
</main>

<script>
  window.onload = async function() {
    await carregarTipo();
    await carregarGrupoMov();
  };

  const id = ${sessionScope.usr.idCli};

  async function carregarTipo() {
    const params = new URLSearchParams();
    params.append("idCli", id);

    //const resposta = await fetch("<%= request.getContextPath() %>/listar-tipo-conta?");
    const resposta = await fetch("<%= request.getContextPath() %>/listar-conta-usuario?" + params.toString());
    const json = await resposta.json();
    console.log(json);

    const obj = document.querySelector("#operacao");
    obj.innerHTML = "";

    json.forEach(c => {
      const linha = "<option value='" + c.idConta + "'>" + c.conta + "</option>";
      //const linha = "<option value='" + c.idTipoConta + "'>" + c.nomeTipoConta + "</option>";
      obj.innerHTML += linha;
    });
  }

  async function carregarGrupoMov() {
    const resposta = await fetch("<%= request.getContextPath() %>/listar-grupo-mov?");
    const json = await resposta.json();

    const obj = document.querySelector("#tipo");
    obj.innerHTML = "";

    json.forEach(c => {
      const linha = "<option value='" + c.idGrupoMov + "'>" + c.nomeGrupoMov + "</option>";
      obj.innerHTML += linha;
    });
  }
</script>


</body>
</html>
