require_relative '../base_generator'
module Howitzer
  # This class responsible for configuration files generation
  class ConfigGenerator < BaseGenerator
    def manifest
      { files:
        [
          { source: 'boot.rb', destination: 'config/boot.rb' },
          { source: 'custom.yml', destination: 'config/custom.yml' },
          { source: 'capybara.rb', destination: 'config/capybara.rb' },
          { source: 'default.yml', destination: 'config/default.yml' }
        ] }
    end

    protected

    def banner
      <<-EOF
  * Config files generation ...
      EOF
    end
  end
end
