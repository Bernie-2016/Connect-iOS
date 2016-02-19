module Helpers
  SRCROOT = "src/Connect"
  TESTS_DIR = "#{SRCROOT}/ConnectTests"
  PRODUCTION_DIR = "#{SRCROOT}/Connect"

  def bail
     puts "👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎 "
     puts "💩  Uh oh, looks like something isn't right  💩 "
     puts "👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎 "
     abort
  end
end
