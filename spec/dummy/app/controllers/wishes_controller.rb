class WishesController < ApplicationController
  before_action :set_wish, only: [:show, :edit, :update, :destroy]

  def plain
  end

  def locals
  end

  def local_models
  end

  def numbers
  end

  # GET /wishes
  def index
    @wishes = Wish.all
  end

  # GET /wishes/1
  def show
  end

  # GET /wishes/new
  def new
    @wish = Wish.new
  end

  # GET /wishes/1/edit
  def edit
  end

  # POST /wishes
  def create
    @wish = Wish.new(wish_params)

    if @wish.save
      redirect_to @wish, notice: 'Wish was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /wishes/1
  def update
    if @wish.update(wish_params)
      redirect_to @wish, notice: 'Wish was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /wishes/1
  def destroy
    @wish.destroy
    redirect_to wishes_url, notice: 'Wish was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wish
      @wish = Wish.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def wish_params
      params.require(:wish).permit(:text)
    end
end
