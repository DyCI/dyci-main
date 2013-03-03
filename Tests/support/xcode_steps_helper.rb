class XcodeTestsHelper

  attr_accessor :output_dir,
                :configuration,
                :sdk_version,
                :test_project_root,
                :test_project_sources_root,
                :fixtures_project_dir,
                :project_name,
                :workspace_name,
                :scheme_name

  def initialize
    @output_dir = "/tmp/output"
    @configuration = "Debug"
    @sdk_version = "6.1"
    @test_project_root = nil
    @test_project_sources_root = nil
    @project_name = nil
    @fixtures_project_dir = nil
    @scheme_name = nil
    @workspace_name = nil
  end

  def xcode_developer_dir
    `xcode-select -print-path`.strip
  end

  def sdk_dir
    "#{xcode_developer_dir}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{@sdk_version}.sdk"
  end

  def build_dir(eff_platform_name)
    File.join(@output_dir, @configuration + eff_platform_name)
  end

end
