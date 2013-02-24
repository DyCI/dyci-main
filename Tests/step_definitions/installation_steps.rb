require 'aruba-doubles/cucumber'
require 'aruba/cucumber'
require 'fileutils'

Given /^User hasn't installed dyci yet$/ do
  include Aruba::Api
  current_dir.should_not be_nil
  create_dir("dyci_installation_dir")
end

When /^User installs dyci$/ do
  check_directory_presence "dyci_installation_dir", true
end

When /^I r?e?install dyci$/ do
  run "../../../Install/install.sh -v"

  #Waiting until it ends
  stdout_from "../../../Install/install.sh -v"
  stderr_from "../../../Install/install.sh -v"

end

Given /^I append the current working dir to my path$/ do
  include Aruba::Api
  ENV['PATH'] = [".", ENV['PATH'] ].join(File::PATH_SEPARATOR)
end

Given /^I double `([^`]*)` to local implementation$/ do |script|
  include Aruba::Api
  check_file_presence script, true
  run "./" + script
  script_stdout = stdout_from "./" + script
  double_cmd(script, :puts=>script_stdout)
  double_cmd(script + " -find clang", :puts=>script_stdout)
end
