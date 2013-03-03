require "xcode_build"
require "bundler"
require 'timeout'
require 'pty'
require 'open3'

require File.expand_path('../../support/xcode_steps_helper', __FILE__)
require File.expand_path('../../support/helpers', __FILE__)

def d_puts(s)
  puts s if @debug_mode == true
end


Before do |scenario|
  @debug_mode = false
  @config = XcodeTestsHelper.new if @config == nil
  d_puts "Before scenario: #{scenario.title}"

end


When /^project was successfully built$/ do

  fail "Cannot start without project name" if @config.project_name == nil

  # Do something before each scenario.
  source_project_path = "fixtures/#{@config.fixtures_project_dir}"
  test_project_path = "tmp/project-dir"

  d_puts "Copying #{source_project_path} to #{test_project_path}"
  FileUtils.rm_r(test_project_path) if File.exist? test_project_path
  FileUtils.mkdir(test_project_path)
  FileUtils.cp_r(source_project_path, test_project_path, :remove_destination => true)
  @config.test_project_root = test_project_path
  @config.test_project_sources_root = File.join(test_project_path, File.basename(source_project_path)).to_s


  # Setting up build dir
  project_output_path = @config.output_dir
  d_puts "Setting up output directory to #{project_output_path}"
  FileUtils.rm_r(project_output_path) if File.exists? project_output_path
  @config.output_dir = project_output_path


  # Building project
  d_puts "output dir is #{@config.output_dir} and test project root is #{@config.test_project_root} and pr path is #{@config.test_project_sources_root}"
  d_puts "Project name is #{@config.project_name}"


  # Xcconfig file for little more configuration
  xcconfig_location = "/tmp/config.xcconfig"
  write_file(xcconfig_location,
             "" "
    OBJROOT=#{@config.output_dir}
    SYMROOT=#{@config.output_dir}
    OTHER_CFLAGS= -DCEDAR_KNOWS_SOMETHING_ABOUT_FAILING_ON_IOS6_SIMULATOR=1
    " ""
  )

  # Running this on via fork, because...
  # Because sometimes..
  @build_project_process = fork do

    File.open('/tmp/ruby-output2', 'w') { |f| f.puts "output dir is #{@config.output_dir} and test project root is #{@config.test_project_root} and pr path is #{@config.test_project_sources_root}" }

    task_working_dir = File.join(@config.test_project_root, @config.fixtures_project_dir)
    d_puts "Running at '#{task_working_dir}"
    File.open('/tmp/ruby-output2', 'a') { |f| f.puts "Running at '#{task_working_dir}" }


    task = XcodeBuild::Tasks::BuildTask.new do |t|
      t.scheme = @config.scheme_name
      t.workspace = @config.workspace_name
      t.invoke_from_within = task_working_dir
      t.sdk = "iphonesimulator#{@config.sdk_version}"
      t.configuration = @config.configuration
      t.output_to = "/tmp/build.output" unless @debug_mode
      t.xcconfig = xcconfig_location
    end

    d_puts "Build opts #{task.build_opts}"
    File.open('/tmp/ruby-output2', 'a') { |f| f.puts "Build opts #{task.build_opts}" }

    task.run("clean")
    task.run("build")
  end

  d_puts "Waiting for project build"
  Process.wait(@build_project_process)
end


#Config setup
Given /^output directory setup to `([^`]*)`$/ do |output_dir|
  @config.output_dir = output_dir
end

When /^project from `([^`]*)` with  name `([^`]*)` is used$/ do |fixtures_project_dir, project_name|
  @config.fixtures_project_dir = fixtures_project_dir
  @config.project_name = project_name

  d_puts "Setting up @config.fixtures_project_dir = #{@config.fixtures_project_dir}"
  d_puts "Setting up @config.project_name = #{@config.project_name}"
end

When /^project build is configured to `([^`]*)` workspace and `([^`]*)` scheme$/ do |workspace_name, scheme_name|
  @config.workspace_name = workspace_name
  @config.scheme_name = scheme_name
end


def run_project(app_name)
  #puts "Project started to run"
  d_puts "Killing previous running instance"
  %x[kill -9 #{app_name} > /dev/null 2>&1]
  sleep(0.5)
  env_vars = {
      "DYLD_ROOT_PATH" => @config.sdk_dir,
      "IPHONE_SIMULATOR_ROOT" => @config.sdk_dir,
      "CFFIXED_USER_HOME" => Dir.tmpdir,
      "DYLD_FALLBACK_LIBRARY_PATH" => @config.sdk_dir,
  }

  project_file = File.join(@config.build_dir("-iphonesimulator"), "#{app_name}.app", app_name)
  unless File.exist? project_file
    fail "No file to run #{project_file}. It seems that build was failed"
  end

  run_project_command = "#{project_file} -RegisterForSystemEvents"

  @project_pid = fork do
    with_env_vars(env_vars) do

      stdin, stdout, stderr = Open3.popen3("#{run_project_command}")

      File.open('/tmp/ruby-output', 'w') { |f| f.puts "#{Time.now} : Injection started" }

      while (line = stderr.gets)
        File.open('/tmp/ruby-output', 'a') { |f1| f1.puts(line) }
      end

    end

  end

  d_puts "Forked project to run"

end

#=========================================================


# Steps

Given /^I start project$/ do
  d_puts "Starting project #{@config.project_name}"
  run_project(@config.project_name)
end


When /^I end project process$/ do
  begin
    #puts "Ending process"
    Timeout.timeout(1) do
      Process.wait @project_pid
    end
  rescue Timeout::Error
    d_puts "Children of current process are #{Process.descendant_processes}"
    Process.descendant_processes.each do |pid|
      begin
        Process.getpgid(pid)
        d_puts "Killing process with #{pid}"
        Process.kill("KILL", pid) if Process.getpgid(pid)
      rescue Errno::ESRCH
        d_puts "Process #{pid} was already ended"
      end
    end
  end
end


When /^Change its source file "([^"]*)" with contents of file "([^"]*)"$/ do |des_file, source_file|
  FileUtils.cp(File.join(@config.test_project_sources_root, source_file), File.join(@config.test_project_sources_root, des_file))
end


When /^Inject inject new version of "([^"]*)" with "([^"]*)" as test string$/ do |file_path, value|
  d_puts "#{Time.now} : Waiting 1 sec to project started"
  sleep(1)

  #Replacing file
  file = File.expand_path(File.join(@config.test_project_sources_root, file_path).to_s)
  text = File.read(file.to_s)
  replace = text.gsub(/######/, value)
  File.open(file.to_s, "w") { |f| f.puts replace }

  d_puts "#{Time.now} : Starting injection"

  verbose_recompile = ""
  verbose_recompile = "> /dev/null 2>&1" if @debug_mode == false
  system("~/.dyci/scripts/dyci-recompile.py #{file} #{verbose_recompile}")
  result_code = $?.exitstatus
  unless result_code == 0
    fail("Unable to inject source python file failed")
  end

  d_puts "Injection result code is #{result_code}"
end


Then /^I should see "([^"]*)" in running project output$/ do |arg|
  d_puts "Checking project output"
  begin
    Timeout.timeout(3) do
      expect_string_found = false
      until expect_string_found do
        sleep 0.5
        File.open('/tmp/ruby-output', 'r') do |f1|
          f1.readlines.each { |line|
            if line.include? arg
              expect_string_found = true
              break
            end
          }
        end
      end
    end
  rescue Timeout::Error
    fail("There is no #{arg} in project output :(")
  end
end


