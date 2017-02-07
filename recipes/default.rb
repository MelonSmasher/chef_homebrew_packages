#
# Cookbook:: homebrew_packages
# Recipe:: default
#

# This function calls the upstream chocolatey resource built into chefs
def run_upstream(package, action, options, ignore_failure)
  homebrew_package package do
    options options
    ignore_failure ignore_failure
    action action
  end
end

def cask_installed?(name)
  shell_out('/usr/local/bin/brew cask list 2>/dev/null').stdout.split.include?(name)
end

def install_cask(name, ignore_failure, options)
  execute 'cask_install' do
    ignore_failure ignore_failure
    command "brew cask install #{name} #{options}"
  end
end

def uninstall_cask(name, ignore_failure, options)
  execute 'cask_uninstall' do
    ignore_failure ignore_failure
    command "brew cask uninstall #{name} #{options}"
  end
end

def upgrade_cask(name, ignore_failure, options)
  execute 'cask_upgrade' do
    ignore_failure ignore_failure
    command "brew cu --cask #{name} #{options}"
  end
end

def run_cask(package, action, options, ignore_failure)
  case action
    when :install
      if cask_installed? package
        log 'Cask' do
          message "Package #{package} installed."
          level :info
        end
      else
        install_cask(package, ignore_failure, options)
      end
    when :upgrade
      if cask_installed? package
        upgrade_cask(package, ignore_failure, options)
      else
        install_cask(package, ignore_failure, options)
      end
    when :remove, :purge
      if cask_installed? package
        uninstall_cask(package, ignore_failure, options)
      end
    else
      log 'Cask' do
        message "Package #{package} supplied with invalid option."
        level :warn
      end
  end
end

include_recipe 'homebrew'

homebrew_tap 'caskroom/cask'
homebrew_tap 'caskroom/versions'
homebrew_tap 'buo/cask-upgrade'

# Global value for ignoring failures
ignore_failure = node['homebrew_packages']['ignore_failure']
# Grab install options that will be applied to each package
install_options = []
unless node['homebrew_packages']['install_options'].nil?
  unless node['homebrew_packages']['install_options'].empty?
    # Are the install options an array?
    if node['homebrew_packages']['install_options'].is_a? Array
      # Join into a single array
      (install_options << node['homebrew_packages']['install_options']).flatten!
    else
      log 'Homebrew Packages Global' do
        message "Global install options are malformed ignoring..."
        level :warn
      end
    end
  end
end

# Loop over packages
node['homebrew_packages']['packages'].each do |package, package_options|
  # Grab the desired action/version
  action_option = package_options['action']
  # If there are any package specific install options append them to the global install options
  if package_options.key?('install_options')
    unless package_options['install_options'].nil?
      unless package_options['install_options'].empty?
        # Check to see if it's an array or string
        if package_options['install_options'].is_a? Array
          # Join the arrays into a single array
          (install_options << package_options['install_options']).flatten!
        else
          log 'Homebrew Package' do
            message "The package: '#{package}' contains a malformed install option, ignoring..."
            level :warn
          end
        end
      end
    end
  end

  if install_options.is_a? Array
    # If the install options are empty make into a blank string otherwise strip each element of the array and join into a string separated by spaces
    final_install_options = install_options.to_a.empty? ? '' : install_options.to_a.each { |a| a.strip! if a.respond_to? :strip! }.join(' ')
  else
    final_install_options = ''
  end

  # Switch over the various actions and pass in the correct action symbol
  case action_option
    when 'install'
      if package_options['cask']
        run_cask(package, :install, final_install_options, ignore_failure)
      else
        run_upstream(package, :install, final_install_options, ignore_failure)
      end
    when 'purge'
      if package_options['cask']
        run_cask(package, :purge, final_install_options, ignore_failure)
      else
        run_upstream(package, :purge, final_install_options, ignore_failure)
      end
    when 'remove'
      if package_options['cask']
        run_cask(package, :remove, final_install_options, ignore_failure)
      else
        run_upstream(package, :remove, final_install_options, ignore_failure)
      end
    when 'upgrade'
      if package_options['cask']
        run_cask(package, :upgrade, final_install_options, ignore_failure)
      else
        run_upstream(package, :upgrade, final_install_options, ignore_failure)
      end
    else # If we make it here, try the action as a version number.
      homebrew_package package do
        version action_option
        options final_install_options
        ignore_failure ignore_failure
        action :install
      end
  end
end
