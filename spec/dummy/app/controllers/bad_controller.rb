class BadController < ApplicationController
  def index
    raise ArgumentError
  end
end
