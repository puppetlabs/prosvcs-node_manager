Puppet::Type.newtype(:node_group) do
  id_format = /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
  desc 'The node_group type creates and manages node groups for the PE Node Manager'
  ensurable
  newparam(:name, :namevar => true) do
    desc 'This is the common name for the node group'
    validate do |value|
      fail("#{name} is not a valid group name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
  end
  newproperty(:id) do
    desc 'The ID of the group'
    validate do |value|
      fail("ID is read-only")
    end
  end
  newproperty(:override_environment) do
    desc 'Override parent environments'
    newvalues(:false, :true)
  end
  newproperty(:parent) do
    desc 'The ID of the parent group'
    defaultto :default
  end
  newproperty(:variables) do
    desc 'Variables set this group\'s scope'
    validate do |value|
      fail("Variables must be supplied as a hash") unless value.is_a?(Hash)
    end
  end
  newproperty(:rule, :array_matching => :all) do
    desc 'Match conditions for this group'
  end
  newproperty(:environment) do
    desc 'Environment for this group'
    defaultto :production
    validate do |value|
      fail("Invalid environment name") unless value =~ /^[a-z][a-z0-9]+$/
    end
  end
  newproperty(:classes) do
    desc 'Classes applied to this group'
    defaultto {}
    validate do |value|
      fail("Classes must be supplied as a hash") unless value.is_a?(Hash)
    end
  end

  autorequire(:node_group) do
    self[:parent] if @parameters.include? :parent
  end

end
