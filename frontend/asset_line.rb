class AssetLine
  def initialize(options)
    env = options.fetch(:env) { ENV['RACK_ENV'] }
    assets_root = options.fetch(:root)

    @compilers = [
      CSS.new(env, assets_root),
      Stylus.new(env, assets_root),
      NullCompiler.new
    ]
  end

  def fetch(filename)
    @compilers
      .find { |compiler| compiler.can_handle?(filename) }
      .compile(filename)
  end

  UnhandableAsset = Class.new(StandardError)

  private

  class CSS
    def initialize(env, root)
      @env = env
      @root = File.join root, 'stylesheets'
    end

    def can_handle?(filename)
      filename.match(/\.css$/i) &&
        File.exist?(file_path(filename))
    end

    def compile(filename)
      File.read(file_path(filename))
    end

    private

    def extensionless(filename)
      filename.gsub /\.css$/, ''
    end

    def file_path(filename)
      File.join(@root, "#{extensionless(filename)}.css")
    end
  end

  class Stylus < CSS
    require 'stylus'

    def compile(filename)
      path = File.join(@root, "#{extensionless(filename)}.styl")
      ::Stylus.compile File.new(path), **css_options
    end

    def file_path(filename)
      File.join(@root, "#{extensionless(filename)}.styl")
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

  class NullCompiler
    def can_handle?(_)
      fail UnhandableAsset
    end
  end
end

