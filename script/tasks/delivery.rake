require 'shell'

desc "Checks that we're ready to push, and then pushes the current branch to origin"
task :shipit => [:am_i_done_yet, "git:push_origin"]  do
  puts "Don't be blue, peter!"
end

namespace :shipit do
 desc "Checks that we're ready to deploy, bumps version, archives and delivers to ITC for acceptance"
 task :acceptance => [:am_i_done_yet] do
   bump_version
   tag_version
   archive_and_deliver(environment: 'acceptance')
   Rake::Task['git:push_origin'].invoke
 end

 desc "Checks that we're ready to deploy, bumps version, archives and delivers to ITC for production"
 task :production => [:am_i_done_yet] do
   bump_version
   tag_version
   archive_and_deliver(environment: 'production')
   Rake::Task['git:push_origin'].invoke
 end
 
 desc "Checks that we're ready to deploy, bumps version, archives and delivers to ITC for production"
 task :acceptance_and_production => [:am_i_done_yet] do
   bump_version
   tag_version
   archive_and_deliver(environment: 'acceptance')
   archive_and_deliver(environment: 'production')
   Rake::Task['git:push_origin'].invoke
 end
end

def bump_version
  Dir.chdir("src/Connect")
  system("agvtool next-version -all")
  system("git add .")
  system("git ci -m 'Bump build'")
  Dir.chdir("../..")
end

def tag_version
  Dir.chdir("src/Connect")
  marketing_version = `agvtool what-marketing-version -terse1`.chomp
  build_number = `agvtool what-version -terse`.chomp
  Dir.chdir("../..")
  system("git tag '#{marketing_version}_#{build_number}'")
end

def archive_and_deliver(environment:nil)
  system("./script/archive_and_deliver #{environment}")
end
