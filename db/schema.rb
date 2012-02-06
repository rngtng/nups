# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120206174156) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "from"
    t.integer  "user_id"
    t.string   "subject"
    t.text     "template_html"
    t.text     "template_text"
    t.text     "test_recipient_emails"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",                 :default => "#FFF"
    t.boolean  "has_html",              :default => true
    t.boolean  "has_text",              :default => true
    t.boolean  "has_attachments"
    t.boolean  "has_scheduling"
    t.text     "mail_config_raw"
    t.string   "permalink"
  end

  create_table "assets", :force => true do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.string   "attachment_file_size"
    t.integer  "user_id"
    t.integer  "account_id"
    t.integer  "newsletter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bounces", :force => true do |t|
    t.integer  "account_id"
    t.integer  "recipient_id"
    t.string   "from"
    t.string   "subject"
    t.datetime "send_at"
    t.text     "header"
    t.text     "body"
    t.text     "raw"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "error_status"
    t.integer  "send_out_id"
  end

  create_table "domains", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "number"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletters", :force => true do |t|
    t.string   "subject"
    t.text     "content"
    t.integer  "mode",                :default => 0,          :null => false
    t.integer  "status",              :default => 0,          :null => false
    t.integer  "last_sent_id"
    t.integer  "recipients_count",    :default => 0,          :null => false
    t.integer  "deliveries_count",    :default => 0,          :null => false
    t.integer  "fails_count",         :default => 0,          :null => false
    t.datetime "deliver_at"
    t.datetime "delivery_started_at"
    t.datetime "delivery_ended_at"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",               :default => "finished"
    t.integer  "bounces_count",       :default => 0,          :null => false
    t.integer  "reads_count",         :default => 0,          :null => false
  end

  add_index "newsletters", ["account_id"], :name => "index_newsletters_on_account_id"

  create_table "recipients", :force => true do |t|
    t.string   "gender"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "deliveries_count", :default => 0,         :null => false
    t.integer  "bounces_count",    :default => 0,         :null => false
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fails_count",      :default => 0,         :null => false
    t.string   "confirm_code"
    t.string   "state",            :default => "pending"
    t.integer  "reads_count",      :default => 0,         :null => false
  end

  add_index "recipients", ["account_id"], :name => "index_recipients_on_account_id"
  add_index "recipients", ["email"], :name => "index_recipients_on_email"
  add_index "recipients", ["id", "account_id"], :name => "index_recipients_on_id_and_account_id", :unique => true

  create_table "send_outs", :force => true do |t|
    t.integer  "recipient_id"
    t.integer  "newsletter_id"
    t.string   "type"
    t.string   "state"
    t.string   "email"
    t.text     "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "finished_at"
  end

  add_index "send_outs", ["newsletter_id", "type", "recipient_id"], :name => "index_send_outs_on_newsletter_id_and_type_and_recipient_id"
  add_index "send_outs", ["newsletter_id", "type"], :name => "index_send_outs_on_newsletter_id_and_type"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.boolean  "admin"
    t.datetime "reset_password_sent_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
