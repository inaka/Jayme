
Pod::Spec.new do |s|
  s.name         = "Jayme"
  s.version      = "4.0.2"
  s.summary      = "An abstraction layer that eases RESTful interconnections in Swift"
  s.description  = <<-DESC
                   Jayme is a Swift library that provides you with a set of tools which reduce drastically the amount of code you have to write to perform CRUD operations to a RESTful API. It also encapsulates networking code, encouraging you to separate networking and business logic code out of your view controllers.
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