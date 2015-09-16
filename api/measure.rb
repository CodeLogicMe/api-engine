require 'skylight'

class Measure
  def initialize(receiver, targets)
    @receiver = receiver
    @targets = targets
  end

  def respond_to_missing?(name, _)
    @targets.keys.include? name
  end

  def method_missing(name, *args, &block)
    if @receiver.respond_to?(name)
      if @targets.has_key?(name)
        Skylight.instrument(title: @targets[name]) do
          @receiver.public_send name, *args, &block
        end
      else
        @receiver.public_send name, *args, &block
      end
    else
      super
    end
  end
end
