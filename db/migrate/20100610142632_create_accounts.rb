class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|

      t.string :name
      t.string :from
      t.string :host

      t.belongs_to :user

      t.string :subject

      t.text :template_html
      t.text :template_text

      t.text :test_recipient_emails

      t.timestamps
    end
  end
end
