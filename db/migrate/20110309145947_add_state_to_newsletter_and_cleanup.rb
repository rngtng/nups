class AddStateToNewsletterAndCleanup < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      INSERT INTO sendings
               (last_id, newsletter_id, fails, oks,
               recipients_count, state, type,
               created_at, finished_at, start_at, updated_at)
        SELECT last_sent_id, id, errors_count, deliveries_count,
               recipients_count, status, IF(mode = 0,'TestSending','LiveSending'),
               deliver_at, delivery_ended_at, deliver_at, delivery_ended_at
        FROM newsletters
    SQL

    change_table :newsletters do |t|
      t.remove :last_sent_id
      t.remove :deliveries_count
      t.remove :errors_count
      t.remove :mode
      t.remove :recipients_count
      t.remove :status
      t.remove :deliver_at
      t.remove :delivery_ended_at
      t.remove :delivery_started_at

      t.string :state
    end

  end

  def self.down
    change_table :newsletters do |t|
      t.integer :last_sent_id
      t.integer :deliveries_count
      t.integer :errors_count
      t.string :mode
      t.integer :recipients_count
      t.string :status
      t.datetime :deliver_at
      t.datetime :delivery_ended_at
      t.datetime :delivery_started_at

      t.remove :state
    end

  end
end
