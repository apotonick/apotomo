require "rake/testtask"

namespace "test" do
  Rake::TestTask.new(:widgets) do |t|
    t.libs << "test"
    t.pattern = 'test/widgets/**/*_test.rb'
  end
end
