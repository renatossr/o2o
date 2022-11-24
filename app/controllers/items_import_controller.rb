class ItemsImportController < ApplicationController
  def import_members
    imported_members = ItemsImport.import_members(file_path)
    if imported_members > 0
      flash[:success] = "Total de alunos importados: #{imported_members}"
    else
      flash[:notice] = "Total de alunos importados: #{imported_members}"
    end
    redirect_to settings_path
  end

  def import_coaches
    imported_coaches = ItemsImport.import_coaches(file_path)
    if imported_coaches > 0
      flash[:success] = "Total de coaches importados: #{imported_coaches}"
    else
      flash[:notice] = "Total de coaches importados: #{imported_coaches}"
    end
    redirect_to settings_path
  end

  private

  def file_path
    params[:import][:file].path
  end
end
