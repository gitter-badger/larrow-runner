require_relative '../../spec_helper.rb'
module Larrow::Runner::Service
  describe Executor do
    subject{ Executor.new 'localhost', `whoami`.chomp, 22, nil }
    it 'normal command run'do
      outputs = ''
      subject.execute('echo aaa',verbose:true){|data| outputs << data}
      expect(outputs).to eq "aaa\n"
    end

    it 'command with base dir' do
      outputs = ''
      subject.execute('pwd', base_dir: '/opt',verbose:true) do |data|
        outputs << data
      end
      expect(outputs).to eq "/opt\n"
    end

    it 'fail command' do
      expect(->{subject.execute('false')}).to raise_error(ExecutionError)
    end
  end
end
