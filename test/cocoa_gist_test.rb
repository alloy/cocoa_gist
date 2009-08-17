require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"

$:.unshift File.expand_path('../../lib', __FILE__)
require "cocoa_gist"

GITHUB_ACCOUNT = { 'login' => 'alloy', 'token' => 'secret' }

describe 'CocoaGist' do
  it "should lazy load the github user info once and return it as a hash" do
    CocoaGist.instance_variable_set(:@credentials, nil)
    CocoaGist.expects(:`).with('git config --global github.user').returns("alloy\n").times(1)
    CocoaGist.expects(:`).with('git config --global github.token').returns("secret\n").times(1)
    
    3.times do
      CocoaGist.credentials.should == GITHUB_ACCOUNT
    end
  end
  
  it "should return an empty hash if no account info was found" do
    CocoaGist.instance_variable_set(:@credentials, nil)
    CocoaGist.stubs(:`).returns('')
    CocoaGist.credentials.should == {}
  end
end

describe "A CocoaGist" do
  before do
    CocoaGist.instance_variable_set(:@credentials, GITHUB_ACCOUNT)
    
    @gist = CocoaGist.alloc.init
  end
  
  it "should serialize the parameters" do
    @gist.send(:params, 'the content').split('&').sort.should ==
      %w{ file_contents[gistfile1]=the+content  login=alloy  token=secret }.sort
  end
  
  it "should omit empty values from the serialized parameters" do
    CocoaGist.stubs(:credentials).returns({})
    @gist.send(:params, 'the content').should == 'file_contents[gistfile1]=the+content'
  end
  
  it "should post the paste contents" do
    @gist.expects(:params).with('the content').returns('the parameters')
    
    request = mock('NSMutableURLRequest')
    OSX::NSMutableURLRequest.expects(:requestWithURL_cachePolicy_timeoutInterval).with do |url, policy, timeout|
      url.absoluteString == 'http://gist.github.com/gists' && policy == 1 && timeout == 10
    end.returns(request)
    
    request.expects(:setHTTPMethod).with('POST')
    request.expects(:setHTTPBody).with do |body|
      body.rubyString == 'the parameters'
    end
    
    connection = mock('NSURLConnection')
    OSX::NSURLConnection.any_instance.expects(:initWithRequest_delegate).with(request, @gist).returns(connection)
    
    @gist.start('the content')
    @gist.connection.should.be connection
  end
end
