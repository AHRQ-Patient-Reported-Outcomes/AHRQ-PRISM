require_relative '../base'
require_relative '../models/current_user'
require 'sinatra/param'

class ControllerBase < Base
  helpers Sinatra::Param

  before do
    content_type :json
    set_current_user

    info = {
      current_user: current_user ? current_user.id : '',
      path: request.path,
      request_method: request.request_method
    }
    logger.info("responding to #{info.inspect}")
  end

  def current_user
    @current_user ||= set_current_user
  end

  def set_current_user
    @current_user = ::Models::CurrentUser.new(env['rack.session'] || {})
  end
end
