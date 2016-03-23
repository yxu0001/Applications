Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "ContentFeed"
s.summary = "ContentFeed framework"
s.requires_arc = true

# 2
s.version = "0.0.1"

# 3
s.license = "Copyright © 2016 athenahealth. All rights reserved."

# 4 - Replace with your name and e-mail address
s.author = { "Bridges-Dev" => "Bridges-Dev@athenahealth.com" }

# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "[ContentFeed github Homepage URL Goes Here]"

# For example,
# s.homepage = "http://www.athenahealth.com"


# 6 - Replace this URL with your own Git URL from "Quick Setup"
# We will have an error emitted because Pods couldn't find the the git url
s.source = { :git => "", :tag => s.version}
# s.source = { :git => "https://github.com/JRG-Developer/RWPickFlavor.git", :tag => "#{s.version}"}


# 7
s.framework = "UIKit"
s.dependency 'SwiftyJSON'

# 8
s.source_files = "ContentFeed/**/*.{swift}"

# 9
s.resources = "ContentFeed/**/*.{png,jpeg,jpg,storyboard,xib}"
end
