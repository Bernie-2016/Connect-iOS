module Helpers
  SRCROOT = "src/berniesanders"
  TESTS_DIR = "#{SRCROOT}/berniesandersTests"
  PRODUCTION_DIR = "#{SRCROOT}/berniesanders"

  def bail
     puts "👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎 "
     puts "💩  Uh oh, looks like something isn't right  💩 "
     puts "👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎 "
     abort
  end
end
