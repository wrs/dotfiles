require 'rubygems'
require 'pp'
require 'irb/completion'
require 'irb/ext/save-history'
begin
  require 'utility_belt'
rescue Exception
  nil
end

ARGV.concat ["--readline"]
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history" 
IRB.conf[:PROMPT_MODE]  = :SIMPLE

# Just for Rails...
if Object.const_defined?("Rails")
  rails_root = File.basename(Dir.pwd)
  IRB.conf[:PROMPT] ||= {}
  IRB.conf[:PROMPT][:RAILS] = {
    :PROMPT_I => "#{rails_root}> ",
    :PROMPT_S => "#{rails_root}* ",
    :PROMPT_C => "#{rails_root}? ",
    :RETURN   => "=> %s\n" 
  }
  IRB.conf[:PROMPT_MODE] = :RAILS
end

old_irb_rc = IRB.conf[:IRB_RC]
IRB.conf[:IRB_RC] = lambda do |x|
  old_irb_rc.call(x) if old_irb_rc
  if Object.const_defined?("Rails") && Object.const_defined?("ActiveRecord")
    $stdout.puts "ActiveRecord logging enabled"
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.instance_eval { alias :[] :find }
  end
  begin
    UtilityBelt::Themes.background(:light)
    UtilityBelt::Equipper.equip(:all)
  rescue Exception
    nil
  end
end
