require "xcode_build"

OUTPUT_DIR = "/tmp/output"


Given /^I have prepared xcode-project for injection at "([^"]*)"$/ do |project_path|

end

When /^project at "([^"]*)" with workspace "([^"]*)" was successfully build with "([^"]*)" scheme$/ do |project_path, workspace_name, scheme_name|

  write_file("/tmp/config.xcconfig",
    """
    OBJROOT=#{OUTPUT_DIR}
    SYMROOT=#{OUTPUT_DIR}
    """
  )

  task = XcodeBuild::Tasks::BuildTask.new do |t|
    t.scheme = scheme_name
    t.workspace = workspace_name
    t.invoke_from_within = project_path
    t.sdk = 'iphonesimulator6.0'
    t.output_to = nil
    t.xcconfig = "/tmp/config.xcconfig"
#    t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
  end

  task.run("build")

end
