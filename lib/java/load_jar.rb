require 'java'

Dir[File.join(File.dirname(__FILE__), "**/*.jar")].each do |f|
  require f
end
