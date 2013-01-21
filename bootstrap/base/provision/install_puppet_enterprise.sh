if [ -f /opt/puppet/bin/puppet ]; then
  echo "Puppet Enterprise already present, version $(/opt/puppet/bin/puppet --version)"
  echo "Skipping installation."
else
  <%= @installer_cmd %>
  echo
  echo
  echo " -- Notice: scheduling Puppet run in one minute to install mcollective"
  echo "/opt/puppet/bin/puppet agent --onetime --noop" | at next minute
fi
