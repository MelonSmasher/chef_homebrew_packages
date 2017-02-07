name 'homebrew_packages'
maintainer 'Alex Markessinis'
maintainer_email 'markea125@gmail.com'
license 'MIT'
description 'Install and updates homebrew packages defined in attributes.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.3'
supports 'mac_os_x'
issues_url 'https://github.com/MelonSmasher/chef_homebrew_packages/issues' if respond_to?(:issues_url)
source_url 'https://github.com/MelonSmasher/chef_homebrew_packagess' if respond_to?(:source_url)
chef_version "~> 12"
depends 'homebrew'