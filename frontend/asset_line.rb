class AssetLine
  def initialize(options)
    env = options.fetch(:env) { ENV['RACK_ENV'] }
    assets_root = options.fetch(:root)

    @compilers = [
      SimpleAsset.new(env, assets_root, type: 'stylesheets', ext: 'css'),
      SimpleAsset.new(env, assets_root, type: 'javascripts', ext: 'js'),
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

  class SimpleAsset
    def initialize(env, root, options)
      @env = env
      @root = File.join root, options.fetch(:type)
      @ext = options.fetch(:ext)
    end

    def can_handle?(filename)
      filename.match(/\.#{@ext}$/i) &&
        File.exist?(file_path(filename))
    end

    def compile(filename)
      File.read(file_path(filename))
    end

    private

    def file_path(filename)
      File.join(@root, filename.gsub(/(?<=\.).+$/, @ext))
    end
  end

  class Stylus < SimpleAsset
    require 'stylus'

    def initialize(env, root)
      super(env, root, type: 'stylesheets', ext: 'styl')
    end

    def can_handle?(filename)
      filename.match(/\.css$/i) &&
        File.exist?(file_path(filename))
    end

    def compile(filename)
      path = File.join(@root, filename.gsub(/(?<=\.)css$/i, 'styl'))
      ::Stylus.compile File.new(path), **css_options
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

