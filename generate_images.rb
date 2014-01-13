require "yaml"
require 'rubygems'
require './lib/card_generator.rb'
require 'active_support/core_ext/hash/indifferent_access'

# Get the layout as a nice pretty hash
layout = HashWithIndifferentAccess.new(YAML::load(File.open('data/layout.yaml')))

# Get a list of cards in a nice pretty hash
c = []
Dir.glob("data/cards/cards.yaml") { | f | c += YAML::load(File.open(f))}
cards = HashWithIndifferentAccess.new({:cards=>c})[:cards]


card_generator = CardGenerator.new(layout)

location = "data/images/cards/"

cards.each do | card |
    card_generator.save_card_to_file(card, location)
end

# cards.each do | card |
#     puts card_generator.get_raw(card, with_artwork)
# end