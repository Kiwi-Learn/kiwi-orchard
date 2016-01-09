require 'sinatra/base'
require 'sinatra/flash'

require 'hirb'
require 'slim'

require 'httparty'

require 'chartkick'

class ApplicationController < Sinatra::Base
  helpers CourseHelpers, SearchHelpers, ApplicationHelpers, DateHelpers
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure do
    Hirb.enable
    set :session_secret, 'something'
    set :api_ver, 'api/v1'
  end

  configure :development, :test do
    set :api_server, 'https://kiwi-api.herokuapp.com'
  end

  configure :production do
    set :api_server, 'https://kiwi-api.herokuapp.com'
  end

  configure :production, :development do
    enable :logging
  end

  # Web App Views Methods
  app_get_root = lambda do
    slim :home
  end

  app_get_courses = lambda do
    response = HTTParty.get("#{settings.api_server}/#{settings.api_ver}/courselist")
    # logger.info "#{settings.api_server}/#{settings.api_ver}/courselist"
    @courselist = JSON.parse(response.body)
    slim :courses
  end

  app_get_courses_info = lambda do
    response = HTTParty.get("#{settings.api_server}/#{settings.api_ver}/info/#{params[:id]}.json")
    @single_course = JSON.parse(response.body)

    request_url = "#{settings.api_server}/#{settings.api_ver}/couseserial/#{params[:id]}"
    video_stat = VedioStatisticsAPI.new(request_url).call
    @video_chartdata = video_stat.chart_data

    logger.info @video_chartdata
    slim :course_info
  end

  app_get_search = lambda do
    date = formatter(Time.yesterday)
    request_url = "#{settings.api_server}/#{settings.api_ver}/popularity/#{date}"
    keyword_stat = KeywordStatisticsAPI.new(request_url).call
    @keyword_chartdata = keyword_stat.chart_data
    @keyword_tabledata = keyword_stat.table_data
    slim :search
  end

  app_post_search =lambda do
    form = SearchForm.new(params)
    # logger.info form
    request_url = "#{settings.api_server}/#{settings.api_ver}/search"
    error_send(back, "Following fields are required: #{form.error_fields}") \
      unless form.valid?

    results = CheckSearchFromAPI.new(request_url, form).call

    if (results.nil?)
      flash[:notice] = 'Could not found course'
      redirect '/search'
      return nil
    end

    @courselist = results
    slim :courses
  end

  app_get_statistics = lambda do
    request_url = "#{settings.api_server}/#{settings.api_ver}/courselist"
    results = GetCoursesDateStatisticsAPI.new(request_url).call
    @chart_data_2016 = results.twenty_sixteen
    @chart_data_2015 = results.twenty_fifteen
    @chart_data_2014 = results.twenty_fourteen
    @chart_data_2013 = results.twenty_thirteen
    @chart_data_2012 = results.twenty_twelve

    institution_result = InstitutionsStatisticsResultAPI.new(request_url).call
    @institution_top10data = institution_result.top10_data
    logger.info @institution_top10data

    slim :statistics
  end

  # Web App Views Routes
  get '/', &app_get_root
  get '/courses', &app_get_courses
  get '/courses/:id', &app_get_courses_info
  get '/search' , &app_get_search
  post '/search' ,&app_post_search
  get '/statistics' ,&app_get_statistics

end
