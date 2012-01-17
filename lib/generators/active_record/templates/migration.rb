class CreateProxies < ActiveRecord::Migration
  def self.up
    create_table :proxies do |t|
      
      t.string :host, :null => false
      t.integer :port, :null => false
      t.string :username
      t.string :password
      
      t.string :protocol, :null => false, :default => 'http'
      t.string :proxy_type, :null => false, :defaut => 'public'
      t.string :category
      
      t.datetime :last_checked_at
      t.boolean :valid_proxy, :null => false, :default => false
      t.integer :successful_attempts, :null => false, :default => 0
      t.integer :failed_attempts, :null => false, :default => 0

      t.timestamps
    end
    
    add_index :proxies, [:host, :port], :unique => true, :name => 'index_unique_proxy'
    add_index :proxies, :protocol, :name => 'index_protocol'
    add_index :proxies, :proxy_type, :name => 'index_proxy_type'
    add_index :proxies, :category, :name => 'index_category'
    add_index :proxies, :valid_proxy, :name => 'index_valid_proxy'
    add_index :proxies, :successful_attempts, :name => 'index_successful_attempts'
    add_index :proxies, :failed_attempts, :name => 'index_failed_attempts'
  end

  def self.down
    drop_table :proxies
  end
end