class ApplicationController < ActionController::Base
  def hello_world
    render json: { message: "Hello World" }, status: :ok
  end
end
