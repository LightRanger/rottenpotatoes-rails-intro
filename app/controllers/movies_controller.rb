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
    redirectRatings = false;
    redirectSort = false;
    
    allRatings = Hash.new
    @all_ratings.each do |r|
      allRatings[r] = true
    end
    
    if (session[:ratings] != nil && session[:ratings] != allRatings && params[:ratings] == nil)
      redirectRatings = true;
    end
    
    session[:ratings] ||= allRatings
    params[:ratings] ||= session[:ratings]
    
    if params.has_key?(:ratings)
      key_list = params[:ratings].keys
      ratingList = Array.new
      for key in key_list do
          @actual_ratings[key] = true
          ary = [key]
          ratingList.concat(ary)
      end
      
      if key_list == nil
        params[:ratings] = session[:ratings]
        @actual_ratings = params[:ratings]
      end
      
      @all_ratings.each do |r|
        if !params[:ratings].has_key?(r)
          @actual_ratings[r] = false
        end
      end
    end
    
    session[:ratings] = params[:ratings]
    
    @movies = Movie.with_ratings(ratingList)
    
    if  (session[:sort] != nil && params[:sort] == nil)
      redirectSort = true;
    end
    
    session[:sort] ||= 'title'
    params[:sort] ||= session[:sort]
    
    if params[:sort] == 'date'
      @movies = @movies.order(:release_date)
      @release_date_header = 'hilite'
      session[:sort] = 'date'
    elsif params[:sort] == 'title'
      @movies = @movies.order(:title)
      @title_header = 'hilite'
      session[:sort] = 'title'
    end
    
    if redirectRatings or redirectSort
      redirect_to movies_path(params) and return
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
