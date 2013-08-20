require "spec_helper"
load "bin/howitzer"

shared_examples "check argument" do |arg|
  before do
    stub_const("ARGV", [arg])
    expect(self).to_not receive(:puts)
    expect(self).to_not receive(:exit)
  end
  context "(#{arg})" do
    let(:arg) { arg }
    it { expect(subject).to be_nil }
  end
end

describe Howitzer do
  describe "#check_arguments" do
    subject { check_arguments }
    context "when right arguments specified" do
      it_behaves_like "check argument", 'install --cucumber'
      it_behaves_like "check argument", 'install --rspec'
      it_behaves_like "check argument", 'install --cucumber --rspec'
      it_behaves_like "check argument", 'install --rspec --cucumber'
      it_behaves_like "check argument", '--version'
      it_behaves_like "check argument", '--help'
      it_behaves_like "check argument", '--HELP'
    end
    context "when arguments incorrect" do
      before do
        expect(self).to receive(:puts).with("ERROR: incorrect options. Please, see help for details").once
        expect(self).to receive(:puts).with(%{
howitzer [command {--cucumber, --rspec}] | {options}

Commands are ...
    install                  Generate test framework units:
          --rspec                add RSpec integration with framework
          --cucumber             add Cucumber integration with framework
Options are ...
    --help                   Display this help message.
    --version                Display the program version.
  })
        expect(self).to receive(:exit).with(1)
      end
      context "(missing arguments)" do
        it { expect(subject).to be_nil  }
      end
      context "UNKNOWN argument" do
        let(:arg) { '--unknown' }
        before { stub_const("ARGV", [arg]) }
        it { expect(subject).to be_nil }
      end
    end
  end


  describe "#parse_options" do
    subject { parse_options }
    context "when correct argument received" do
      before do
        stub_const("ARGV", arg)
        expect(self).not_to receive(:puts).with("ERROR: incorrect first argument '#{arg}'")
      end
      context "'--version' argument given" do
        let(:arg) { ['--version'] }
  before{ stub_const("Howitzer::VERSION", '1.0.0') }
        it do
          expect(self).to receive(:exit).with(0).once
          expect(self).to receive(:puts).with("Version: 1.0.0")
          subject
        end
      end
      context "'--help' argument given" do
        let(:arg) { ['--help'] }
        it do
          expect(self).to receive(:puts).with(
                                 %{
howitzer [command {--cucumber, --rspec}] | {options}

Commands are ...
    install                  Generate test framework units:
          --rspec                add RSpec integration with framework
          --cucumber             add Cucumber integration with framework
Options are ...
    --help                   Display this help message.
    --version                Display the program version.
  }
                             )
          subject
        end
      end
      context "'install' argument" do
        let(:primary_arg) { 'install' }
        let(:generator) { double('generator') }
        before do
          expect(generator).to receive(:run).with(%w[config]).once
          expect(generator).to receive(:run).with(['pages']).once
          expect(generator).to receive(:run).with(['tasks']).once
          expect(generator).to receive(:run).with(['emails']).once
          expect(generator).to receive(:run).with(['root']).once
        end
        context "with option == '--cucumber'" do
          let(:arg) { [primary_arg, '--cucumber'] }
          before { expect(RubiGen::Scripts::Generate).to receive(:new).exactly(6).times.and_return(generator)}
          it do
            expect(generator).to receive(:run).with(['cucumber']).once
            subject
           end
        end
        context "with option == '--rspec'" do
          let(:arg) {[primary_arg, '--rspec']}
          before { expect(RubiGen::Scripts::Generate).to receive(:new).exactly(6).times.and_return(generator)}
          it do
            expect(generator).to receive(:run).with(['rspec']).once
            subject
          end
        end
        context "with UNKNOWN option specified" do
          let(:arg) {[primary_arg, '--unknown']}
          before do
            expect(RubiGen::Scripts::Generate).to receive(:new).exactly(5).times.and_return(generator)
            expect(self).to receive(:puts).with("ERROR: unknown '--unknown' option for 'install' command")
            expect(self).to receive(:puts).with(
                                %{
howitzer [command {--cucumber, --rspec}] | {options}

Commands are ...
    install                  Generate test framework units:
          --rspec                add RSpec integration with framework
          --cucumber             add Cucumber integration with framework
Options are ...
    --help                   Display this help message.
    --version                Display the program version.
  }
                            )
          end
          it { subject }
        end
        context "with no option specified" do
          let(:arg) {[primary_arg,'']}
          before do
            expect(RubiGen::Scripts::Generate).to receive(:new).exactly(5).times.and_return(generator)
            expect(self).to receive(:puts).with("ERROR: unknown '' option for 'install' command")
            expect(self).to receive(:puts).with(
                                %{
howitzer [command {--cucumber, --rspec}] | {options}

Commands are ...
    install                  Generate test framework units:
          --rspec                add RSpec integration with framework
          --cucumber             add Cucumber integration with framework
Options are ...
    --help                   Display this help message.
    --version                Display the program version.
  }
                            )
          end
          it { subject }
        end
      end
    end
  end
end