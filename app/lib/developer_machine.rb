class DeveloperMachine
  
  # a file that if exists, proves that this instance of Rails is running in a developer/CI machine.
  def self.developer_identifying_directories
    ['/Users/vemv', '/home/rof']
  end
  
  def self.running_in_developer_machine?
    developer_identifying_directories.any?{|a| File.exists? a }
  end
  
end