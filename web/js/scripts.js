let chartInstance = null;
document.addEventListener("DOMContentLoaded", () => {

    const linhaCruz = {
        id: 'linhaCruz',
        afterDraw(chart) {
            const {
                ctx,
                chartArea: { left, right},
                scales: { y }
            } = chart;

                    // --- Posição da linha no eixo Y (horizontal) ---
            const valorHorizontal = 0; // valor onde você quer a linha horizontal
            const yPos = y.getPixelForValue(valorHorizontal);

            ctx.save();
            ctx.beginPath();
            ctx.lineWidth = 1;
            ctx.strokeStyle = "rgba(15, 52, 66, 95)";

            // === Linha horizontal ===
            ctx.moveTo(left, yPos);
            ctx.lineTo(right, yPos);

            ctx.stroke();
            ctx.restore();
        }
    };


// Acessa a variável globalmente definida no JSP
    window.carregarGrafico = async function () {
    //async function carregarGrafico() {
        try {
            if (!window.contextPathGrafico) {
                return;
            }

            const response = await fetch(window.contextPathGrafico);
            const dados = await response.json();

            const labels = dados.map(d => d.nomeGrupo);
            const valores = dados.map(d => d.totalGrupo);

            const max = Math.round(valores.reduce((a, b) => Math.max(a, b)))

            const ctx = document.getElementById("graficoBarras").getContext("2d");
            // 🔥 Se já existe gráfico, destruímos ANTES
            if (chartInstance) {
                chartInstance.destroy();
            }

            chartInstance = new Chart(ctx, {
                type: "bar",
                data: {
                    labels: labels,
                    datasets: [{
                        label: "Clientes",
                        data: valores,
                        backgroundColor: [
                            "rgb(161,97,2)",
                            "rgb(175,43,3)"
                        ],
                        borderColor: [
                            "rgb(255,150,0)",
                            "rgb(213,100,68)"
                        ],
                        borderWidth: 2,
                        borderRadius: 6 // cantos arredondados nas barras
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            titleFont: { size: 14, weight: '600' },
                            bodyFont: { size: 12 }
                        }
                    },
                    scales: {
                        x: {
                            grid: { display: false }, // remove TODAS as grades horizontais
                            ticks: { font: { size: 12 }, color: '#495057' }
                        },
                        y: {
                            min: 0,
                            max: max,
                            grid: { display: false }, // remove TODAS as grades verticais
                            beginAtZero: true,
                            ticks: { font: { size: 12 }, color: '#495057', stepSize: 100 }
                        }
                    }
                },
                plugins: [linhaCruz]  // <<< plugin ativado aqui
            });
        } catch (err) {
            console.error("Erro ao carregar gráfico:", err);
        }
    }
    carregarGrafico();

    /*
    // --- Botão de criar conta ---
    const btnMap = [
        { id: "btnCriar"},
        { id: "btnAlterar"}
    ];

    function redirectPage(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        window.location.href = contextPath;
    }

    btnMap.forEach(item => {
        const btn = document.getElementById(item.id);
        if (btn) {
            btn.addEventListener("click", ev=> redirectPage(ev))
        }
    })*/

    // --- Bloco de alerta do login ---
    const alertPlaceholder = document.getElementById("alertPlaceholder");

    if (typeof serverMessage !== "undefined" && serverMessage !== "") {
        alertPlaceholder.innerHTML =
            '<div class="alert alert-danger">' + //alert-dismissible fade show mt-3" role="alert">' +
            serverMessage +
            //'<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
            '</div>';
    }

    // --- Função de carregar páginas no iframe ---
    window.loadPage = function(page) {
        document.getElementById("contentFrame").src = page;
    }

    // --- Menu lateral ---
    document.querySelectorAll('.menu-btn').forEach(btn => {
        btn.addEventListener('click', function (e) {
            document.querySelectorAll('.menu-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');

            // se quiser usar data-target no lugar de onclick inline
            const target = this.dataset.target;
            if (target) {
                loadPage(`pages/${target}.jsp`);
            }
        });
    });
});