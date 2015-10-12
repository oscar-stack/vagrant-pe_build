require 'vagrant/errors'

module PEBuild
  module Util
    # Utilities related to Vagrant Machine communications
    #
    # This module provides general-purpose utility functions for communicating
    # with Vagrant machines.
    #
    # @since 0.13.0
    module MachineComms

      # Determine if commands can be executed on a Vagrant machine
      #
      # @param machine [Vagrant::Machine] A Vagrant machine.
      #
      # @return [true] If the machine can accept communication.
      # @return [false] If the machine cannot accept communication.
      def is_reachable?(machine)
        begin
          machine.communicate.ready?
        rescue Vagrant::Errors::VagrantError
          # WinRM will raise an error if the VM isn't running instead of
          # returning false (GH-6356).
          false
        end
      end
      module_function :is_reachable?

      class MachineNotReachable < ::Vagrant::Errors::VagrantError
        error_key(:machine_not_reachable, 'pebuild.errors')
      end

      # Raise an error if Vagrant commands cannot be executed on a machine
      #
      # This function raises an error if a given vagrant machine is not ready
      # for communication.
      #
      # @param machine [Vagrant::Machine] A Vagrant machine.
      #
      # @return [void] If the machine can accept communication.
      # @raise [MachineNotReachable] If the machine cannot accept
      #   communication.
      def ensure_reachable(machine)
        raise MachineNotReachable, :vm_name => machine.name.to_s unless is_reachable?(machine)
      end
      module_function :ensure_reachable

    end
  end
end
