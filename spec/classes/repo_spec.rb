require 'spec_helper'

describe 'logstashforwarder::repo', :type => 'class' do

  default_params = {
    :servers  => [ '192.168.0.1' ],
    :ssl_ca   => '/path/to/ssl.ca',
    :ssl_key  => '/path/to/ssl.key',
    :ssl_cert => '/path/to/ssl.cert'
  }

  on_supported_os.each do |os, facts|

    context "on #{os} OS" do

      let (:facts) {
        facts
      }

      let (:params) {
        default_params   
      }

      context 'When managing the repository' do

        let (:params) {
          default_params.merge({
            :manage_repo => true,
          })
        }
        case facts[:osfamily]
        when 'Debian'
          it { should contain_class('apt') }
          it { should contain_apt__source('logstashforwarder').with(:release => 'stable', :repos => 'main', :location => 'http://packages.elasticsearch.org/logstashforwarder/debian') }
        when 'RedHat'
          it { should contain_yumrepo('logstashforwarder').with(:baseurl => 'http://packages.elasticsearch.org/logstashforwarder/centos', :gpgkey => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch', :enabled => 1) }
        when 'SuSE'
          it { should contain_exec('logstashforwarder_suse_import_gpg') }
          it { should contain_zypprepo('logstashforwarder').with(:baseurl => 'http://packages.elasticsearch.org/logstashforwarder/centos') }
        end

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
