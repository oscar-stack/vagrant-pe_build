# Define a Puppet Enterprise release
#
# @api private
class PEBuild::Release::Instance

  attr_reader :version

  def initialize(&blk)

    @supported = Hash.new { |hash, key| hash[key] = Set.new }

    @answer_files = {}

    instance_eval(&blk) if blk
  end

  # Determine if Puppet Enterprise supports the specific release
  #
  # @param distro [String] The distribution to check
  # @param dist_release [String] The version release to check
  #
  # @return [true, false]
  def supports?(distro, dist_release)
    distro       = distro.to_sym     unless distro.is_a? Symbol
    dist_release = dist_release.to_s unless dist_release.is_a? String

    @supported[distro].include? dist_release
  end

  # Return the answer file template for the given role and release of PE
  #
  # @param role [Symbol] The role for the template
  #
  # @return
  def answer_file(role)
    @answer_files[role]
  end

  private

  # Define a distribution release as supported.
  #
  # @param distro [String] The distribution to add
  # @param dist_release [String] The version release to add
  #
  # @return [void]
  def add_release(distro, dist_release)
    distro       = distro.to_sym     unless distro.is_a? Symbol
    dist_release = dist_release.to_s unless dist_release.is_a? String

    @supported[distro].add dist_release
  end

  # Set the answer file template for a given role
  #
  # @param role [Symbol] The role for the template
  # @param path [String] The path to the template
  #
  # @return [void]
  def set_answer_file(role, path)
    @answer_files[role] = path
  end
end
