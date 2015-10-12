
desc "Tells you if you need to do any cleanup of the code before you push"
task :am_i_done_yet => ['git:check_for_uncommitted_changes', 'tidy', 'git:check_for_uncommitted_changes'] do
   puts "👍   👍   👍   👍   👍   👍   👍   👍   👍   👍   👍   👍  "
   puts "Looks like you're good to ship!"
end
