class Lock < ActiveRecord::Base

  # Get an atomic lock if value matches or is nil. Block until lock was successful if args[:blocking] was set to true
  def self.get name, args = {}
    poll_time = args[:poll_time] || 10
    until (lock = get_lock_for(name, args)) || args[:blocking] != true do
      sleep poll_time
    end
    lock
  end


  # Release an atomic lock if value matches or is nil
  def self.release names, args = {}
    successful = false

    if name
      # If names is a single string, transorm it to an array
      names = [names.to_s] if names.class == String || names.class == Symbol

      self.transaction do
        locks = self.where(:name => names).lock(true).all

        unless locks.blank?
          successful = true
          # Check, if the value of every selected lock matches the args[:value] unless no args[:value] was specified
          locks.each{ |l| successful = false unless (args[:value].nil? || (args[:value] != nil && args[:value] == l.value)) }
          # Now destroy the locks, if it is successful
          locks.each{ |l| l.destroy } if successful
        end
      end
    end

    successful
  end


  # Release all locks for a given task. This is only working, if the value was set to "task #{task.id}"
  def self.release_for_task task
    self.transaction do
      locks = self.where(:value => "task #{task.id}").lock(true).all
      locks.each{ |l| l.destroy }
    end
  end


  # Return value of a lock. When no lock was found, nil will be returned.
  def self.get_value name
    lock = self.where(:name => name).first
    if lock
      lock.value.nil? ? '' : lock.value
    else
      nil
    end
  end


  # Destroy all locks in one atomic operation
  def self.release_all
    self.transaction do
      self.all.each { |l| l.destroy }
    end
  end


private


  # Get an atomic lock if value matches or is nil
  def self.get_lock_for names, args = {}
    successful_if_value_matches = args[:successful_if].to_s == 'value_matches'
    successful = false

    if names
      # If names is a single string, transorm it to an array
      names = [names.to_s] if names.class == String || names.class == Symbol

      self.transaction do
        locks = self.where(:name => names).lock(true).all

        if locks.blank?
          names.each{ |n| self.create :name => n, :value => args[:value] }
          successful = true
        else
          if args[:force]
            names.each do |n|
              lock = locks.find{ |l| l.name == n }
              if lock
                lock.update_attribute :value, args[:value]
              else
                self.create :name => n, :value => args[:value]
              end
            end
            successful = true
          elsif successful_if_value_matches && args[:value] != nil 
            successful = true
            created_locks = []
            names.each do |n|
              lock = locks.find{ |l| l.name == n }
              if lock
                successful = false if lock.value != args[:value]
              else
                created_locks << self.create(:name => n, :value => args[:value])
              end
            end
            # Rollback created locks, if the lock acquire was not successful
            created_locks.each{ |l| l.destroy } unless successful
          end
        end

        # Wait some secound inside the transaction for debuging and testing purposes
        sleep args[:debug_wait].to_i if args[:debug_wait]
      end
    end

    successful
  end

end
