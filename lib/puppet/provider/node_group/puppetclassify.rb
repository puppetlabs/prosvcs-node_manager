require 'puppetclassify'
require 'yaml'

Puppet::Type.type(:node_group).provide(:puppetclassify) do

  auth_info = {
    "ca_certificate_path" => Puppet.settings['localcacert'],
    "certificate_path"    => Puppet.settings['hostcert'],
    "private_key_path"    => Puppet.settings['hostprivkey'],
  }

  begin
    nc_settings = YAML.load_file("#{Puppet.settings['confdir']}/classifier.yaml")
  rescue
    fail "Could not find file #{Puppet.settings['confdir']}/classifier.yaml"
  else
    classifier_url = "https://#{nc_settings['server']}:#{nc_settings['port']}/classifier-api"
  end
  $puppetclassify = PuppetClassify.new(classifier_url, auth_info)

  def initialize(value={})
    super(value)
    @property_flush = {
      'state' => {},
      'attrs' => {},
    }
  end

  # API will fail if disallowed-keys are passed
  # Decided to use override_environment instead
  def self.friendly_name
    {
      :classes            => 'classes',
      :environment        => 'environment',
      :environment_trumps => 'override_environment',
      :id                 => 'id',
      :name               => 'name',
      :parent             => 'parent',
      :rule               => 'rule',
      :variables          => 'variables'
    }
  end

  def self.instances
    $ngs = $puppetclassify.groups.get_groups
    $ngs.collect do |group|
      ngs_hash = {}
      friendly_name.each do |property,friendly|
        # Replace parent ID with string name
        if friendly == 'parent'
          gindex = $ngs.index { |i| i['id'] == group[property.to_s] }
          ngs_hash[friendly.to_sym] = $ngs[gindex]['name']
        else
          ngs_hash[friendly.to_sym] = group[property.to_s]
        end
      end
      # Boolean strings converted to syms
      ngs_hash[:override_environment] = :"#{ngs_hash[:override_environment]}"
      ngs_hash[:ensure] = :present
      new(ngs_hash)
    end
  end

  def self.prefetch(resources)
    ngs = instances
    resources.keys.each do |group|
      if provider = ngs.find{ |g| g.name == group }
        resources[group].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  mk_resource_methods

  def create
    # Only passing parameters that are given
    send_data = Hash.new
    @resource.original_parameters.each do |k,v|
      send_data[k.to_s] = v unless k == :ensure
    end
    # namevar may not be in this hash 
    send_data['name'] = @resource[:name] unless send_data['name']
    
    # Passing an empty hash in the type results in undef
    send_data['classes'] = {} unless send_data['classes']

    send_data['parent'] = 'default' if !send_data['parent']
    unless send_data['parent'] =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
      gindex = $ngs.index { |i| i['name'] == send_data['parent'] }
      if gindex
        send_data['parent'] = $ngs[gindex]['id']
      end
    end

    #renamed key for v1.0 API... 
    send_data['environment_trumps'] = send_data.delete('override_environment')
    send_data['environment_trumps'] = false if !send_data['environment_trumps']

    resp = $puppetclassify.groups.create_group(send_data)
    if resp
      send_data.each_key do |k|
        #renamed key for v1.0 API...
        k = 'override_environment' if k == 'environment_trumps'
        @property_hash[k]       = @resource[k]
        @property_hash[:ensure] = :present
      end
      # Add placeholder for $ngs lookups
      $ngs << { "name" => send_data[:name], "id" => resp }
    else
      fail("puppetclassify was not able to create group")
    end

    exists? ? (return true) : (return false)

  end

  def destroy
    begin
      $puppetclassify.groups.delete_group(@property_hash[:id])
    rescue Exception => e
      fail(e.message)
      debug(e.backtrace.inspect)
    else
      @property_hash.clear
    end
    exists? ? (return false) : (return true)
  end

  # If ID is given, translate to string name
  def parent
    if @resource[:parent] =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
      gindex = $ngs.index { |i| i['id'] == @resource[:parent] }
      $ngs[gindex]['id']
    else
      @property_hash[:parent]
    end
  end

  friendly_name.each do |property,friendly|
    define_method "#{friendly}=" do |value|
      if property == :parent
        if value =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
          @property_flush['attrs'][property.to_s] = value
        else
          gindex = $ngs.index { |i| i['name'] == value }
          @property_flush['attrs'][property.to_s] = $ngs[gindex]['id']
        end
      else
        # The to_json function needs to recognize
        # booleans true/false, not symbols :true/false
        case value
        when :true
          @property_flush['attrs'][property.to_s] = true
        when :false
          @property_flush['attrs'][property.to_s] = false
        else
          @property_flush['attrs'][property.to_s] = value
        end
      end
      @property_hash[friendly.to_sym] = value
    end
  end

  def flush
    debug @property_flush['attrs']
    if @property_flush['attrs']
      @property_flush['attrs']['id'] = @property_hash[:id] unless @property_flush['attrs']['id']
      begin
        $puppetclassify.groups.update_group(@property_flush['attrs'])
      rescue Exception => e
        fail(e.message)
        debug(e.backtrace.inspect)
      else
      end
    end
  end

end
