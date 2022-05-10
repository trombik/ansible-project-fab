# frozen_string_literal: true

require "rake"
require "pathname"

def ansible_environment
  ENV["PROJECT_ENVIRONMENT"] || "virtualbox"
end

desc "up"
task "up" do
  case ansible_environment
  when "virtualbox"
    Bundler.with_original_env do
      sh "vagrant up --no-provision"
    end
  when "staging"
    Dir.chdir "terraform/plans/staging" do
      sh "terraform apply"
    end
  end
end

desc "provision"
task "provision" do
  case ansible_environment
  when "virtualbox"
    Bundler.with_original_env do
      sh "vagrant provision"
    end
  end
end

desc "destroy"
task "destroy" do
  case ansible_environment
  when "virtualbox"
    Bundler.with_original_env do
      sh "vagrant destroy -f"
    end
  when "staging"
    Dir.chdir "terraform/plans/staging" do
      sh "terraform apply --destroy"
    end
  end
end