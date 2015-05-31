# Uncomment this line to define a global platform for your project
platform :osx, '10.10'

link_with 'Reader'

target 'Reader' do
	use_frameworks!
	pod 'Swift-Collections', :git => 'https://github.com/mrniket/Swift-Collections'
	pod 'MendeleyKit', :git => 'https://github.com/Mendeley/mendeleykit.git'
	pod 'SVGKit', :git => 'https://github.com/MaddTheSane/SVGKit.git'
	pod 'JNWCollectionView'
end

target 'ReaderTests' do
	use_frameworks!
	pod 'Swift-Collections', :git => 'https://github.com/mrniket/Swift-Collections'
	pod 'Nimble', '~> 0.4.0'
	pod 'MendeleyKit', :git => 'https://github.com/Mendeley/mendeleykit.git'
	pod 'SVGKit', :git => 'https://github.com/MaddTheSane/SVGKit.git'
	pod 'JNWCollectionView'
end