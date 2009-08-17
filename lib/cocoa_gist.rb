require 'osx/cocoa'

class CocoaGist < OSX::NSObject
  def self.credentials
    @credentials ||= {
      :user =>  `git config --global github.user`,
      :token => `git config --global github.token`
    }
  end
end