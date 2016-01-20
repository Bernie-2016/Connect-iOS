include Helpers

namespace :git do
  desc "Checks for uncommitted changes and aborts if any are found"
  task :check_for_uncommitted_changes do
    puts "Checking for uncommitted changes..."
    if `git status -s`.chomp.length > 0
      puts("!! Uncommitted changes detected!")
      system("git status")
      bail
    end
    puts "Done!"
  end

  desc "Pushes the current branch to origin"
  task :push_origin do
    system("git push origin head") || bail
  end
end
