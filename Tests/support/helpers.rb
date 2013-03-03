
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


def Process.descendant_processes(base=Process.pid)
  descendants = Hash.new { |ht, k| ht[k]=[k] }
  Hash[*`ps -eo pid,ppid`.scan(/\d+/).map { |x| x.to_i }].each { |pid, ppid|
    descendants[ppid] << descendants[pid]
  }
  descendants[base].flatten - [base]
end

