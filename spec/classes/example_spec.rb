require 'spec_helper'

describe 'pe_failover' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "pe_failover class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('pe_failover::params') }
          it { is_expected.to contain_class('pe_failover::install').that_comes_before('pe_failover::config') }
          it { is_expected.to contain_class('pe_failover::config') }
          it { is_expected.to contain_class('pe_failover::service').that_subscribes_to('pe_failover::config') }

          it { is_expected.to contain_service('pe_failover') }
          it { is_expected.to contain_package('pe_failover').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'pe_failover class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('pe_failover') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
