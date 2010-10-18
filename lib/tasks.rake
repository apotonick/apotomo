namespace "test" do
  TestTaskWithoutDescription.new(:widgets => "test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'test/widgets/**/*_test.rb'
  end
end
