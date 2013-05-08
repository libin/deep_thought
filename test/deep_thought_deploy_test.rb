require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtDeployTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def setup
    DatabaseCleaner.start

    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    @user = DeepThought::User.create(:email => 'test@test.com', :password => 'secret', :password_confirmation => 'secret', :api_key => '12345')
  end

  def teardown
    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    DatabaseCleaner.clean
  end

  def app
    DeepThought.app
  end

  def test_deploy_unauthorized
    get '/deploy/'
    assert !last_response.ok?
    assert_equal last_response.status, 401
  end

  def test_deploy_get
    get '/deploy/', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "I don't got what you're trying to GET.", last_response.body
  end

  def test_deploy_post_empty
    post '/deploy/', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "Must supply app name.", last_response.body
  end

  def test_deploy_setup_success
    post '/deploy/setup/test', params={:repo_url => 'http://fake.url', :deploy_type => 'capy'}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert last_response.ok?
  end

  def test_deploy_setup_failed
    post '/deploy/setup/test', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "Sorry, but I need a project name, repo url, and deploy type. No exceptions, despite how nicely you ask.", last_response.body
  end

  def test_deploy_non_project
    post '/deploy/test', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "Hmm, that project doesn't appear to exist. Have you set it up?", last_response.body
  end

  def test_deploy_no_repo
    project = DeepThought::Project.create(:name => '_test', :repo_url => 'http://fake.url', :deploy_type => 'capy')
    post '/deploy/_test', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "Woah - I can't seem to access that repo. Are you sure the URL is correct and that I have access to it?", last_response.body
  end

  def test_deploy_no_branch
    project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'capy')
    post '/deploy/_test', params={:branch => 'no-branch'}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "Hmm, that branch doesn't appear to exist. Have you pushed it?", last_response.body
  end
end
