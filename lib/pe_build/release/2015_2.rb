require 'pe_build/release'

module PEBuild::Release

  twentyfifteen_two_x = newrelease do

    # PE 2015.2.x supports many more platforms, but the pe_bootstrap
    # provisioner can only work with tarball installers --- which are now only
    # available for the following master platforms:
    add_release :el, '6'
    add_release :el, '7'

    add_release :sles, '11'
    add_release :sles, '12'

    add_release :ubuntu, '12.04'
    add_release :ubuntu, '14.04'

    # Nothing has changed for installation of Windows agents.

    add_release :windows, '2003'
    add_release :windows, '2003R2'
    add_release :windows, '2008'
    add_release :windows, '2008R2'
    add_release :windows, '7'
    add_release :windows, '2012'
    add_release :windows, '2012R2'
    add_release :windows, '8'
    add_release :windows, '8.1'

    set_answer_file :master, File.join(PEBuild.template_dir, 'answers', 'master-2015.x.txt.erb')
    set_answer_file :agent,  File.join(PEBuild.template_dir, 'answers', 'agent-2015.x.txt.erb')
  end

  @releases['2015.2.0'] = twentyfifteen_two_x
  @releases['2015.2.1'] = twentyfifteen_two_x
end
