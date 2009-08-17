require 'osx/cocoa'
require 'cgi'

class CocoaGist < OSX::NSObject
  REQUEST_URL = OSX::NSURL.URLWithString('http://gist.github.com/gists')
  TIMEOUT = 10
  POLICY = 1 # NSURLRequestReloadIgnoringLocalCacheData
  
  attr_accessor :delegate
  attr_reader :connection, :response
  
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
  
  def connection_willSendRequest_redirectResponse(_, request, response)
    if response && response.statusCode == 302
      @delegate.pastie_on_success(self, request.URL.absoluteString)
      nil
    else
      request
    end
  end
  
  # def connection_didFailWithError(conn, err)
  #   p err.userInfo[:NSLocalizedDescription]
  # end
  
  private
  
  def post_request(body)
    request = OSX::NSMutableURLRequest.requestWithURL_cachePolicy_timeoutInterval(REQUEST_URL, POLICY, TIMEOUT)
    request.setHTTPMethod('POST')
    request.setHTTPBody(OSX::NSData.dataWithRubyString(body))
    request
  end
  
  def params(content, syntax)
    self.class.credentials.merge({
      'file_contents[gistfile1]' => content,
      'file_ext[gistfile1]'      => syntax_ext(syntax)
    }).inject('') { |body, (key, value)| body << "#{key}=#{CGI.escape(value)}&" }.chop
  end
  
  def syntax_ext(syntax)
    SYNTAX_TO_EXT[syntax.downcase]
  end
  
  SYNTAX_TO_EXT = {
    'c'            => '.h',
    'css'          => '.css',
    'diff'         => '.diff',
    'haskell'      => '.hs',
    'html'         => '.htm',
    'java'         => '.java',
    'javascript'   => '.js',
    'objective-c'  => '.m',
    'perl'         => '.pl',
    'php'          => '.php',
    'plain text'   => '.txt',
    'python'       => '.py',
    'ruby'         => '.rb',
    'scheme'       => '.scm',
    'shell script' => '.sh',
    'sql'          => '.sql'
  }
end