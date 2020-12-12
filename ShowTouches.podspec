Pod::Spec.new do |s|
	s.name = 'ShowTouches'
	s.version = ENV["RELEASE_VERSION"]
	s.license = 'MIT'
	s.summary = 'Visualize touches.'
	s.homepage = 'https://github.com/Cyberbeni/ShowTouches'
	s.authors = { 'Benedek Kozma' => 'cyberbeni@gmail.com' }
	s.source = { :git => 'https://github.com/Cyberbeni/ShowTouches.git', :tag => 'v' + s.version.to_s }
 
	s.ios.deployment_target = '8.0'
 
	s.swift_version = '5.0'
 
	s.source_files = 'Sources/ShowTouches/**/*.swift'
 end