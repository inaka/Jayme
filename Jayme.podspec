
Pod::Spec.new do |s|
  s.name         = "Jayme"
  s.version      = "2.0.2"
  s.summary      = "An abstraction layer that eases RESTful interconnections in Swift"
  s.description  = <<-DESC
                   Jayme defines a neat architecture for REST management in your Swift code. The idea behind this library is to separate concerns: Your view controllers should handle neither networking code nor heavy business logic code, in order to stay lightweight. The library provides a neat API to deal with REST communication, as well as default implementations for basic CRUD functionality and pagination.
                   DESC

  s.homepage     = "https://github.com/inaka/Jayme/tree/master"
  s.screenshots  = "https://raw.githubusercontent.com/inaka/Jayme/master/Assets/logo.png"
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  s.author    = "Inaka"
  s.social_media_url   = "http://twitter.com/inaka"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/inaka/Jayme.git", :tag => s.version }
  s.source_files  = "Jayme/**/*.swift"
end