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

ActiveRecord::Schema.define(:version => 1) do

  create_table "login_tickets", :force => true do |t|
    t.string   "ticket",          :null => false
    t.datetime "consumed"
    t.string   "client_hostname", :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "login_tickets", ["ticket"], :name => "index_login_tickets_on_ticket"

  create_table "service_tickets", :force => true do |t|
    t.string   "ticket",                    :null => false
    t.string   "service",                   :null => false
    t.datetime "consumed"
    t.integer  "ticket_granting_ticket_id", :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "service_tickets", ["ticket"], :name => "index_service_tickets_on_ticket"
  add_index "service_tickets", ["ticket_granting_ticket_id"], :name => "index_service_tickets_on_ticket_granting_ticket_id"

  create_table "ticket_granting_tickets", :force => true do |t|
    t.string   "ticket",                           :null => false
    t.string   "client_hostname",                  :null => false
    t.string   "username",                         :null => false
    t.text     "extra_attributes", :limit => 2048
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "ticket_granting_tickets", ["ticket"], :name => "index_ticket_granting_tickets_on_ticket"

  create_table "users", :force => true do |t|
    t.string   "email",              :null => false
    t.string   "encrypted_password"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
