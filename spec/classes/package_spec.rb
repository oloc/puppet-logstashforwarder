require 'spec_helper'

describe 'package', :type => 'class' do

  default_params = {
    :servers  => [ '192.168.0.1' ],
    :ssl_ca   => '/path/to/ssl.ca',
    :ssl_key  => '/path/to/ssl.key',
    :ssl_cert => '/path/to/ssl.cert'
  }
  
  on_supported_os.each do |os, facts|

    context "on #{os} OS" do

    it { should compile.and_raise_error(/error message match/) }

      case facts[:osfamily]
      when 'Debian'
        let(:defaults_path) { '/etc/default' }
        let(:pkg_ext) { 'deb' }
        let(:pkg_prov) { 'dpkg' }
      when 'RedHat'
        let(:defaults_path) { '/etc/sysconfig' }
        let(:pkg_ext) { 'rpm' }
        let(:pkg_prov) { 'rpm' }
      when 'Suse'
        let(:defaults_path) { '/etc/sysconfig' }
        let(:pkg_ext) { 'rpm' }
        let(:pkg_prov) { 'rpm' }
      end

      let (:facts) {
        facts
      }

      let (:params) {
        default_params   
      }

      context 'package installation' do
        context 'via repository' do

          context 'with default settings' do
           it { should contain_package('logstash-forwarder').with(:ensure => 'present') }
          end

          context 'with specified version 1.0' do
            let (:params) {
              default_params.merge({
              :version => '1.0'
              })
            }
            it { should contain_package('logstash-forwarder').with(:ensure => '1.0') }
          end

          context 'with auto upgrade enabled' do
            let (:params) {
              default_params.merge({
              :autoupgrade => true
              })
            }
            it { should contain_package('logstash-forwarder').with(:ensure => 'latest') }
          end

          context 'when setting package version and package_url' do
            let (:params) {
              default_params.merge({
                :version     => '0.90.10',
                :package_url => 'puppet:///path/to/some/logstash-forwarder-0.90.10.#{pkg_ext}'
              })
            }
            it { expect { should raise_error(Puppet::Error) } }
          end

        end

        context 'via package_url setting' do
          context 'using puppet:/// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "puppet:///path/to/package.#{pkg_ext}"
              })
            }

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl/').with(:purge => false, :force => false, :require => "Exec[create_package_dir_logstashforwarder]") }
            it { should contain_file("/opt/logstashforwarder/swdl/package.#{pkg_ext}").with(:source => "puppet:///path/to/package.#{pkg_ext}", :backup => false) }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end

          context 'using http:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "http://www.domain.com/path/to/package.#{pkg_ext}"
              })
            } 

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl/').with(:purge => false, :force => false, :require => "Exec[create_package_dir_logstashforwarder]") }
            it { should contain_exec('download_package_logstashforwarder').with(:command => "wget -O /opt/logstashforwarder/swdl/package.#{pkg_ext} http://www.domain.com/path/to/package.#{pkg_ext} 2> /dev/null", :require => 'File[/opt/logstashforwarder/swdl]') }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end

          context 'using https:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "https://www.domain.com/path/to/package.#{pkg_ext}"
              })
            }

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl').with(:purge => false, :force => false, :require => 'Exec[create_package_dir_logstashforwarder]') }
            it { should contain_exec('download_package_logstashforwarder').with(:command => "wget -O /opt/logstashforwarder/swdl/package.#{pkg_ext} https://www.domain.com/path/to/package.#{pkg_ext} 2> /dev/null", :require => 'File[/opt/logstashforwarder/swdl]') }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end

          context 'using ftp:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "ftp://www.domain.com/path/to/package.#{pkg_ext}"
              })
            }

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl').with(:purge => false, :force => false, :require => 'Exec[create_package_dir_logstashforwarder]') }
            it { should contain_exec('download_package_logstashforwarder').with(:command => "wget -O /opt/logstashforwarder/swdl/package.#{pkg_ext} ftp://www.domain.com/path/to/package.#{pkg_ext} 2> /dev/null", :require => 'File[/opt/logstashforwarder/swdl]') }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end

          context 'using file:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "file:/path/to/package.#{pkg_ext}"
              })
            }

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl').with(:purge => false, :force => false, :require => 'Exec[create_package_dir_logstashforwarder]') }
            it { should contain_file("/opt/logstashforwarder/swdl/package.#{pkg_ext}").with(:source => "/path/to/package.#{pkg_ext}", :backup => false) }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end
        end
      end # package

    end
  end
end
