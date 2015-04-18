module Helpers
  module ClientAccess
    def current_client
      client_id = request.cookies["client_id"]

      return ::Models::NilClient.new if client_id.nil?

      @client ||= ::Models::Client.find(client_id)
    rescue ::Mongoid::Errors::DocumentNotFound
      request.cookies["client_id"] = nil
      ::Models::NilClient.new
    end

    def set_current_client(client)
      @client = client
      response.set_cookie "client_id",
        { value: client.id.to_s, max_age: "604800" }
    end
  end

  module Assets
    def js(*files)
      statement = "<!-- #{files.join(', ')} -->"
      case ENV['RACK_ENV']
      when 'development'
        statement << Array(files).map { |file|
          "<script src='/assets/javascripts/#{file}' type='text/javascript'></script>"
        }.join('')
      when 'production'
        fail NotImlementedError
      when 'test'
        # we still don't test scripts
      end
    end
  end
end
