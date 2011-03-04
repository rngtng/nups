class CreateSendings < ActiveRecord::Migration
  def self.up
    create_table :sendings do |t|
      t.belongs_to :newsletter

      t.string    :type

      t.string    :state
      t.integer   :recipients_count
      t.timestamp :start_at

      t.integer   :last_id,   :null => false, :default => 0
      t.integer   :oks,       :null => false, :default => 0
      t.integer   :fails,     :null => false, :default => 0

      t.timestamp :finished_at

      t.timestamps
    end

    add_index :sendings, [:id, :type, :state]
  end

  def self.down
    drop_table :sendings
  end
end
