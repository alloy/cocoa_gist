require 'osx/cocoa'
require 'cgi'

class CocoaGist < OSX::NSObject
  REQUEST_URL = OSX::NSURL.URLWithString('http://gist.github.com/gists')
  TIMEOUT = 10
  POLICY = 1 # NSURLRequestReloadIgnoringLocalCacheData
  
  attr_reader :connection
  
  def self.credentials
    @credentials ||= {
      'login' => `git config --global github.user`.strip,
      'token' => `git config --global github.token`.strip
    }.reject { |_, v| v.empty? }
  end
  
  def start(content, syntax = 'ruby')
    request = post_request(params(content))
    @connection = OSX::NSURLConnection.alloc.initWithRequest_delegate(request, self)
  end
  
  private
  
  def post_request(body)
    request = OSX::NSMutableURLRequest.requestWithURL_cachePolicy_timeoutInterval(REQUEST_URL, POLICY, TIMEOUT)
    request.setHTTPMethod('POST')
    request.setHTTPBody(OSX::NSData.dataWithRubyString(body))
    request
  end
  
  def params(content)
    params = { 'file_contents[gistfile1]' => content }.merge(self.class.credentials)
    params.inject('') { |body, (key, value)| body << "#{key}=#{CGI.escape(value)}&" }.chop
  end
end