require 'osx/cocoa'

class CocoaGist < OSX::NSObject
  def self.credentials
    @credentials ||= {
      :user =>  `git config --global github.user`.strip,
      :token => `git config --global github.token`.strip
    }
  end
end