use_frameworks!
platform :ios, '10.0'

target 'ClipboardManager' do
    pod 'RealmSwift'
    pod 'DateToolsSwift'

    target 'ClipboardManagerTests' do
        inherit! :search_paths
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        puts target.name
    end
end
