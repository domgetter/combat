#Encoding: UTF-8

# uncomment following line for Ocra distribution
Dir.chdir(File.dirname(__FILE__))

require 'gosu'
require 'opengl'

require_relative 'gosu/image'
require_relative 'combat/tank'
require_relative 'combat/bullet'
require_relative 'combat/cell'
require_relative 'combat/game'
