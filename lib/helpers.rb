Dir[File.expand_path('../helpers/**/*.rb', __FILE__)].each do |filename|
  require filename
end

include PartialsHelper
include CollectionHelper
include NavigationHelper
