class IslandsController < ApplicationController
  before_action :set_island, only: %i[show edit update destroy]
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    if params[:query].present?
      @islands = policy_scope(Island).search_by_name_and_location(params[:query])
    else
      @islands = policy_scope(Island)
    end
  end

  def show
    p @island
    @review = Review.new(island: @island)
    @markers = [
      {
        lat: @island.latitude,
        lng: @island.longitude,
        info_window: render_to_string(partial: "info_window", locals: { island: @island }),
        image_url: helpers.asset_url("noun-island-1442323.png")
      }
    ]
    skip_authorization
  end

  def new
    @island = Island.new
    skip_authorization
  end

  def create
    @island = Island.new(island_params)
    @island.user = current_user
    if @island.save
      redirect_to island_path(@island)
    else
      render :new, status: :unprocessable_entity
    end
    skip_authorization
  end

  def edit
    authorize @island
  end

  def update
    if @island.update(island_params)
      redirect_to island_path(@island)
    else
      render :new, status: :unprocessable_entity
    end
    authorize @island
  end

  def destroy
    p"entrnado"
    @island.destroy
    redirect_to profile_islands_path, status: :see_other
    authorize @island
  end

  private

  def set_island
    if island_exists?
      @island = Island.find(params[:id])
    else
      redirect_to islands_path, status: :see_other
    end
  end

  def island_params
    params.require(:island).permit(:name, :description, :price, :location, photos: [])
  end

  def island_exists?
    Island.all.any? { |island| island.id == params[:id].to_i }
  end
end
