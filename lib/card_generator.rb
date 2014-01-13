require './lib/image'

# Add newlines every 35 characters, without breaking words
def wordwrap(txt, col=35)
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n") if txt
end

# Given string including {{var}}, replace with hash["var"]
# TODO: Make this regex not greedy, and replace multiple vars
def render(string, hash)
    string.gsub(/\{\{\s*(\w+)\s*\}\}/) { hash[$1] } if string
end

class CardGenerator

    def initialize(layout)
        @card = nil
        @layout = layout
    end

    # Given a type (ie, character) get the layout def for that, deep cloned
    def get_layout_for_type(type)
        Marshal.load( Marshal.dump(@layout[type]))
    end

    # Given an attribute (ie, title, strength), get the attribute definition
    def get_attribute_definition(card, attribute)
        return nil unless @layout[card[:card_type]].has_key? attribute
        @layout[card[:card_type]][attribute].clone
    end

    def get_attribute(card, attribute, opts={})
        attr_def = self.get_attribute_definition(card, attribute)
        return unless attr_def

        opts[:text] = (card.has_key? attribute) ? card[attribute] : ""

        # Handle Wordwrapping
        if attr_def.has_key? :wordwrap
            opts[:text] = wordwrap(opts[:text], attr_def[:wordwrap])
            attr_def.delete(:wordwrap)
        end

        # Handle depends ons
        if attr_def.has_key? :depends_on
            if(attr_def[:depends_on][:comparison] == "present")
                return unless card.has_key? attr_def[:depends_on][:attribute]
            end
            attr_def.delete(:depends_on)
        end

        # Handle depends ons
        if attr_def.has_key? :offset_per_char
            len = (card[attribute]).to_s.length
            opts[:x] = attr_def[:x] + attr_def[:offset_per_char][:x] * len
            opts[:y] = attr_def[:y] + attr_def[:offset_per_char][:y] * len
            attr_def.delete(:offset_per_char)
        end

        # Handle variables in the artwork
        if(attribute == "artwork")
            opts[:source_image] = render(attr_def[:source_image], card)
        end

        Attribute.new(attr_def.merge(opts))
    end

    def save_card_to_file(card, location)
        make_card(card)
        @_card.write(location)
    end

    def get_raw(card)

        make_card(card)
        @_card.raw
    end

    def make_card(card)
        print "Generating card #{card['id']}..."

        @_card = Image.new(card['id'])

        layout = self.get_layout_for_type(card[:card_type])

        # Do the Background specially
        @_card.background = render(layout[:background], card)
        layout.delete(:background)

        layout.keys.each { |a | @_card.add get_attribute(card, a) }

        @_card.generate
        puts " Finished."
    end
end
