require 'test_helper'

class UrlsControllerTest < ActionController::TestCase
  REFERRER_INDEX = 'https://www.testing.com/urls'
  REFERRER_NEW = 'https://www.testing.com/urls/new'

  setup do
    @url = urls(:one)
    @new_url = Url.new(:long_url => 'https://www.test1.com')
    @request.env['HTTP_REFERER'] = REFERRER_INDEX 
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:url)
  end

  test "should or should not get new, depends on admin permission" do
    get :new
    if UrlsController::ADMIN == 1
      assert_response :success
    else
      assert_response :unauthorized
    end
  end

  test "should create url, new url posted from index" do
    assert_difference('Url.count') do
      post :create, url: { long_url: @new_url.long_url }
    end

    assert_template :index
  end

  test "should create url, new url posted from new, with admin permission" do
    @request.env['HTTP_REFERER'] = REFERRER_NEW 

    if UrlsController::ADMIN == 1
      assert_difference('Url.count') do
        post :create, url: { long_url: @new_url.long_url }
      end

      last_id = Url.maximum(:id) 
      assert_redirected_to '/urls/' + last_id.to_s
    end
  end

  test "should not create url, existing url posted from index" do
    assert_no_difference('Url.count') do
      post :create, url: { long_url: @url.long_url }
    end

    assert_template :index
  end

  test "should not create url, existing url posted from new, with admin permission" do
    @request.env['HTTP_REFERER'] = REFERRER_NEW 

    if UrlsController::ADMIN == 1
      assert_no_difference('Url.count') do
        post :create, url: { long_url: @url.long_url }
      end

      url = Url.find_by(:long_url => @url.long_url)
      assert_redirected_to '/urls/' + url[:id].to_s
    end
  end

  test "should not create url, invalid url posted from index" do
    assert_no_difference('Url.count') do
      post :create, url: { long_url: 'abc' }
    end

    assert_template :index
  end

  test "should not create url, invalid url posted from new, with admin permission" do
    @request.env['HTTP_REFERER'] = REFERRER_NEW 

    if UrlsController::ADMIN == 1
      assert_no_difference('Url.count') do
        post :create, url: { long_url: 'abc' }
      end
      assert_template :new
    end
  end

  test "should or should not show url, depends on admin permission" do
    get :show, id: @url
    if UrlsController::ADMIN == 1
      assert_response :success
    else
      assert_response :unauthorized
    end
  end

  test "should or should not get edit, depends on admin permission" do
    get :edit, id: @url
    if UrlsController::ADMIN == 1
      assert_response :success
    else
      assert_response :unauthorized
    end
  end

  test "should or should not update new url, depends on admin permission" do
    patch :update, id: @url, url: { long_url: 'https://www.updated.com' }

    if UrlsController::ADMIN == 1
      assert_redirected_to url_path(assigns(:url))
    else
      assert_response :unauthorized
    end
  end

  test "should or should not update invalid url, depends on admin permission" do
    patch :update, id: @url, url: { long_url: 'abc' }

    if UrlsController::ADMIN == 1
      assert_template :edit
    else
      assert_response :unauthorized
    end
  end

  test "should or should not destroy url, depends on admin permission" do
    if UrlsController::ADMIN == 1
      assert_difference('Url.count', -1) do
        delete :destroy, id: @url
      end

      assert_redirected_to urls_list_path
    else
      assert_no_difference('Url.count', -1) do
        delete :destroy, id: @url
      end
      assert_response :unauthorized
    end
  end

  test "should redirect to long url" do
    get :purple, short_url: @url.short_url
    assert_redirected_to @url.long_url 
    assert_response :moved_permanently
  end

  test "should not redirect to long url" do
    get :purple, short_url: 'xx99'
    assert_response :bad_request
  end
end
