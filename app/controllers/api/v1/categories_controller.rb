class Api::V1::CategoriesController < ApplicationController

  def index
    categories = Category.all
    #render json: categories
    render json: CategorySerializer.new(categories)
  end
  
end
