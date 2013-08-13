# Define a Puppet Enterprise release
#
# @api private
class PEBuild::Release::Instance

  attr_reader :version

  def initialize(&blk)

    @supported = Hash.new { |hash, key| hash[key] = Set.new }

    instance_eval(&blk) if blk
  end

  # Determine if Puppet Enterprise supports the specific release
  #
  # @param distro [String] The distribution to check
  # @param dist_version [String] The version release to check
  #
  # @return [true, false]
  def supports?(distro, dist_release)
    distro       = distro.to_sym     unless distro.is_a? Symbol
    dist_release = dist_release.to_s unless dist_release.is_a? String

    @supported[distro].include? dist_release
  end

  private

  # Define a distribution release as supported.
  #
  # @param distro [String] The distribution to add
  # @param dist_version [String] The version release to add
  #
  # @return [void]
  def add_release(distro, dist_release)
    distro       = distro.to_sym     unless distro.is_a? Symbol
    dist_release = dist_release.to_s unless dist_release.is_a? String

    @supported[distro].add dist_release
  end
end
