require 'spec_helper'

describe 'jmeter' do

  before(:all) do
    @jmeter_version = '2.13'
  end

  context "On an Ubuntu OS with no additional params specified" do
    let :facts do
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '16.04'
      }
    end

    let :params do
      {
        :jpgc_plugins_set  => ['casutg-2.1'],
        :user_property_config => ['set jmeter.save.saveservice.data_type false']
      }
    end

    it {
      should contain_exec('download-jmeter').with(
          { 'creates' => "/root/apache-jmeter-#{@jmeter_version}.tgz"}
        )
    }

    it {
      should contain_exec('install-jmeter').with(
          { 'command' => "tar xzf /root/apache-jmeter-#{@jmeter_version}.tgz && mv apache-jmeter-#{@jmeter_version} jmeter"}
        )
    }

    it {
      should contain_jmeter__jdbc_plugins_install('casutg-2.1').with(
          { 'base_download_url' => 'http://jmeter-plugins.org/files/packages/'}
        )
    }

    it {
      should contain_jmeter__config_property_file('user.properties').with(
          { 'change_set' => ['set jmeter.save.saveservice.data_type false']}
        )
    }

    it {
      should contain_package('openjdk-8-jre-headless')
    }
  end
end
