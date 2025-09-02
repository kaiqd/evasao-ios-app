Evasão iOS App

Aplicativo iOS desenvolvido em SwiftUI, que consome uma API em Python para demonstrar o fluxo de predição de evasão acadêmica.

📌 Objetivo

Este aplicativo foi criado como uma versão inicial para mostrar a integração entre um modelo de Machine Learning (rodando no backend em Python/FastAPI) e uma interface em Swift.
O foco é demonstrar o funcionamento básico: o usuário informa alguns dados do aluno e recebe de volta uma previsão de risco de evasão.

⸻

🚀 Como rodar o projeto

1. Pré-requisitos
	•	Xcode 15+
	•	iOS 17+ (simulador ou dispositivo físico)
	•	Backend rodando localmente ou hospedado (veja evasao-ml-api)

2. Configuração

No arquivo APIClient dentro do projeto, ajuste a variável baseURL para apontar para o servidor Python:

struct APIClient {
    static var baseURL = "http://127.0.0.1:8000" // simulador
    // ou "http://SEU-IP-LOCAL:8000" para rodar em dispositivo físico
}

3. Executar

Abra o projeto no Xcode e rode no simulador ou dispositivo.
Digite os dados de exemplo e pressione Prever Evasão.
O app enviará os dados para a API e exibirá a probabilidade de risco.

⸻

📡 Exemplo de fluxo
	1.	Usuário informa:
	•	Faltas: 25
	•	Nota Média: 60.5
	•	Horas de Trabalho: 20
	•	Idade: 22
	2.	O app envia para o endpoint /predict da API.
	3.	O backend retorna um JSON com a probabilidade de evasão.
	4.	O resultado é exibido no app em texto e cor (verde/vermelho).

