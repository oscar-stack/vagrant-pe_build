require 'vagrant'

module PEBuild
module ConfigDefault

  # @param [Symbol] iv The instance variable to set the default value
  # @param [Object] default The default value
  def set_default(iv, default)
    iv_val = instance_variable_get(iv)
    if iv_val == Vagrant::Plugin::V2::Config::UNSET_VALUE
      instance_variable_set(iv, default)
    end
  end
  private :set_default
end
end
