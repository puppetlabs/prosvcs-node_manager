Puppet::Parser::Functions.newfunction(:environment_classes, :arity => -1, :type => :rvalue) do |values|
  env_name = values[0]

  if env_name
    env = Puppet.lookup(:environments).get!(env_name)
  else
    # If no environment was provided, use this node's
    env = environment
  end

  # Make sure we've parsed and evaluated every class
  # available in the environment.
  env.check_for_reparse
  env.known_resource_types.loader.import_all

  classes = env.known_resource_types.hostclasses.map {|name, hostclass| hostclass.name }
  classes.delete("")

  return classes
end
