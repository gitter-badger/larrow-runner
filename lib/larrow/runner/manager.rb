require 'larrow/runner/model/app'
require 'larrow/runner/model/node'

module Larrow
  module Runner
    class Manager
      include Service

      attr_accessor :vcs
      attr_accessor :app
      def initialize target_url
        self.vcs = Vcs.parse target_url
      end

      def preload
        self.vcs.load_manifest
      end

      def go
        self.app = Model::App.new vcs
        allocate
        app.action
        release
      end

      def allocate
        app.assign node: Model::Node.new(*vm.create.first)
      end

      def release
        app.node.destroy
      end
    end
  end
end
