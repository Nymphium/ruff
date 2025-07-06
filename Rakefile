# frozen_string_literal: true

require 'bundler/setup'
Bundler.require
require 'rspec/core/rake_task'
require 'yard'
require 'ruff/version'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

YARDOPTS = [
  '--output-dir=docs',
  "--title=Ruff #{Ruff::VERSION} Documentation",
  '--markup-provider=redcarpet',
  '--markup=markdown',
  '--charset=utf-8',
  '--no-private'
].freeze

require 'rspec/core'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = './spec/**/*_spec.rb'
  t.rspec_opts = ['--format', 'documentation']
end

YARD::Rake::YardocTask.new do |doc|
  doc.name = 'doc'

  YARDOPTS.each { |opt| doc.options << opt }

  doc.files = FileList.new('lib/**/*.rb').exclude('**/util.rb')
end

def handle_minor_and_patch_update(newv, v)
  case newv[1]
  when '-'
    newv[1] = v[1]
    newv[2] = v[2].to_i + 1 if newv[2] == '+'
  when '+'
    newv[1] = v[1].to_i + 1
    newv[2] = 0
  else
    newv[2] = 0
  end
end

def handle_major_update(newv, v)
  newv[0] = v[0].to_i + 1
  newv[1] = 0
  newv[2] = 0
end

def update_version_parts(newv, v)
  case newv[0]
  when '-'
    newv[0] = v[0]
    handle_minor_and_patch_update(newv, v)
  when '+'
    handle_major_update(newv, v)
  end
end

desc 'new version'
task(:newver, %i[major minor patch]) do |_, args|
  f = File.open('version', 'r+')
  v = f.read.gsub(/[^a-zA-Z0-9\-_.]/, '').split('.')
  newv = args.to_a.dup

  begin
    update_version_parts(newv, v)
  rescue StandardError => e
    puts e
  end

  p "#{v.join '.'} => #{newv.join '.'}"
  f.seek(0, IO::SEEK_SET)
  f.write newv.join '.'
  f.close

  sh 'bash lib/ruff/version.gen.sh > lib/ruff/version.rb'
end

task default: :spec
