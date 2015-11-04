require 'puppetlabs_spec_helper/module_spec_helper'

describe "the environment_classes function" do
  let(:the_node)     { Puppet::Node.new('stub_node') }
  let(:the_compiler) { Puppet::Parser::Compiler.new(the_node) }
  let(:the_scope)    { Puppet::Parser::Scope.new(the_compiler) }
  let(:the_typecollection) { Puppet::Resource::TypeCollection.new(the_scope.environment) }

  it "should return all available class names without any empty strings" do
    the_typecollection << Puppet::Resource::Type.new(:hostclass, :stub_class_1)
    the_typecollection << Puppet::Resource::Type.new(:hostclass, :stub_class_2)
    the_typecollection << Puppet::Resource::Type.new(:hostclass, '')

    col = the_scope.environment.stubs(:known_resource_types).returns(the_typecollection)
    expect(the_scope.function_environment_classes([])).to eq(["stub_class_1", "stub_class_2"])
  end
end
