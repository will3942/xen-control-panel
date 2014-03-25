require 'bundler/setup'
Bundler.require(:default)
require './db'
require 'open3'
require 'json'
require 'rack/csrf'

class ControlPanel < Sinatra::Base
  configure do
    set :protection, :session => true
    set :server, :puma
    use Rack::Csrf, :raise => true, :skip_if => lambda { |request|
      if request.env['CONTENT_TYPE'] == 'application/json' or request.body.read == ""
        return true
      else
        return false
      end
    }
  end

  register do
    def auth(type)
      condition do
        redirect '/users/logout' unless is_user?
      end
    end
  end

  helpers do
    def is_user?
      unless User.where(:username => session[:authenticated]).first.nil?
        return true
      else
        return false
      end
    end

    def get_id(username)
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['control_panel_key']
        config.consumer_secret     = ENV['control_panel_secret']
      end

      user = client.user(username).id
      return user
    end

    def current_user
      user = User.where(:username => session[:authenticated]).first
      return user
    end

    def in_users_vms(hostname)
      current_user.vms.each do |vm|
        if vm["hostname"] == hostname
          return true
        end
      end
      return false
    end

    def csrf_token
      Rack::Csrf.csrf_token(env)
    end

    def csrf_tag
      Rack::Csrf.csrf_tag(env)
    end
  end

  use OmniAuth::Builder do
    provider :twitter, ENV['control_panel_key'], ENV['control_panel_secret']
  end

  get '/' do
    redirect '/vms' if is_user?
    erb :index
  end

  get '/auth/:provider/callback' do
    id = get_id(env['omniauth.auth']['info']['nickname'])
    session[:authenticated] = id
    redirect '/vms'
  end

  get '/auth/failure' do
    erb :"login/failure"
  end

  get '/auth/:provider/deauthorized' do
    erb :"login/deauthorized"
  end

  get '/vms', :auth => :user do
    erb :"dashboard/index"
  end

  get '/vms/:hostname', :auth => :user do
    @hostname = params[:hostname]
    if in_users_vms(@hostname)
      @slice = Xen::Slice.find(@hostname)
    else
      @error = "VM not found, try going back and selecting another VM or email mail@definedcode.com"
    end
    erb :"dashboard/manage/hostname"
  end

  get '/vms/new', :auth => :user do
    @debian_releases = IO.read('./public/debian.txt').split("\n")
    @ubuntu_releases = IO.read('./public/ubuntu.txt').split("\n")
    erb :"dashboard/create"
  end

  post '/vms', :auth => :user do

  end

  put '/vms/:hostname/status', :auth => :user do
    @hostname = params[:hostname]
    if request.content_type == 'application/json' or request.accept? 'application/json'
      begin
        json = request.body.read
        @power_state = JSON.parse(json)["power_state"].to_i
      rescue JSON::ParserError => e
        @error = "Invalid content submitted."
      end
    else
      @power_state = params[:power_state].to_i
    end
    if @power_state == 1
      if in_users_vms(@hostname)
        @slice = Xen::Slice.find(@hostname)
        unless @slice.running?
          @slice.start
        end
      else
        @error = "VM not found, try going back and selecting another VM or email mail@definedcode.com"
      end
      erb :"dashboard/manage/start"
    elsif @power_state == 0
      if in_users_vms(@hostname)
        @slice = Xen::Slice.find(@hostname)
        if @slice.running?
          @slice.stop
        end
      else
        @error = "VM not found, try going back and selecting another VM or email mail@definedcode.com"
      end
      erb :"dashboard/manage/shutdown"
    else
      unless @error
        @error = "Invalid Power State."
      end
      erb :"errors/generic"
    end
  end

  get '/vms/:hostname/destroy', :auth => :user do
    @hostname = params[:hostname]
    if in_users_vms(@hostname)
      @slice = Xen::Slice.find(@hostname)
    else
      @error = "VM not found, try going back and selecting another VM or email mail@definedcode.com"
    end
    erb :"dashboard/manage/pre-destroy"
  end

  delete '/vms/:hostname', :auth => :user do
    @hostname = params[:hostname]
    if in_users_vms(@hostname)
      @slice = Xen::Slice.find(@hostname)
      config_file = @slice.config_file.filename
      @slice.stop

      disk = @slice.root_disk.path
      swap = disk.gsub('disk', 'swap')

      stdin, stdout, stderr = Open3.popen3('rm', '-f', config_file)

      stdin, stdout, stderr = Open3.popen3('lvremove', '-f', disk)
      disk_status = stdout.gets
      unless disk_status.include?("successfully removed")
        @error = "VM disk not removed, please email mail@definedcode.com"
      end

      stdin, stdout, stderr = Open3.popen3('lvremove', '-f', swap)
      swap_status = stdout.gets

      unless swap_status.include?("successfully removed")
        @error = "VM swap not removed, please email mail@definedcode.com"
      end

      vms = current_user.vms.where(hostname: @hostname).first.delete
    end
    erb :"dashboard/manage/destroy"
  end

  get '/users/logout' do
    session[:authenticated] = nil
    redirect '/'
  end

end

