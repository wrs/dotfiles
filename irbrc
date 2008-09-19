require 'rubygems'
require 'pp'
require 'irb/completion'
require 'irb/ext/save-history'
require 'utility_belt'

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history" 
IRB.conf[:PROMPT_MODE]  = :SIMPLE

# Just for Rails...
if rails_env = ENV['RAILS_ENV']
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
IRB.conf[:IRB_RC] = lambda do
  old_irb_rc.call if old_irb_rc
  if rails_env = ENV['RAILS_ENV'] && Object.const_defined?("ActiveRecord")
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.instance_eval { alias :[] :find }
  end
  UtilityBelt::Themes.background(:light)
  UtilityBelt::Equipper.equip(:all)
end
