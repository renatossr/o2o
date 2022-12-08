class ItemsImport
  def self.import_members(file)
    import_count = 0
    worksheet = active_worksheet(file)
    worksheet.each_with_index(
      first_name: "Nome",
      last_name: "Sobrenome",
      alias: "Apelido",
      cel_number: "Celular",
      responsible: "Responsável",
      subscription_price: "Mensalidade",
      subscription_type: "Tipo de Plano",
      class_price: "Preço Aula Avulsa",
      double_class_price: "Preço Aula Dupla",
      triple_class_price: "Preço Aula Trio",
      monday: "Segunda",
      tuesday: "Terça",
      wednesday: "Quarta",
      thursday: "Quinta",
      friday: "Sexta",
      saturday: "Sábado",
      sunday: "Domingo",
      loyal: "Fidelizado?",
      replacement_classes: "Reposições",
    ) do |row, row_index|
      next if row_index == 0 || Member.find_by(first_name: row[:first_name].capitalize, last_name: row[:last_name].capitalize).present?

      member =
        Member.create!(
          first_name: row[:first_name].capitalize,
          last_name: row[:last_name].capitalize,
          alias: row[:alias].capitalize,
          cel_number: row[:cel_number],
          subscription_price: row[:subscription_price].present? ? (row[:subscription_price] * 100.0).to_i : nil,
          subscription_type: row[:subscription_type].to_i,
          class_price: row[:class_price].present? ? (row[:class_price] * 100.0).to_i : nil,
          double_class_price: row[:double_class_price].present? ? (row[:double_class_price] * 100.0).to_i : nil,
          triple_class_price: row[:triple_class_price].present? ? (row[:triple_class_price] * 100.0).to_i : nil,
          monday: row[:monday],
          tuesday: row[:tuesday],
          wednesday: row[:wednesday],
          thursday: row[:thursday],
          friday: row[:friday],
          saturday: row[:saturday],
          sunday: row[:sunday],
          loyal: row[:loyal],
          replacement_classes: row[:replacement_classes],
        )
      puts "Inserindo: #{member.name}"
      import_count += 1
    end

    worksheet.each_with_index(first_name: "Nome", last_name: "Sobrenome", responsible: "Responsável") do |row, row_index|
      next if row_index == 0
      name_responsible = row[:responsible]
      member = Member.find_by(first_name: row[:first_name].capitalize, last_name: row[:last_name].capitalize)
      if name_responsible.present? && member.present?
        responsible =
          Member
            .where("SIMILARITY(CONCAT(first_name, ' ', last_name), ?) > 0.3", name_responsible)
            .order(Member.sanitize_sql_for_order([Arel.sql("SIMILARITY(CONCAT(first_name, ' ', last_name), ?) DESC"), name_responsible]))
            .first
        member.responsible = responsible
        member.save!
      end
    end

    import_count
  end

  def self.import_coaches(file)
    import_count = 0
    worksheet = active_worksheet(file)
    worksheet.each_with_index(first_name: "Nome", last_name: "Sobrenome", alias: "Apelido", cel_number: "Celular", pay_fixed: "Salário", pay_per_workout: "Valor Aula Avulsa") do |row, row_index|
      next if row_index == 0 || Coach.find_by(first_name: row[:first_name], last_name: row[:last_name]).present?

      coach =
        Coach.create!(
          first_name: row[:first_name].capitalize,
          last_name: row[:last_name].capitalize,
          alias: row[:alias].capitalize,
          cel_number: row[:cel_number],
          pay_fixed: row[:pay_fixed].present? ? (row[:pay_fixed] * 100.0).to_i : nil,
          pay_per_workout: row[:pay_per_workout].present? ? (row[:pay_per_workout] * 100.0).to_i : nil,
        )
      puts "Inserindo: #{coach.name}"
      import_count += 1
    end
    import_count
  end

  def self.active_worksheet(file)
    workbook = Roo::Spreadsheet.open(file) #RubyXL::Parser.parse(file)
    workbook.sheet(0)
  end
end
