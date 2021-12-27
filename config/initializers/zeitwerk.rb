ActiveSupport::Dependencies
  .autoload_paths
  .delete("#{Rails.root}/app/services")

module Services; end
