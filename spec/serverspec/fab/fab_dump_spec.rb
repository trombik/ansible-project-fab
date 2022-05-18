# frozen_string_literal: true

require_relative "../spec_helper"

dump_dir = "/usr/local/fab/backup"
dump_script = "/usr/local/bin/fab_dump"

describe file dump_dir do
  it { should exist }
  it { should be_directory }
  it { should be_mode 770 }
  it { should be_owned_by "fab" }
  it { should be_grouped_into "wheel" }
end

describe file dump_script do
  it { should exist }
  it { should be_file }
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
end
