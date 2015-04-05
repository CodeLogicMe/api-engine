require_relative "./asset_line"

class AssetsServer < Sinatra::Base
  helpers do
    def assets
      root_path = File.join(__dir__, "assets")
      AssetLine.new(root: root_path)
    end
  end

  get /^\/assets\/\w+\/(?<filename>.+)$/ do
    if params["filename"].match /\.js$/
      content_type "application/javascript"
    elsif params["filename"].match /\.css$/
      content_type "text/css"
    end

    assets.fetch params.fetch("filename")
  end
end
