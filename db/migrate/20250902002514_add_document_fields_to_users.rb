class AddDocumentFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :business_license_document, :boolean, default: false
    add_column :users, :insurance_certificate_document, :boolean, default: false
    add_column :users, :professional_certifications_document, :boolean, default: false
    add_column :users, :government_id_document, :boolean, default: false
  end
end
