class BaseException < StandardError
  def initialize(message = nil)
    @message = message
  end

  def message
    @message || 'Something went wrong!'
  end
end