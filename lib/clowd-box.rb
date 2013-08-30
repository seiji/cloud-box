require "clowd-box/version"
require "clowd-box/cli"
require "yaml"

module Clowd
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

  DROPBOX_YAML = File.join(Clowd::Box.root, 'private', 'config', 'dropbox.yml')
  DROPBOX_CONFIG = YAML.load_file(DROPBOX_YAML)["production"]

end
