require 'yaml' 

module Kofi

  class << self

    attr_reader :trail

  def run(opts, args)
    @locale_path = opts[:locale_path]
    @trail       = args.shift.split('.')
    @locale      = trail.first
    @value       = args.shift

    if @value
      data = set YAML::load_file(filename), trail, @value
      File.open(filename, 'w') do |file|
        YAML::dump(data, file)
      end
    end

    puts "#{trail.join('.')} => #{get(trail).inspect}"
  end

  def filename
    File.join(@locale_path, "#{@locale}.yml")
  end

  def get(key)
    current = YAML::load_file(filename)
    key.each do |part|
      current = current[part]
    end

    return current
  end

  def set(data, key, value)
    deep_merge(data, hash_to_be_merged(key, value))
  end

  def hash_to_be_merged(trail, value)
    trail = trail.dup
    if trail.size > 0
      key = trail.shift
      { key => hash_to_be_merged(trail, value) }
    else
      value
    end
  end

  def deep_merge(lhs, rhs)
    target = lhs.dup

    rhs.keys.each do |key|
      if rhs[key].is_a? Hash and lhs[key].is_a? Hash
        target[key] = deep_merge(target[key], rhs[key])
        next
      end

      target[key] = rhs[key]
    end

    target
  end
  end

end
