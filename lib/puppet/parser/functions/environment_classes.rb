Puppet::Parser::Functions.newfunction(:environment_classes, :arity => 0, :type => :rvalue) do |values|
  # Make sure we've parsed and evaluated every class
  # available in the environment.
  environment.check_for_reparse
  environment.known_resource_types.loader.import_all

  classes = environment.known_resource_types.hostclasses.map {|name, hostclass| hostclass.name }
  classes.delete("")

  return classes
end
