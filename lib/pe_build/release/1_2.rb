require 'pe_build/release'

module PEBuild::Release

  one_oh_x = newrelease do
    add_release :debian, 5
    add_release :debian, 6

    add_release :el, 4
    add_release :el, 5
    add_release :el, 6

    add_release :sles, 11

    add_release :solaris, 10

    add_release :ubuntu, '10.04'

    set_answer_file :master, File.join(PEBuild.template_dir, 'answers', 'master-1.x.txt.erb')
    set_answer_file :agent,  File.join(PEBuild.template_dir, 'answers', 'agent-1.x.txt.erb')
  end

  @releases['1.2.7'] = one_oh_x
  @releases['1.2.6'] = one_oh_x
  @releases['1.2.5'] = one_oh_x
  @releases['1.2.4'] = one_oh_x
  @releases['1.2.3'] = one_oh_x
  @releases['1.2.2'] = one_oh_x
  @releases['1.2.1'] = one_oh_x
  @releases['1.2.0'] = one_oh_x
end
