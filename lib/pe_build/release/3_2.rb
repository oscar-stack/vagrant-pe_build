require 'pe_build/release'

module PEBuild::Release

  three_two_x = newrelease do

    add_release :debian, '6'
    add_release :debian, '7'

    add_release :el, '4'
    add_release :el, '5'
    add_release :el, '6'

    add_release :sles, '11'

    add_release :solaris, '10'
    add_release :solaris, '11'

    add_release :ubuntu, '10.04'
    add_release :ubuntu, '12.04'

    add_release :windows, '2003'
    add_release :windows, '2008R2'
    add_release :windows, '7'
    add_release :windows, '2012'

    # PE 3.x has support for AIX, but as of 2013-08-12 Vagrant has nothing
    # remotely resembling support for AIX WPARs or LPARs. Since it's meaningless
    # to try to add support for AIX, we just leave this commented out.
    #
    # add_release :aix, '5.3'
    # add_release :aix, '6.1'
    # add_release :aix, '7.1'

    set_answer_file :master, File.join(PEBuild.template_dir, 'answers', 'master-3.x.txt.erb')
    set_answer_file :agent,  File.join(PEBuild.template_dir, 'answers', 'agent-3.x.txt.erb')
  end

  @releases['3.2.0'] = three_two_x
  @releases['3.2.1'] = three_two_x
  @releases['3.2.2'] = three_two_x
end

