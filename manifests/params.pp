class node_manager::params {
  $version = '0.1.5' #puppetclassify gem version

  if "$::puppetversion" =~ /3.8/ {
    $gemprovider='pe_gem'
  }
  elsif "$::pe_server_version" =~ /2015/ or "$::pe_server_version" =~ /2016/ {
    $gemprovider = 'puppet_gem'
  }
  else {
    $gemprovider = 'gem'
  }

}

