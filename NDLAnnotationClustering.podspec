Pod::Spec.new do |spec|
  spec.name = "NDLAnnotationClustering"
  spec.version = "1.0.0"
  spec.summary = "A drop-in map annotation clustering solution for iOS app"
  spec.homepage = "https://github.com/Nandalu/NDLAnnotationClustering"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Denken Chen" => 'denkenie@gmail.com' }
  spec.social_media_url = "https://twitter.com/denkeni"

  spec.platform = :ios, "9.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/Nandalu/NDLAnnotationClustering.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "NDLAnnotationClustering/**/*.{h,m}"
end
