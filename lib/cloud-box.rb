require "cloud-box/version"
require "cloud-box/cli"
require "yaml"

module Cloud
  module Box
    def self.root
      File.expand_path '../..', __FILE__
    end

    def self.bin
      File.join root, 'bin'
    end

    def self.lib
      File.join root, 'lib'
    end
  end

  DROPBOX_YAML = File.join(Cloud::Box.root, 'private', 'config', 'dropbox.yml')
  DROPBOX_CONFIG = YAML.load_file(DROPBOX_YAML)["production"]

end
