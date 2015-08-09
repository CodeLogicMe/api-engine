class ResponseNormalizer
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.(env).finish
  end
end
