#!/usr/bin/env ruby

require 'xcoder'

def log(args = nil)
  puts args if args
end

project = Xcode.find_projects.first
if project.nil?
  log("Project not found")
  exit 1
end

log("Project '#{project.name}' founded")

target = project.targets.first

log("Inject into '#{target.name}' target")

config = target.config "Debug"

log("Inject into '#{config.name}' config")

config.gcc_version = "/usr/bin/ololo"

project.save!

