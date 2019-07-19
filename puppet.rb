# depends on ruby being installed in /opt/puppet-omnibus/embedded by ruby-build
class PuppetGem < FPM::Cookery::Recipe
  description 'Puppet gem stack'

  # If you want to bump puppet version you have to do it in Gemfile as well
  name 'puppet'
  version ENV['PUPPET_VERSION']

  source "nothing", :with => :noop

  build_depends 'pkg-config', 'libxml2-dev', 'libxslt1-dev'
  depends 'libxml2', 'libxslt1.1', 'virt-what'

  def build
    ENV['PKG_CONFIG_PATH'] = "#{destdir}/lib/pkgconfig"
    cleanenv_safesystem "#{destdir}/bin/bundle config build.ruby-augeas \
                           --with-opt-dir=#{destdir}"
    cleanenv_safesystem "#{destdir}/bin/bundle config --delete path"
    cleanenv_safesystem "#{destdir}/bin/bundle install --local \
                           --gemfile #{workdir}/puppet/Gemfile \
                           --system"
    cleanenv_safesystem "#{destdir}/bin/gem install #{workdir}/vendor/puppet-#{ENV['PUPPET_VERSION']}.gem"

    # bundle is shit
    cleanenv_safesystem <<-SHELL
      for file in #{destdir}/bin/*; do
        if head -n1 $file | grep '^#!/usr/bin/env ruby'; then
          echo "Fixing shebang in $file"
          sed -i '1s/.*/#!#{destdir.to_s.gsub('/', "\\/")}\\/bin\\/ruby/' $file
        fi
      done

      for gemdir in `gem env GEM_HOME`/gems/*; do
        [ -d $gemdir ] && rm -rf $gemdir/spec
      done
    SHELL
  end

  def install
    # Provide 'safe' binaries in /opt/<package>/bin like Vagrant does
    rm_rf "#{destdir}/../bin"
    destdir('../bin').mkdir
    destdir('../bin').install workdir('puppet/puppet'), 'puppet'
    destdir('../bin').install workdir('shared/omnibus.bin'), 'facter'
    destdir('../bin').install workdir('shared/omnibus.bin'), 'hiera'
    destdir('../bin').install workdir('puppet/unicorn'), 'unicorn'

    destdir('../var').mkdir
    destdir('../var/lib').mkdir

    destdir('../var/lib/ruby').mkdir
    destdir('../var/lib/ruby').install workdir('puppet/gemspec_patch.rb')
    destdir('../var/lib/ruby').install workdir('puppet/seppuku_patch.rb')

    destdir('../var/lib/puppetmaster').mkdir
    destdir('../var/lib/puppetmaster/rack').mkdir
    destdir('../var/lib/puppetmaster/rack').install workdir('puppet/config.ru')

    destdir('../etc').mkdir
    destdir('../etc').install workdir('puppet/unicorn.conf')
  end
end
