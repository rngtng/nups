class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.string :name
      t.string :type
      t.string :extension
      t.belongs_to :user
      t.belongs_to :newsletter

      t.timestamps
    end
    
    change_table :newsletters do |t|
      t.remove :attachemnts
    end
    
  end

  def self.down
    drop_table :attachments
    
    change_table :newsletters do |t|
      t.text :attachemnts
    end
  end
end
