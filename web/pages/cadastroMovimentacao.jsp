<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Tabela | OrangePay</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/cadastroMovimentacao.css">
</head>
<body class="page-body">

  <!-- FRAGMENTO -->
  <main id="page-fragment" class="op-cadastro-tabela-fragment">
    <section class="op-card">
      <header class="head">
        <div>
          <span class="chip">LANÇAMENTOS</span>
          <h2 class="title">Tabela de transações</h2>
          <p class="subtitle">Dados vindos do cadastro</p>
        </div>
        <div class="head-actions">
          <!-- link "Inserir novo" removido -->
        </div>
      </header>

      <div class="toolbar">
        <select id="filtroMes" class="input">
          <option value="">Todos os meses</option>
          <option value="JAN">JAN</option>
          <option value="FEV">FEV</option>
          <option value="MAR">MAR</option>
          <option value="ABR">ABR</option>
          <option value="MAI">MAI</option>
          <option value="JUN">JUN</option>
          <option value="JUL">JUL</option>
          <option value="AGO">AGO</option>
          <option value="SET">SET</option>
          <option value="OUT">OUT</option>
          <option value="NOV">NOV</option>
          <option value="DEZ">DEZ</option>
        </select>
        <select id="filtroTipo" class="input">
          <option value="">- Selecione o tipo de movimentação -</option>
        </select>
      </div>

      <div class="table-wrap">
        <table class="big-table" id="tabelaMovimentacao">
          <thead>
            <tr>
              <th>DATA</th>
              <th>CENTRO DE CUSTO</th>
              <th>AÇÕES</th>
              <th>VALOR</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
        <div id="noData" class="no-data" hidden>Nenhum lançamento</div>
      </div>

      <div class="table-actions">
        <button class="action" id="btnIncluir" onclick="inserirMovimentacao()">Inserir</button>
        <button class="action" id="btnAlterar" onclick="editarMovimentacao()">Alterar</button>
        <button class="action text-danger" id="btnExcluir" onclick="excluirMovimentacao()">Excluir</button>
      </div>
    </section>
  </main>

  <script>
    const id = ${sessionScope.usr.idCli};
    const cpf = ${sessionScope.usr.cpf};

    async function carregarMovimentacao() {
      const select = document.getElementById("filtroMes");
      let mesSelecionado = getMonth(select.value); // JAN -> 01

      const selectTipo = document.getElementById("filtroTipo");
      let tipoSelecionado = selectTipo.value;

      const params = new URLSearchParams();
      params.append('cpf', cpf);
      const atual = getMonthByDate();

      if(mesSelecionado === "") {
        params.append("mes", atual);
      } else {
        params.append("mes", mesSelecionado);
      }
      //params.append("mes", mesSelecionado);
      params.append("idtipoMov", tipoSelecionado);

      const resposta = await fetch("<%= request.getContextPath() %>/listar-mov-tipo?" + params.toString());
      const json = await resposta.json();

      const tbody = document.querySelector("#tabelaMovimentacao tbody");
      tbody.innerHTML = "";

      json.forEach(c => {
        const linha =
                "<tr data-id=" + c.id + ">" +
                "<td>" + c.mesAno + "</td>" +
                "<td>" + c.nomeGrupo + "</td>" +
                "<td>" + c.infoDesc + "</td>" +
                "<td>" + c.valor + "</td>" +
                "</tr>";
        tbody.innerHTML += linha;
      });
    }
    document.getElementById("filtroMes").addEventListener("change", carregarMovimentacao);
    document.getElementById("filtroTipo").addEventListener("change", carregarMovimentacao);

    async function carregarTipo() {
      const resposta = await fetch("<%= request.getContextPath() %>/listar-tipo-mov?");
      const json = await resposta.json();

      const obj = document.querySelector("#filtroTipo");
      obj.innerHTML = "";

      json.forEach(c => {
        const linha = "<option value='" + c.idTipoMov + "'>" + c.nomeTipoMov + "</option>";
        obj.innerHTML += linha;
      });
    }

    let newid = null;
    window.onload = async function () {
      await carregarTipo();
      await carregarMovimentacao();

      const tbody = document.querySelector("#tabelaMovimentacao tbody");

      tbody.addEventListener("click", function(e) {
        const tr = e.target.closest("tr");
        if (!tr) return;

        tbody.querySelectorAll("tr").forEach(r => r.classList.remove("table-primary"));
        tr.classList.add("table-primary");

        newid = tr.dataset.id;
        console.log("Selecionado:", newid);
      });
    };

    function inserirMovimentacao() {
      window.location.href = "<%= request.getContextPath() %>/pages/inserirMovimentacao.jsp";
    }

    function editarMovimentacao() {
      const params = new URLSearchParams();
      params.append("id", newid);
      window.location.href = "<%= request.getContextPath() %>/pages/atualizarMovimentacao.jsp?" + params.toString();
      console.log("<%= request.getContextPath() %>/pages/atualizarMovimentacao.jsp?" + params.toString());
    }

    function excluirMovimentacao() {
      fetch('<%= request.getContextPath() %>/deletar-mov?idMov=' + newid, {
        method: 'DELETE'
      })
              .then(response => {
                if(response.ok){
                  alert('Movimentação excluída com sucesso!');
                  location.reload(); // atualiza a tabela
                } else {
                  alert('Erro ao excluir movimentação');
                }
              })
              .catch(error => console.error(error));
    }
  </script>
  <script>
    window.getMonth = function (mes) {
      switch (mes) {
        case "JAN": return "01";
        case "FEV": return "02";
        case "MAR": return "03";
        case "ABR": return "04";
        case "MAI": return "05";
        case "JUN": return "06";
        case "JUL": return "07";
        case "AGO": return "08";
        case "SET": return "09";
        case "OUT": return "10";
        case "NOV": return "11";
        case "DEZ": return "12";
        default: return "";
      }
    }

    window.getMonthExtension = function (mes) {
      switch (mes) {
        case "01": return "Janeiro";
        case "02": return "Fevereiro";
        case "03": return "Março";
        case "04": return "Abril";
        case "05": return "Maio";
        case "06": return "Junho";
        case "07": return "Julho";
        case "08": return "Agosto";
        case "09": return "Setembro";
        case "10": return "Outubro";
        case "11": return "Novembro";
        case "12": return "Dezembro";
        default: return "";
      }
    }

    window.getMonthByDate = function () {
      const data = new Date();
      return ('0'+ (data.getMonth() + 1)).slice(-2);
    }

    window.getFormatMoney = function(value) {
      const money = new Intl.NumberFormat('pt-BR', {style: 'currency', currency: 'BRL'});
      return money.format(value);
    }
  </script>

</body>
</html>
