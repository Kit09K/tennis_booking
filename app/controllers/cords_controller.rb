class CordsController < ApplicationController
  def index
    @cords = Cord.all
  end
end
