module PEBuild::Release

  two_six_x = newrelease do

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
  end

  @releases['2.6.0'] = two_six_x
  @releases['2.6.1'] = two_six_x
end
