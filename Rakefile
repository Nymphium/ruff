require "bundler/gem_tasks"
require "yard"
require "ruff/version"

YARD::Rake::YardocTask.new {|doc|
  doc.name = "doc"

  [
    "--output-dir=docs",
    "--title=Ruff #{Ruff::VERSION} Documentation",
    "--markup-provider=redcarpet",
    "--markup=markdown",
    "--charset=utf-8"
  ].each{|opt| doc.options << opt }

  doc.files = FileList.new "lib/**/*.rb"
}

desc "new version"
task(:newver, [:major, :minor, :patch]){|_, args|
  File.open('version.h', 'r+'){|f|
    f.write <<-EOL
#define RUFF_VERSION "#{args.to_a.join "."}"
    EOL
  }

  sh "cpp -P lib/ruff/version.cpp.rb > lib/ruff/version.rb"
}

task :default => :spec
