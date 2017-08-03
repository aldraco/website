class CreateIterationFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :iteration_files do |t|
      t.bigint :iteration_id, null: false
      t.string :filename, null: false
      t.string :content_type, null: false
      t.binary :file_contents, null: false

      t.timestamps
    end

    add_foreign_key :iteration_files, :iterations
  end
end
