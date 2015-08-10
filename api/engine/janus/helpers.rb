module Janus
  module Helpers
    def current_api
      env.fetch 'current_api'
    end
  end
end
