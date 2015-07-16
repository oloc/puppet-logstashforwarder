require 'spec_helper'

describe 'logstashforwarder', :type => 'class' do

  default_params = {
    :servers  => [ '192.168.0.1' ],
    :ssl_ca   => '/path/to/ssl.ca',
    :ssl_key  => '/path/to/ssl.key',
    :ssl_cert => '/path/to/ssl.cert'
  }
  
  context "on an unknown OS" do
    context "it should fail" do
      let :facts do {
        :operatingsystem => 'Windows',
      } end
      it { expect { should raise_error(Puppet::Error) } }
    end
  end

  on_supported_os.each do |os, facts|

    context "on #{os} OS" do

      let (:facts) {
        facts
      }

      let (:params) {
        default_params   
      }

      context 'main class tests' do
        it { should contain_class('logstashforwarder::repo') }
        it { should contain_class('logstashforwarder::config') }
        it { should contain_class('logstashforwarder::service') }

        it { should contain_class('logstashforwarder::repo').that_notifies('Class[logstashforwarder::package]') }
        it { should contain_class('logstashforwarder::config').that_subscribes_to('Class[logstashforwarder::package]') }
        it { should contain_class('logstashforwarder::service').that_subscribes_to(['Class[logstashforwarder::package]', 'Class[logstashforwarder::config]']) }
        
        #it { should contain_file('/etc/logstash-forwarder/logstash-forwarder.conf') }
        #it { should contain_file('/etc/logstash-forwarder/ssl') }
        #it { should contain_logstashforwarder__config('lsf-config') }
      end

      context 'when setting the module to absent' do
        let (:params) {
          default_params.merge({
            :ensure => 'absent'
          })
        }

        it { should contain_file('/etc/logstash-forwarder/logstash-forwarder.conf').with(:ensure => 'absent', :force => true, :recurse => true) }
        it { should contain_package('logstash-forwarder').with(:ensure => 'purged') }
        it { should contain_service('logstash-forwarder').with(:ensure => 'stopped', :enable => false) }
      end
    
    end
  end
end
