class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.string :attachment_file_size
      t.belongs_to :user
      t.belongs_to :account
      t.belongs_to :newsletter

      t.timestamps
    end
    
    change_table :newsletters do |t|
      t.remove :attachemnts
    end

    change_table :accounts do |t|
      t.boolean :has_attachments
    end
  end

  def self.down
    drop_table :assets
    
    change_table :newsletters do |t|
      t.text :attachemnts
    end

    change_table :accounts do |t|
      t.remove :has_attachments
    end    
  end
end
