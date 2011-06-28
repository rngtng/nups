class CreateSendOuts < ActiveRecord::Migration
  def change
    create_table :send_outs do |t|
      t.belongs_to :recipient
      t.belongs_to :newsletter
      t.string :type
      t.string :state
      t.string :email

      t.string :error_code
      t.text :error_message

      t.timestamps
    end

    add_index :send_outs, [:newsletter_id, :type]
  end
end
