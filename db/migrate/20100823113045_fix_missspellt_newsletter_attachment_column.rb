class FixMissspelltNewsletterAttachmentColumn < ActiveRecord::Migration
  def self.up
    change_table :newsletters do |t|
      t.rename :attachemnts, :attachments
    end
  end

  def self.down
    change_table :newsletters do |t|
      t.rename :attachments, :attachemnts
    end    
  end
end
