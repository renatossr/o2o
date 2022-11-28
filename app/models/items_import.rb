class ItemsImport
  def self.import_members(file)
    import_count = 0
    worksheet = active_worksheet(file)
    worksheet.each_with_index(
      first_name: "Nome",
      last_name: "Sobrenome",
      alias: "Apelido",
      cel_number: "Celular",
      subscription_price: "Mensalidade",
      class_price: "Preço Aula Avulsa",
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
      next if row_index == 0 || Member.find_by(first_name: row[:first_name], last_name: row[:last_name]).present?

      member =
        Member.create!(
          first_name: row[:first_name],
          last_name: row[:last_name],
          alias: row[:alias],
          cel_number: row[:cel_number],
          subscription_price: (row[:subscription_price] * 100.0).to_i,
          class_price: (row[:class_price] * 100.0).to_i,
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
    import_count
  end

  def self.import_coaches(file)
    import_count = 0
    worksheet = active_worksheet(file)
    worksheet.each_with_index(
      first_name: "Nome",
      last_name: "Sobrenome",
      alias: "Apelido",
      cel_number: "Celular",
      pay_fixed: "Salário",
      pay_per_workout: "Valor Aula Avulsa",
    ) do |row, row_index|
      next if row_index == 0 || Coach.find_by(first_name: row[:first_name], last_name: row[:last_name]).present?

      coach =
        Coach.create!(
          first_name: row[:first_name],
          last_name: row[:last_name],
          alias: row[:alias],
          cel_number: row[:cel_number],
          pay_fixed: (row[:pay_fixed] * 100.0).to_i,
          pay_per_workout: (row[:pay_per_workout] * 100.0).to_i,
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
