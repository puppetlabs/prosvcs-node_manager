class node_manager::params {
  $version = '0.1.3' #puppetclassify gem version

  if "$::puppetversion" =~ /3.8/ {
    $gemprovider='pe_gem'
  }
  elsif "$::pe_server_version" =~ /201[56]/ {
    $gemprovider = 'puppet_gem'
  }
  else {
    $gemprovider = 'gem'
  }

}

