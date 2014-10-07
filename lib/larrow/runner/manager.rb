require 'pry'
require 'pry-nav'
module Larrow::Runner
  class Manager
    include Service

    attr_accessor :vcs
    attr_accessor :app
    def initialize target_url
      signal_trap
      self.vcs = Vcs.detect target_url
      self.app = Model::App.new vcs
    end

    def signal_trap
      trap('INT') do
        RunLogger.title 'try to release'
        release
        ::Kernel.exit
      end
    end

    def go
      handle_exception do
        app.allocate
        app.action :all
      end
    end

    def build_image
      handle_exception do
        app.allocate
        app.build_image
      end
    end

    def build_server
      handle_exception do
        app.allocate
        app.deploy
      end
    end

    def handle_exception
      yield
    rescue => e
      if e.is_a? ExecutionError
        data = eval(e.message)
        RunLogger.level(1).err "Execute fail: "
        RunLogger.level(2).detail "cmd    -> #{data[:cmd]}"
        RunLogger.level(2).detail "stderr -> #{data[:errmsg]}"
      else
        debug? ? binding.pry : raise(e)
      end
    ensure
      release unless keep?
    end

    def debug?
      RunOption.key? :debug
    end

    def keep?
      RunOption.key? :keep
    end

    def release
      RunLogger.title 'release resource'
      begin_at = Time.new
      if app && app.node
        app.node.destroy if @state != :release
      end
      during = sprintf('%.2f', Time.new - begin_at)
      RunLogger.level(1).detail "released(#{during}s)"
    end
  end
end
