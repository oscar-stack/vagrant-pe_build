if [ -f /opt/puppet/bin/puppet ]; then
  echo "Puppet Enterprise already present, version $(/opt/puppet/bin/puppet --version)"
  echo "Skipping installation."
else
  <%= @installer_cmd %>
  echo " -- Performing Puppet run to preload classification"
  /opt/puppet/bin/puppet agent -t
fi
