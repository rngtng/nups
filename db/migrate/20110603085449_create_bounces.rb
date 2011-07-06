class CreateBounces < ActiveRecord::Migration
  def change
    create_table :bounces do |t|
      t.integer :account_id
      t.integer :user_id

      t.string :from
      t.string :subject
      t.datetime :send_at
      t.text :header
      t.text :body
      t.text :raw

      t.timestamps
    end
  end

end
