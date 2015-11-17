include Helpers
task :specs do
  specs_cmd = []
  specs_cmd << "xcodebuild clean build test"
  specs_cmd << "-project #{SRCROOT}/Movement.xcodeproj"
  specs_cmd << "-scheme Movement"
  specs_cmd << "-sdk iphonesimulator"
  specs_cmd << "ONLY_ACTIVE_ARCH=NO"
  specs_cmd = specs_cmd.join(" ")

  puts "Running specs..."
  if(!system(specs_cmd))
    bail
  end
  puts "Done!"
end

