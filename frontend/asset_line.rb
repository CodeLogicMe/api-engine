class AssetLine
  def initialize(options)
    env = options.fetch(:env) { ENV['RACK_ENV'] }
    assets_root = options.fetch(:root)

    @compilers = [CSS.new(env, assets_root)]
  end

  def fetch(filename)
    @compilers
      .find { |compiler| compiler.can_handle?(filename) }
      .compile(filename)
  end

  private

  def js?(filename)
    filename.match /\.(js|coffee)$/i
  end

  class CSS
    require 'stylus'

    def initialize(env, root)
      @env = env
      @root = File.join root, 'stylesheets'
    end

    def can_handle?(filename)
      filename.match /\.(css|styl)$/i
    end

    def compile(filename)
      path = File.join(@root, "#{extensionless(filename)}.styl")
      Stylus.compile File.new(path), **css_options
    end

    def extensionless(filename)
      filename.gsub /\.css$/, ''
    end

    def css_options
      {
        'development' => {
          compress: false
        },
        'test' => {
          compress: false
        }
      }[@env]
    end
  end
end

