#Script de automação para ler petições de clientes integrar com API e mandar para documento.

require 'pdf-reader'
require 'docx'
require 'json'

textos_joao = []
conteudo_modelo_maria = ""
docs_path = File.join(__dir__, '..', 'Docs', '*')

Dir.glob(docs_path).each do |arquivo|
  extensao = File.extname(arquivo).downcase
  nome_arquivo = File.basename(arquivo)

  begin
    texto = case extensao
            when '.pdf'
              reader = PDF::Reader.new(arquivo)
              reader.pages.map(&:text).join("\n").strip
            when '.docx'
              doc = Docx::Document.open(arquivo)
              doc.paragraphs.map(&:text).join("\n").strip
            else
              next
            end

    if texto.empty?
      warn "Aviso: #{nome_arquivo} sem texto extraível."
      next
    end

    if nome_arquivo.downcase.include?('maria') || nome_arquivo.downcase.include?('modelo')
      conteudo_modelo_maria = texto
    else
      textos_joao << { arquivo: nome_arquivo, conteudo: texto }
    end

  rescue StandardError => e
    warn "Erro ao processar #{nome_arquivo}: #{e.message}"
  end
end

solicitacao_ia = {
  instrucoes: "Você é um advogado previdenciarista sênior. Use o 'modelo_referencia_maria' apenas para entender a estrutura, tom da linguagem e fundamentação jurídica. Analise os documentos do 'caso_joao' (RG, residência, indeferimento do INSS e laudo médico), extraia a profissão, diagnóstico e conecte-os de forma lógica e personalizada para criar a nova petição inicial do João da Silva. Não copie o histórico da Maria, adapte ao caso do João.",
  modelo_referencia_maria: conteudo_modelo_maria,
  caso_joao: textos_joao
}

json_final = JSON.pretty_generate(solicitacao_ia)

# Exibe o JSON pronto para o payload da API
puts json_final