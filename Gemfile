# frozen_string_literal: true

source "https://rubygems.org"

gem "ansibleinventory", git: "https://github.com/trombik/ansibleinventory.git", branch: "master"
gem "ansible-vault", git: "https://github.com/trombik/ansible-vault", branch: "master"
gem "highline"
gem "rake"
gem "vagrant-serverspec", git: "https://github.com/trombik/vagrant-serverspec.git", branch: "master"
gem "vagrant-ssh-config", git: "https://github.com/trombik/vagrant-ssh-config.git", branch: "master"

group :development, :test do
  # gem "capybara"
  gem "retries", "~> 0.0.5"
  gem "rspec", "~> 3.4.0"
  gem "rspec-retry", "~> 0.5.5"
  gem "rubocop"
  # gem "selenium-webdriver"
  gem "dnsruby"
  gem "irb"
  gem "serverspec"
end
