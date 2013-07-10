class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email, :null => false
      t.string :encrypted_password
      t.timestamps
    end

    create_table :login_tickets do |t|
      t.string :ticket, :null => false
      t.timestamp :consumed
      t.string :client_hostname, :null => false

      t.timestamps
    end

    create_table :ticket_granting_tickets do |t|
      t.string :ticket, :null => false
      t.string :client_hostname, :null => false
      t.string :username, :null => false
      t.text :extra_attributes, :limit => 2048

      t.timestamps
    end

    create_table :service_tickets do |t|
      t.string :ticket, :null => false
      t.string :service, :null => false
      t.timestamp :consumed
      t.references :ticket_granting_ticket, :null => false

      t.timestamps
    end
 
    add_index :ticket_granting_tickets, :ticket
    add_index :login_tickets, :ticket
    add_index :service_tickets, :ticket
    add_index :service_tickets, :ticket_granting_ticket_id
    add_index :users, :email, :unique => true
  end

  def self.down
    drop_table :users
    drop_table :login_tickets
    drop_table :ticket_granting_tickets
    drop_table :service_tickets
  end
end
