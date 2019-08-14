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

task :default => :spec
