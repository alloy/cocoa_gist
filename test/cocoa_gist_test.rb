require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"

$:.unshift File.expand_path('../../lib', __FILE__)
require "cocoa_gist"

describe 'CocoaGist' do
  it "should lazy load the github user info once and return it as a hash" do
    CocoaGist.instance_variable_set(:@credentials, nil)
    CocoaGist.expects(:`).with('git config --global github.user').returns("alloy\n").times(1)
    CocoaGist.expects(:`).with('git config --global github.token').returns("secret\n").times(1)
    
    3.times do
      CocoaGist.credentials.should == { :user => 'alloy', :token => 'secret' }
    end
  end
end
