require 'spec_helper'

describe 'nexus::package', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) {
        {
          'deploy_pro'                    => false,
          'download_site'                 => 'http://download.sonatype.com/nexus/oss',
          'nexus_root'                    => '/srv',
          'nexus_home_dir'                => 'nexus',
          'nexus_user'                    => 'nexus',
          'nexus_group'                   => 'nexus',
          'nexus_work_dir'                => '/srv/sonatype-work/nexus',
          'nexus_work_dir_manage'         => true,
          'nexus_work_recurse'            => true,
          'nexus_type'                    => 'bundle',
          'nexus_selinux_ignore_defaults' => true,
          # Assume a good revision as init.pp screens for us
          'revision'                      => '01',
          'version'                       => '2.11.2',
          'download_folder'               => '/srv',
          'md5sum'                        => '',
        }
      }

      context 'with default values' do
        it { should contain_class('nexus::package') }

        it { should contain_archive('nexus-2.11.2-01-bundle.tar.gz').with(
          'source'          => 'http://download.sonatype.com/nexus/oss/nexus-2.11.2-01-bundle.tar.gz',
          'path'            => '/srv/nexus-2.11.2-01-bundle.tar.gz',
          'checksum'        => '',
          'checksum_verify' => false,
          'extract_path'    => '/srv',
          'creates'         => '/srv/nexus-2.11.2-01',
        ) }

        it { should contain_file('/srv/nexus-2.11.2-01').with(
          'ensure'  => 'directory',
          'owner'   => 'nexus',
          'group'   => 'nexus',
          'recurse' => true,
          'require' => 'Archive[nexus-2.11.2-01-bundle.tar.gz]',
        ) }

        it { should contain_file('/srv/sonatype-work/nexus').with(
          'ensure'  => 'directory',
          'owner'   => 'nexus',
          'group'   => 'nexus',
          'recurse' => true,
          'require' => 'Archive[nexus-2.11.2-01-bundle.tar.gz]',
        ) }

        it { should contain_file('/srv/nexus').with(
          'ensure'  => 'link',
          'target'  => '/srv/nexus-2.11.2-01',
          'require' => 'Archive[nexus-2.11.2-01-bundle.tar.gz]',
        ) }

        it 'should handle deploy_pro' do
          params.merge!(
            {
              'deploy_pro'    => true,
              'download_site' => 'http://download.sonatype.com/nexus/professional-bundle'
            }
          )

          should contain_archive('nexus-professional-2.11.2-01-bundle.tar.gz').with(
            'source' => 'http://download.sonatype.com/nexus/professional-bundle/nexus-professional-2.11.2-01-bundle.tar.gz',
            'path'   => '/srv/nexus-professional-2.11.2-01-bundle.tar.gz',
          )

          should contain_file('/srv/nexus-professional-2.11.2-01')

          should contain_file('/srv/nexus').with(
            'target' => '/srv/nexus-professional-2.11.2-01',
          )
        end

        it 'should working with md5sum' do
          params.merge!({'md5sum'=> '1234567890'})

          should contain_archive('nexus-2.11.2-01-bundle.tar.gz').with(
            'source'          => 'http://download.sonatype.com/nexus/oss/nexus-2.11.2-01-bundle.tar.gz',
            'path'            => '/srv/nexus-2.11.2-01-bundle.tar.gz',
            'checksum'        => '1234567890',
            'checksum_verify' => true,
          )
        end

        it 'should work with a https|http|ftp proxy server' do
          params.merge!({'proxy_server' => 'https://example.com:8080'})

          should contain_archive('nexus-2.11.2-01-bundle.tar.gz').with(
            'source'          => 'http://download.sonatype.com/nexus/oss/nexus-2.11.2-01-bundle.tar.gz',
            'path'            => '/srv/nexus-2.11.2-01-bundle.tar.gz',
            'proxy_server'    => 'https://example.com:8080',
          )
        end

      end

    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
