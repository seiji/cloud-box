require 'thor'

module Clowd
  module Box
    class CLI < Thor
      def initialize(*args)
        super
        DROPBOX_YAML = File.join(DataHub.root, 'private', 'config', 'dropbox.yml')
        DROPBOX_CONFIG = YAML.load_file(DROPBOX_YAML)["production"]
      end
      desc "red", "print red"
      def red(txt)
        say txt, :red
      end

      desc "list" "list ur directories"
      def list
        
      end
    end
  end
end
