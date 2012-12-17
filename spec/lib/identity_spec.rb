require 'spec_helper'

describe ThePlatform::Identity do

  before(:each) do
    WebMock.reset!

    duration = ""
    idleTimeout = ""
    userName = "user"
    password = "secret"
    form = "json"
    schema = "1.0"
    time = 1111111
    token = '1nb2wzDV8Pd5eGDJhZjRgRBdkEDgsJDm'
    userId = 'https://identity.auth.theplatform.com/idm/data/User/mps/1111'

    @signInURL = ThePlatform::IDENTITY + 'signIn'

    @query = { "form" => form,
               "password" => password,
               "schema" => schema,
               "username" => userName,
               "_duration" => duration }

    @response = { "signInResponse" => {
                  "userName" => userName,
                  "duration" => time,
                  "token" => token,
                  "userId" => userId,
                  "idleTimeout" => time }
                }

  end

  describe 'default attributes' do

    it 'should include HTTParty methods' do
      ThePlatform::Identity.should include HTTParty
    end

  end

  describe "#signin_response" do

      # stub "valid credentials" identity call
      before(:each) do
        # reset anything from previous tests
        WebMock.reset!
        stub_request(:get, @signInURL).with(:query => @query).to_return(:body => {}, :status => 200, :headers => {})
      end

    it "should call signIn endpoint with parameters" do
      ThePlatform::Identity.stub(:signin_response) { HTTParty.get(@signInURL, query: @query) }
      ThePlatform::Identity.signin_response(@query)
      WebMock.should have_requested(:get, @signInURL)
             .with(:query => hash_including(@query))
    end

    it "should return a Hash with signIn information" do
      ThePlatform::Identity.stub(:get) { @response }
      ThePlatform::Identity.signin_response.should == @response['signInResponse']
    end

    it "should bubble up any exception" do
      stub_request(:any, @signInURL)
                  .with(:query => hash_including({}))
                  .to_raise(Exception)

      expect {ThePlatform::Identity.signin_response(@query)}.to raise_error(Exception)
    end

  end

  describe "#token" do

    it "should return only the :token from #signin_response" do
      ThePlatform::Identity.stub(:signin_response) { @response['signInResponse'] }
      puts ThePlatform::Identity.token(@query).should == @response['signInResponse']['token']
    end

  end

  describe "#invalidate!" do
    before(:all) do
      @signOutURL = ThePlatform::IDENTITY + 'signOut'
    end

    before(:each) do
      WebMock.reset!

      stub_request(:any, @signOutURL)
                  .with(:query => hash_including({}))
                  .to_return(:status => 200, :body => {}, :headers => {})
    end

    it "should call signOut endpoint with parameters" do
      @token = 'foo'

      ThePlatform::Identity.invalidate!(@token)

      WebMock.should have_requested(:get, @signOutURL)
             .with(:query => hash_including({"_token" => @token}))
    end

    it "should return a HTTParty::Response from the web request" do
      ThePlatform::Identity.invalidate!(@token).class.should == HTTParty::Response
    end

    it "should bubble up any exception" do
      stub_request(:any, @signOutURL)
                  .with(:query => hash_including({}))
                  .to_raise(Exception)

      expect {ThePlatform::Identity.invalidate!(@token)}.to raise_error(Exception)
    end

  end

  describe "#count" do
    before(:all) do
      @getTokenCountURL = ThePlatform::IDENTITY + 'getTokenCount'
    end

    before(:each) do
      WebMock.reset!

      stub_request(:any, @getTokenCountURL)
                  .with(:query => hash_including({}))
                  .to_return(:status => 200, :body => {}, :headers => {})
    end

    it "should call getTokenCount endpoint with parameters" do
      ThePlatform::Identity.count(foo: 'bar')

      WebMock.should have_requested(:get, @getTokenCountURL)
             .with(:query => hash_including({"foo" => 'bar'}))
    end

    it "should return a HTTParty::Response from the web request" do
      ThePlatform::Identity.count({}).class.should == HTTParty::Response
    end

    it "should bubble up any exception" do
      stub_request(:any, @getTokenCountURL)
                  .with(:query => hash_including({}))
                  .to_raise(Exception)

      expect {ThePlatform::Identity.count(foo:'bar')}.to raise_error(Exception)
    end

  end

end
