require 'pe_buld/release'

module PEBuild::Release

  two_five_x = newrelease do

    add_release :debian, 6

    add_release :el, 5
    add_release :el, 6

    add_release :sles, 11

    add_release :solaris, 10

    add_release :ubuntu, '10.04'

    add_release :windows, '2003'
    add_release :windows, '2008R2'
    add_release :windows, 7

    set_answer_file :master, File.join(PEBuild.template_dir, 'answers', 'master-2.x.txt.erb')
    set_answer_file :agent,  File.join(PEBuild.template_dir, 'answers', 'agent-2.x.txt.erb')
  end

  @releases['2.5.0'] = two_five_x
  @releases['2.5.1'] = two_five_x
  @releases['2.5.2'] = two_five_x
  @releases['2.5.3'] = two_five_x
end
