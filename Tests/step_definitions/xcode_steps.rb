require "xcode_build"
require "bundler"
require 'timeout'
require 'pty'


@output_dir = "/tmp/output"
CONFIGURATION = "Debug"
SDK_VERSION = "6.1"
$output_value = []

$pipe = nil

# Helpers
def sdk_dir
  "#{xcode_developer_dir}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{SDK_VERSION}.sdk"
end

def xcode_developer_dir
  `xcode-select -print-path`.strip
end

def build_dir(eff_platform_name)
  File.join(@output_dir, CONFIGURATION + eff_platform_name)
end

def with_env_vars(env_vars)
  old_values = {}
  env_vars.each do |key, new_value|
    old_values[key] = ENV[key]
    ENV[key] = new_value
  end

  yield

  env_vars.each_key do |key|
    ENV[key] = old_values[key]
  end
end


# =====================================================

def Process.descendant_processes(base=Process.pid)
  descendants = Hash.new { |ht, k| ht[k]=[k] }
  Hash[*`ps -eo pid,ppid`.scan(/\d+/).map { |x| x.to_i }].each { |pid, ppid|
    descendants[ppid] << descendants[pid]
  }
  descendants[base].flatten - [base]
end

# =====================================================


def run_project(app_name)
  #puts "Project started to run"
  env_vars = {
      "DYLD_ROOT_PATH" => sdk_dir,
      "IPHONE_SIMULATOR_ROOT" => sdk_dir,
      "CFFIXED_USER_HOME" => Dir.tmpdir,
      "DYLD_FALLBACK_LIBRARY_PATH" => sdk_dir,
  }

  cmd = "#{File.join(build_dir("-iphonesimulator"), "#{app_name}.app", app_name)} -RegisterForSystemEvents"

  @project_pid = fork do
    with_env_vars(env_vars) do
      require 'open3'
      stdin, stdout, stderr = Open3.popen3("#{cmd}")

      File.open('/tmp/ruby-output', 'w') do |f1|
        f1.puts "#{Time.now} : Injection started"
      end

      while (line = stderr.gets)
        File.open('/tmp/ruby-output', 'a') do |f1|
          $output_value << line
          f1.puts(line)
        end
      end

    end

  end

  #puts "Forked project to run"

end

#=========================================================

@test_project_root = nil
@test_project_sources_root = nil


# Steps

Given /^I have prepared xcode-project at "([^"]*)" for injection at "([^"]*)"$/ do |source_project_path, test_project_path|
  FileUtils.rm_r(test_project_path) if File.exist? test_project_path
  FileUtils.mkdir(test_project_path)
  FileUtils.cp_r(source_project_path, test_project_path, :remove_destination => true)
  @test_project_root = test_project_path
  @test_project_sources_root = File.join(test_project_path, File.basename(source_project_path)).to_s
end


When /^project at "([^"]*)" with workspace "([^"]*)" was successfully build with "([^"]*)" scheme$/ do |project_path, workspace_name, scheme_name|

  write_file("/tmp/config.xcconfig",
             "" "
    OBJROOT=#{@output_dir}
    SYMROOT=#{@output_dir}
    OTHER_CFLAGS= -DCEDAR_KNOWS_SOMETHING_ABOUT_FAILING_ON_IOS6_SIMULATOR=1
    " ""
  )

  #puts "Running at '#{File.join(@test_project_root, project_path)}'"
  task = XcodeBuild::Tasks::BuildTask.new do |t|
    t.scheme = scheme_name
    t.workspace = workspace_name
    t.invoke_from_within = File.join(@test_project_root, project_path)
    t.sdk = 'iphonesimulator6.1'
    t.configuration = CONFIGURATION
    t.output_to = "/tmp/build.output"
    t.xcconfig = "/tmp/config.xcconfig"
  end

  #puts "Build opts #{task.build_opts}"

  task.run("build")

end


When /^build directory is setup to "([^"]*)"$/ do |project_output_path|
  FileUtils.rm_r(project_output_path) if File.exists? project_output_path
  @output_dir = project_output_path
end

Given /^I start project at with name "([^"]*)"$/ do |app_name|
  run_project(app_name)
end


When /^I end project process$/ do
  begin
    #puts "Ending process"
    Timeout.timeout(1) do
      Process.wait @project_pid
    end
  rescue Timeout::Error
    #puts "Children of current process are #{Process.descendant_processes}"
    Process.descendant_processes.each do |pid|
      begin
        Process.getpgid(pid)
        #puts "Killing process with #{pid}"
        Process.kill("KILL", pid) if Process.getpgid(pid)
      rescue Errno::ESRCH
        #puts "Process #{pid} was already ended"
      end
    end
  end
end


When /^Change its source file "([^"]*)" with contents of file "([^"]*)"$/ do |des_file, source_file|
  FileUtils.cp(File.join(@test_project_sources_root, source_file), File.join(@test_project_sources_root, des_file))
end


When /^Inject inject new version of "([^"]*)" with "([^"]*)" as test string$/ do |file_path, value|
  file = File.expand_path(File.join(@test_project_sources_root, file_path).to_s)
  text = File.read(file.to_s)
  replace = text.gsub(/######/, value)
  File.open(file.to_s, "w") { |f| f.puts replace }
  #puts "#{Time.now} : Waiting 1 sec to project started"
  sleep(1)
  #puts "#{Time.now} : Starting injection"
  system("~/.dyci/scripts/dyci-recompile.py #{file} 2&1>/dev/null")
  #puts "Injection done"
end


Then /^I should see "([^"]*)" in running project output$/ do |arg|
  #puts "Checking project output"
  begin
    Timeout.timeout(10) do
      expect_string_found = false
      until expect_string_found do
        sleep 0.5
        File.open('/tmp/ruby-output', 'r') do |f1|
          f1.readlines.each { |line|
            if line.include? arg
              #puts "Found #{arg} in output"
              expect_string_found = true
              break
            end
          }
        end
      end
    end
  rescue Timeout::Error
    #puts "Expected output (#{arg}) wasn't found :("
  end
end