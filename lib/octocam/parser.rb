require 'optparse'

module Octocam
  class Parser

    BANNER = 'Usage: octocam [OPTIONS]'.freeze

    def self.parse_options(args)
      options = {
          owner: nil,
          repository: nil,
          base: 'develop',
          from: nil,
          to: nil
      }

      OptionParser.new do |opts|
        opts.banner = BANNER
        opts.version = Octocam::VERSION

        opts.accept(Time) do |s|
          begin
            Time.parse(s) if s
          rescue
            raise "#{s} is not date format. ex) 2015-08-22"
          end
        end

        opts.on('-o [NAME]', 'Username of the owner of target GitHub repo') do |v|
          options[:owner] = v
        end
        opts.on('-r [NAME]', 'target repository name') do |v|
          options[:repository] = v
        end
        opts.on('-b [NAME]', "base branch name (default:'develop')") do |v|
          options[:base] = v
        end
        opts.on('-f YYYY-MM-DD', Time, 'From date of merged date') do |v|
          options[:from] = v
        end
        opts.on('-t YYYY-MM-DD', Time, 'To date of merged date') do |v|
          options[:to] = v
        end
        opts.parse(args)
      end

      if !options[:owner] || !options[:repository]
        options[:owner], options[:repository] = detect_owner_and_repository
      end

      options
    end

    private

    def self.detect_owner_and_repository
      remote = `git config --get remote.origin.url`

      # git@github.com:zephiransas/octocam.git
      match = /.*(?:[:\/])((?:-|\w|\.)*)\/((?:-|\w|\.)*)(?:\.git).*/.match(remote)
      if match
        puts "Detected owner:#{match[1]}, repository:#{match[2]}"
        return [match[1], match[2]]
      end

      # https://github.com/zephiransas/octocam
      match = /.*\/((?:-|\w|\.)*)\/((?:-|\w|\.)*).*/.match(remote)
      if match
        puts "Detected owner:#{match[1]}, repository:#{match[2]}"
        return [match[1], match[2]]
      end

      []
    end

  end
end