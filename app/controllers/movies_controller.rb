class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    @actual_ratings = Hash.new
    
    if params.has_key?(:ratings)
      key_list = params[:ratings].keys
      ratingList = Array.new
      for key in key_list do
          @actual_ratings[key] = true
          ary = [key]
          ratingList.concat(ary)
      end
      @all_ratings.each do |r|
        if !@actual_ratings.has_key?(r)
          @actual_ratings[r] = false
        end
      end
    else
      ratingList = Movie.ratings
      @all_ratings.each do |r|
        @actual_ratings[r] = true
      end
    end
    
    @movies = Movie.with_ratings(ratingList)
    
    if params[:sort] == 'date'
      @movies = @movies.order(:release_date)
      @release_date_header = 'hilite'
    else
      @movies = @movies.order(:title)
      @title_header = 'hilite'
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
end
