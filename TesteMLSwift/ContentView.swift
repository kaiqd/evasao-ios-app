import SwiftUI

struct InputAluno: Codable {
    let faltas: Double
    let nota_media: Double
    let horas_trabalho: Double
    let idade: Double
}

struct PredictRequest: Codable {
    let alunos: [InputAluno]
}

struct PredictResponseItem: Codable {
    let risk_score: Double
    let model_version: String
}

struct PredictResponse: Codable {
    let results: [PredictResponseItem]
}

enum APIError: LocalizedError {
    case invalidURL
    case badStatus(Int)
    case emptyResults
    case decoding(Error)
    case other(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL inválida."
        case .badStatus(let code): return "Erro HTTP \(code)."
        case .emptyResults: return "Resposta vazia do servidor."
        case .decoding(let err): return "Falha ao decodificar: \(err.localizedDescription)"
        case .other(let err): return err.localizedDescription
        }
    }
}

struct APIClient {
    static var baseURL = "http://127.0.0.1:8000"
    
    static func predict(_ aluno: InputAluno) async throws -> PredictResponseItem {
        guard let url = URL(string: "\(baseURL)/predict") else { throw APIError.invalidURL }
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = PredictRequest(alunos: [aluno])
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.badStatus(http.statusCode)
        }
        do {
            let decoded = try JSONDecoder().decode(PredictResponse.self, from: data)
            guard let first = decoded.results.first else { throw APIError.emptyResults }
            return first
        } catch {
            throw APIError.decoding(error)
        }
    }
}

struct ContentView: View {
    @State private var faltas: String = ""
    @State private var notaMedia: String = ""
    @State private var horasTrabalho: String = ""
    @State private var idade: String = ""
    
    @State private var resultado: String = ""
    @State private var riscoPercent: Double?
    @State private var modeloVersao: String?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dados do Aluno")) {
                    TextField("Faltas", text: $faltas)
                        .keyboardType(.numberPad)
                    
                    TextField("Nota Média", text: $notaMedia)
                        .keyboardType(.decimalPad)
                    
                    TextField("Horas de Trabalho", text: $horasTrabalho)
                        .keyboardType(.numberPad)
                    
                    TextField("Idade", text: $idade)
                        .keyboardType(.numberPad)
                    
                }
                
                Section {
                    Button {
                        Task { await preverEvasao() }
                    } label: {
                        HStack {
                            if isLoading { ProgressView() }
                            Text("Prever Evasão")
                        }
                    }
                    .disabled(isLoading)
                }
                
                if !resultado.isEmpty || riscoPercent != nil {
                    Section(header: Text("Resultado")) {
                        VStack(alignment: .leading, spacing: 8) {
                            if let risco = riscoPercent {
                                Text("Risco: \(Int(risco * 100))%")
                                    .font(.headline)
                                    .foregroundStyle(risco >= 0.5 ? .red : .green)
                            }
                            Text(resultado)
                            if let v = modeloVersao {
                                Text("Modelo: \(v)").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Previsão de Evasão")
        }
    }
    
    // MARK: - Helpers
    
    private func parseDouble(_ s: String) -> Double? {
        let normalized = s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(normalized)
    }
    
    private func preverEvasao() async {
        resultado = ""
        riscoPercent = nil
        modeloVersao = nil
        
        guard
            let faltasVal = parseDouble(faltas),
            let notaMediaVal = parseDouble(notaMedia),
            let horasTrabalhoVal = parseDouble(horasTrabalho),
            let idadeVal = parseDouble(idade)
        else {
            resultado = "Preencha todos os campos corretamente."
            return
        }
        
        let aluno = InputAluno(
            faltas: faltasVal,
            nota_media: notaMediaVal,
            horas_trabalho: horasTrabalhoVal,
            idade: idadeVal,
        )
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let item = try await APIClient.predict(aluno)
            riscoPercent = item.risk_score
            modeloVersao = item.model_version
            resultado = (item.risk_score >= 0.5) ? "Evasão provável" : "Sem risco relevante"
        } catch {
            resultado = "Erro: \(error.localizedDescription)"
        }
    }
}

#Preview { ContentView() }
