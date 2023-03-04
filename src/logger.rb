class Logger
  def self.prompt(message)
    current_time = Time.now.strftime("%m/%d/%Y %H:%M:%S")
    puts "#{current_time}\t#{message}"
  end
end
