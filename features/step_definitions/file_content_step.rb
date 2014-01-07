Then /^the output should match the content file "(.*)"$/ do |filename|
  exact_output = nil
  in_current_dir do
    exact_output = File.read(filename)
  end

  all_output.should == exact_output
end
