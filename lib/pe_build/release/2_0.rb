module PEBuild::Release

  two_oh_x = newrelease do
    add_release :debian, 5
    add_release :debian, 6

    add_release :el, 4
    add_release :el, 5
    add_release :el, 6

    add_release :sles, 11

    add_release :solaris, 10

    add_release :ubuntu, '10.04'
  end

  @releases['2.0.0'] = two_oh_x
  @releases['2.0.1'] = two_oh_x
  @releases['2.0.2'] = two_oh_x
  @releases['2.0.3'] = two_oh_x
end
