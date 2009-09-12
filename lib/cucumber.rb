$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems' # TODO: remove
require 'yaml'
require 'cucumber/platform'
require 'cucumber/version'
require 'cucumber/step_mother'
require 'cucumber/cli/main'
require 'cucumber/broadcaster'
