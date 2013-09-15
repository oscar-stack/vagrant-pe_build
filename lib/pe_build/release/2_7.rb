require 'pe_build/release'

module PEBuild::Release

  two_seven_x = newrelease do

    add_release :debian, 6

    add_release :el, 5
    add_release :el, 6

    add_release :sles, 11

    add_release :solaris, 10

    add_release :ubuntu, '10.04'
    add_release :ubuntu, '12.04'

    add_release :windows, '2003'
    add_release :windows, '2008R2'
    add_release :windows, 7

    set_answer_file :master, File.join(PEBuild.template_dir, 'answers', 'master-2.x.txt.erb')
    set_answer_file :agent,  File.join(PEBuild.template_dir, 'answers', 'agent-2.x.txt.erb')
  end

  @releases['2.7.0'] = two_seven_x
  @releases['2.7.1'] = two_seven_x
  @releases['2.7.2'] = two_seven_x
end
