
Pod::Spec.new do |s|
  s.name         = "Jayme"
  s.version      = "1.0.4"
  s.summary      = "Abstraction layer that eases RESTful interconnections in Swift"
  s.description  = <<-DESC
                   What's the best place to put your entities business logic code? What's the best place to put your networking code? Jayme answers those two existencial questions by defining a straightforward and extendable architecture based on Repositories and Backends. It provides a neat API for dealing with REST communication, leaving your ViewControllers out of that business by abstracting all that logic, thereby allowing them to focus on what they should do rather on how they should connect to services.
                   DESC

  s.homepage     = "https://github.com/inaka/Jayme/tree/master"
  s.screenshots  = "https://raw.githubusercontent.com/inaka/Jayme/master/Assets/logo.png"

  s.license = 'MIT'
  s.author    = "Inaka"
  s.social_media_url   = "http://twitter.com/inaka"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/inaka/Jayme.git", :tag => s.version }
  s.source_files  = "Jayme/**/*.swift"
end