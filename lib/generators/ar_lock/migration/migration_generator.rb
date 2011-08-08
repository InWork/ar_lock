require 'rails/generators'
require 'rails/generators/migration'

module ArLock
  class MigrationGenerator < Rails::Generators::Base
    desc "The ar_lock migration generator creates a database migration for the lock model."
    include Rails::Generators::Migration
    source_root File.join(File.dirname(__FILE__), 'templates')

    class_option :ar_lock_table_name,
      :type => :string,
      :desc => "Name for the ArLock Table",
      :required => false,
      :default => "locks"

    def initialize(args = [], options = {}, config = {})
      super
    end

    #attr_reader :lock_table_name

    # Implement the required interface for Rails::Generators::Migration.
    # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    def create_migration_file
      migration_template 'migration.rb', 'db/migrate/add_ar_lock_table.rb'
    end

  end
end
