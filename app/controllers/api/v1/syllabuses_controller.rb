class Api::V1::SyllabusesController < ApplicationController

  def index
    syllabuses = Syllabus.all
    # render json: syllabuses
    render json: SyllabusSerializer.new(syllabuses)
    # options = {
    #   # inlcude associated category
    #   include: [:category]
    # }
    # to add a relationship in serializer
    # render json: SyllabusSerializer.new(syllabuses, options)
  end

  def create
    syllabus = Syllabus.new(syllabus_params)
    if syllabus.save
      render json: SyllabusSerializer.new(syllabus), status: :accepted
    else
      render json: {errors: syllabus.errors.full_messages}, status: :unprocessible_entity
    end
  end

  private

  def syllabus_params
    params.require(:syllabus).permit(:title, :description, :image_url, :category_id)
  end

end
