# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'yard'
# require 'ruff/version'

YARD::Rake::YardocTask.new do |doc|
  doc.name = 'doc'

  [
    '--output-dir=docs',
    "--title=Ruff #{Ruff::VERSION} Documentation",
    '--markup-provider=redcarpet',
    '--markup=markdown',
    '--charset=utf-8'
  ].each { |opt| doc.options << opt }

  doc.files = FileList.new 'lib/**/*.rb'
end

desc 'new version'
task(:newver, %i[major minor patch]) do |_, args|
  File.open('version', 'r+') do |f|
    f.write args.to_a.join '.'
  end

  sh 'bash lib/ruff/version.gen.sh > lib/ruff/version.rb'
end

task default: :spec
