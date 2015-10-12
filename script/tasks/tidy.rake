namespace :tidy do
  desc "Unfocusses any focussed specs"
  task :specs do
    puts "Unfocussing specs..."

    find_focussed_files_cmd = []
    find_focussed_files_cmd << 'grep -l -r -e'
    find_focussed_files_cmd << '"fit(\\|fdescribe(\\|fcontext"'
    find_focussed_files_cmd << 'src/berniesanders/berniesandersTests'
    find_focussed_files_cmd << '2>/dev/null'
    find_focussed_files_cmd = find_focussed_files_cmd.join(' ')

    `#{find_focussed_files_cmd}`.chomp.split("\n").each do |file_with_focussed_specs|
      puts "#{file_with_focussed_specs}"
      unfocus_cmd = []
      unfocus_cmd << "sed -i ''"
      unfocus_cmd << "-e 's/fit(/it(/g'"
      unfocus_cmd << "-e 's/fdescribe(/describe(/g;'"
      unfocus_cmd << "-e 's/fcontext(/context(/g;'"
      unfocus_cmd << "\"#{file_with_focussed_specs}\""
      unfocus_cmd = unfocus_cmd.join(" ")
      system(unfocus_cmd)
    end

    puts "Done!"
  end

  desc "Sorts the project file"
  task :project_file do
    puts "Sorting the project file..."
    system("script/sort-Xcode-project-file.pl src/berniesanders/berniesanders.xcodeproj/")
    puts "Done!"
  end
end

