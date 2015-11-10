Puppet::Type.newtype(:puppet_environment) do
  desc 'The puppet_environment type creates and manages environments for the PE Node Manager'
  ensurable
  newparam(:name, :namevar => true) do
    desc 'This is the name of the environment'
    validate do |value|
      fail("#{value} is not a valid group name") unless value =~ /\A[a-z0-9_-]+\Z/
    end
  end
end
