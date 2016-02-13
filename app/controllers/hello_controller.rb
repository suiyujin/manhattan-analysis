class HelloController < ApplicationController
  def greet_with_name
    render json: { message: "hello, #{params[:name]}!" }
  end
end
