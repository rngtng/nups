class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.belongs_to :user
      
      t.string :name
      t.string :number
      t.string :username
      t.string :password

      t.timestamps
    end
  end

end
