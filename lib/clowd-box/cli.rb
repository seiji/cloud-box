require 'thor'
require 'dropbox_sdk'

module Clowd
  module Box
    class CLI < Thor
      CHUNK_SIZE = 4*1024*1024

      def initialize(*args)
        super
        @dropbox = DropboxClient.new(DROPBOX_CONFIG['access_token'])
      end
      
      desc "info", "print account_info"
      def info
        account = @dropbox.account_info
        account_name = account['display_name']

        puts "[Dropbox @#{account_name}]"
        quota_info = account['quota_info']
        quota_info.each do |k,v|
          bytes = v
          unit = " B"
          %w(KB MB GB).each do |u|
            if bytes > 1024.00
              unit = u
              bytes /= 1024.00
            end
          end
          puts "  %-10s %20.2f %s" % [k, bytes, unit]
        end
      end
        
      desc "list [path]", "list ur directories"
      def list(path = '/')
        root_metadata = @dropbox.metadata path
        puts "-" * 60
        puts "dropbox /"
        puts "-" * 60
        root_metadata["contents"].each do |content|
          modified = DateTime.parse(content['modified']) + Rational(9,24)
          puts "%-16s %-16s %s" % [
                                   content['icon'].sub('page_white_', ''),
                                   modified.strftime('%a %m/%d %Y'),
                                   content['path'].sub('/', ''),
                                  ]
        end
      end

      desc "mv [from_path] [to_path]", "move a file"
      def mv(from, to)
        @dropbox.file_move(from, to)
      end
      
      desc "push [src] [dst]", "upload ur file"
      def push(src, dst)
        src_path = Pathname.new src
        dst_path = Pathname.new dst
        unless src_path.exist?
          puts "File not found: #{src}"
          return
        end
        
        if src_path.directory?
          Dir["#{src}/**/*"].reject {|fn|
            File.directory?(fn) || File.extname(fn) == '.mov'
          }.each do |f|
            puts f
            pathname = Pathname f
            push_path = dst_path.join(pathname.relative_path_from(src_path))
            upload(push_path, pathname)
          end
        else
          upload(dst_path, src_path)
        end
      end

      desc "mkdir [path]", "make dir"
      def mkdir(path)
        begin
          @dropbox.file_create_folder(path)
        rescue DropboxError => e
          puts e
        ensure
          list
        end
      end

      desc "rmdir [path]", "remove dir"
      def rmdir(path)
        begin
          @dropbox.file_delete(path)
        rescue DropboxError => e
          puts e
        ensure
          list
        end
      end

      private
      def upload(dst_path, src_path)
        if src_path.size > 150 * 1024 * 1024
          puts src_path
          uploader = @dropbox.get_chunked_uploader(File.new(src_path.to_s, "r"), src_path.size)
          retries  = 0

          while uploader.offset < uploader.total_size
            puts uploader.offset
            begin
              uploader.upload(CHUNK_SIZE)
            rescue DropboxError => e
              if retries > 10
                  break;
              end
              retries += 1
            end
          end
          uploader.finish(dst_path.to_s, true)
          exit
        else
#          @dropbox.put_file(dst_path.to_s, src_path.open)
        end
      end
    end
  end
end
