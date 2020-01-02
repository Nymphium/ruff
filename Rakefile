# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'yard'
require 'ruff/version'

YARDOPTS = [
  '--output-dir=docs',
  "--title=Ruff #{Ruff::VERSION} Documentation",
  '--markup-provider=redcarpet',
  '--markup=markdown',
  '--charset=utf-8',
  '--no-private'
].freeze

RuboCop::RakeTask.new

YARD::Rake::YardocTask.new do |doc|
  doc.name = 'doc'

  YARDOPTS.each { |opt| doc.options << opt }

  doc.files = FileList.new('lib/**/*.rb').exclude('**/util.rb')
end

desc 'new version'
task(:newver, %i[major minor patch]) do |_, args|
  f = File.open('version', 'r+')
  v = f.read.gsub(/[^a-zA-Z0-9\-_\.]/, '').split '.'
  newv = args.to_a.dup

  begin
    case newv[0]
    when '-'
      newv[0] = v[0]

      case newv[1]
      when '-'
        newv[1] = v[1]

        case newv[2]
        when '+'
          newv[2] = v[2].to_i + 1
        end
      when '+'
        newv[1] = v[1].to_i + 1
        newv[2] = 0
      else
        newv[2] = 0
      end
    when '+'
      newv[0] = v[0].to_i + 1
      newv[1] = 0
      newv[2] = 0
    end
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
