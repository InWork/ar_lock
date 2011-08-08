class AddArLockTable < ActiveRecord::Migration
  def self.up
    create_table "<%= options[:ar_lock_table_name] %>", :force => true do |t|
      t.string :name, :null => false
      t.string :value

      t.timestamps
    end
    add_index "<%= options[:ar_lock_table_name] %>", :name, :unique => true
  end

  def self.down
    drop_table "<%= options[:ar_lock_table_name] %>"
  end
end
