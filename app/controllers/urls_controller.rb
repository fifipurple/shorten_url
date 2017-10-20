class UrlsController < ApplicationController
  before_action :set_url, only: [:show, :edit, :update, :destroy]
  before_action :check_admin_permission, only: [:new, :show, :edit, :update, :destroy]
  before_action :set_short_url_prefix, only: [:show, :list, :create]

  ADMIN = 0
  ALPHANUM = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).join
  BASE = ALPHANUM.length
  # To get short url key with at least 5 characters
  START_OFFSET = 100000000

  # GET /urls
  # GET /urls.json
  def index
    @url = Url.new
  end

  # GET /urls/list
  # GET /urls/list.json
  def list
    @urls = Url.all
    @admin = ADMIN
  end

  # GET /urls/new
  def new
    if url_params
      create
      return
    else
      @url = Url.new
    end
  end

  # POST /urls
  # POST /urls.json
  def create
    referrer = Rails.application.routes.recognize_path(request.referrer)
    
    @url = Url.new(url_params)
    @error = nil
    result_url = Url.find_by(:long_url => @url[:long_url])

    respond_to do |format|
      if result_url.nil?
        max_id = Url.maximum(:id) || 0
        num = START_OFFSET + max_id + 1
        short_key = encode(num) 
        @url[:short_url] = short_key

        if @url.save
          @new_url = @url
          @url = Url.new(:long_url => @new_url[:long_url], :short_url => @new_url[:short_url])
          if referrer[:action] == 'index'
            format.html { render :index  }
          else
            format.html { redirect_to @new_url, notice: "URL was successfully created."}
          end
        else
          @error = @url.errors.full_messages
          if referrer[:action] == 'index'
            format.html { render :index  }
          else
            format.html { render :new }
            format.json { render json: @url.errors, status: :unprocessable_entity }
          end
        end
      else
        if referrer[:action] == 'index'
          @url[:short_url] = result_url[:short_url]
          format.html { render :index }
        else
          format.html { redirect_to result_url, notice: "Existing URL. No URL is created." }
        end
      end
    end
  end

  # GET /urls/1
  # GET /urls/1.json
  def show
  end

  # GET /urls/1/edit
  def edit
  end

  # PATCH/PUT /urls/1
  # PATCH/PUT /urls/1.json
  def update
    respond_to do |format|
      if @url.update(url_params)
        format.html { redirect_to @url, notice: 'URL was successfully updated.' }
        format.json { render :show, status: :ok, location: @url }
      else
        format.html { render :edit }
        format.json { render json: @url.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /urls/1
  # DELETE /urls/1.json
  def destroy
    @url.destroy
    respond_to do |format|
      format.html { redirect_to urls_list_url, notice: 'URL was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def purple
    url = Url.find_by(:short_url => params[:short_url])

    if url.nil?
      respond_to do |format|
        format.html { render html: "Uh oh, couldn't find a link for the URL you clicked.",
          status: :bad_request }
      end
    else
      redirect_to url[:long_url], status: :moved_permanently
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_url
      @url = Url.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def url_params
      if params[:url].nil? || params[:url].empty?
      else
        return params.require(:url).permit(:long_url)
      end
    end

    def encode(num)
      str = ''

      while num > 0
        str << ALPHANUM[num.modulo(BASE)]
        num = num / BASE
      end

      return str.reverse
    end

    # NOTE: not being used for now
    def decode(str)
      num = 0
      str.each_char {|c| num = num * BASE + ALPHANUM.index(c) }
      return num;
    end

    def check_admin_permission
      unless ADMIN == 1
        respond_to do |format|
          format.html { render html: "No permission to perform this action.",
            status: :unauthorized }
        end
        return
      end
    end

    def set_short_url_prefix 
      @short_url_prefix = request.base_url + '/purple/'
    end
end
