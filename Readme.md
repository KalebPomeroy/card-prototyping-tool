Requirements:

    * Ruby
    * RMagick
    * Rubygems
        * activesupport

Everything in data can be considered an example.

To generate the cards, run

$ ruby generate_images.rb


## Data Files
Right now, the code is the best documentation, as there will be a GUI wrapper
soon. Short version is as follows.

### Card data
The cards.yaml files should include an array of cards. Each card should have

    * card_type - used for the layout definition
    * id - used for internal processing as saving to the filesystem
    * background - optional, but this determines image size. Othersize, it defaults to 300x400
    * artwork - options, and can include {{variables}}

Other attributes can be added however you want

### Layout
The layout file should be a hash of every card type defined in the cards above.
Each card_type should have a number of attributes under it. An attribute is
anything that should be added to the card, such as the title. Each attribute
should have its own definition. Valid values are as follows (Everything should
have sane defaults, and therefore be optional, but as no one besides myself has
used this, no promises):

    * x: the horizontal positioning
    * y: the vertical positioning

    * wordwrap:
        limit: Add {char} after this many characters, respecting word breaks
        char: Separating character Default is \n
    * render_with_variables: name of another attribute to render with card data. ie, source_image: /artwork/{{id}}.png

    * font_size: Size of the font
    * font: Only currently supported value is "italics"
    * rotation: Degrees to rotate this attribute
    * source_image: Instead of text, add an image to the card
    * source_width: Resize the source image width
    * source_height: Resize the source image height
    * blending_method: control how a source image is added. ("under" is the only supported, and requires a background with transparency)
    * offset_per_char:
        y: Move down this many pixels per character
        x: Move right this many pixels per character

    * depends_on: add the attribute only if it matches a condition
        attribute: attribute on the card to compare against
        comparison: "present" is the only supported right now

    * container_width: The width of a container to put content in
    * container_height: The height of a container to put content in
    * gravity: How content should be aligned in the container

