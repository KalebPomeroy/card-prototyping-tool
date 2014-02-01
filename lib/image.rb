require 'RMagick'

class Attribute

    attr_accessor :type

    attr_accessor :source_image, :source_height, :source_width

    attr_accessor :blending_method

    attr_accessor :text
    attr_accessor :color
    attr_accessor :font_size

    attr_accessor :x, :y
    attr_accessor :rotation


    attr_accessor :container_height, :container_width
    attr_accessor :gravity


    def initialize(options)
        @_blending_method = Magick::OverCompositeOp
        @type = "text"
        @x = 0
        @y = 0
        @rotation = 0
        @color = "black"
        @container_width = 0
        @container_height = 0
        @font_size = 14
        @_font = "lib/fonts/Times_New_Roman.ttf"
        options.each_pair { | k, v | self.send("#{k}=",v) }
    end

    def gravity=(gravity)
        case gravity
        when "centered", :centered, "center", :center
            @_gravity = Magick::CenterGravity
        when "north_west", :north_west, "northwest", :northwest, "nw", :nw
            @_gravity = Magick::NorthWestGravity
        end
    end

    def gravity
        @_gravity
    end

    def source_image=(source_image)
        @_source_image = source_image
        @type = "image"
    end

    def source_image
        @_source_image
    end

    def blending_method=(method)
        case method
        when "under", :under
            @_blending_method = Magick::DstOverCompositeOp
        else
            raise "#{method} is not a valid blending method"
        end
    end

    def blending_method
        @_blending_method
    end


    def font=(font)
        case font
        when "italics", :italics
            @_font = "lib/fonts/Times_New_Roman_Italic.ttf"
        end
    end

    def font
        @_font
    end

    def text=(text)
        @_text = text.to_s
        @_text = " " if @_text.length == 0
    end

    def text
        @_text
    end
end

class Image

    attr_accessor :background, :format, :height, :width, :image_path, :source_height, :source_width

    def initialize(image_name)
        @image_name = image_name
        @background = background
        @image_path = "/images"
        @format = "PNG"
        @height = 400
        @width = 300
        @things = []

        @_image = nil
    end

    def add(thing)
        @things << thing if thing
    end

    def generate
        if @background
            @_image = Magick::Image.read(@background).first
        else
            @_image = Magick::ImageList.new
            @_image.new_image(@width, @height)
        end

        @things.each do | a |
            if(a.type == "image")
                # TODO: Read source image in a way smarter than from the filesystem
                # so that users can have separate, managable files
                img = Magick::Image.read(a.source_image).first
                img.resize!(a.source_width, a.source_height) if a.source_width && a.source_height
                @_image.composite!(img, a.x, a.y, a.blending_method)
            elsif(a.type == "text")
                text = Magick::Draw.new
                text.gravity = a.gravity if a.gravity
                text.pointsize = a.font_size
                text.font = a.font
                text.annotate(@_image, a.container_width, a.container_height, a.x, a.y, a.text) {
                    self.fill = a.color
                    self.rotation = a.rotation
                }
            else
                raise "Unsupported type of attribute"
            end

        end

        @_image.format = @format
    end

    def raw
        @_image.to_blob
    end


    def write(path=nil)
        raise "You have to run Image#generate first!" if @_image == nil

        @_image.write("#{path || @image_path}#{@image_name}.png")
    end
end