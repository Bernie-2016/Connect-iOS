module Helpers
  SRCROOT = "src/Movement"
  TESTS_DIR = "#{SRCROOT}/MovementTests"
  PRODUCTION_DIR = "#{SRCROOT}/Movement"

  def bail
     puts "👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎 "
     puts "💩  Uh oh, looks like something isn't right  💩 "
     puts "👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎   👎 "
     abort
  end
end
