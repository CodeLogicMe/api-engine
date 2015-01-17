require_relative './asset_line'

class AssetsServer < Sinatra::Base
  helpers do
    def assets
      root_path = File.join(__dir__, 'assets')
      compiler = AssetLine.new(root: root_path)
    end
  end

  get '/assets/**/:filename' do
    assets.fetch(params.fetch('filename'))
  end
end
