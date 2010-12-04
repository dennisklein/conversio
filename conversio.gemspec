# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  
s.name = %q{conversio}
s.version = "0.1.2"

s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
s.authors = ["Jörg Behrendt","Victor Penso"]
s.date = %q{2010-11-19}
s.default_executable = %q{conversio}
s.homepage = 'https://github.com/vpenso/conversio'

s.description = <<-EOF 
Renders plain text files with Markdown syntax to XHTML pages. 
User can define their own Ruby ERB templates to customize the 
XHTML page generation. Also the creation of a table of content 
using the HTML header elements (like `<h1>`) and the syntax
high-lighting of code snippets is supported.
EOF

s.email = %q{v.penso@gsi.de}
s.executables = ["conversio"]
s.extra_rdoc_files = [
  "bin/conversio", 
  "lib/conversio.rb", 
  "lib/conversio/converter.rb", 
  "lib/conversio/htmltoc.rb", 
  "lib/conversio/pygmentizer.rb"
]
s.files = [
  "README.md", 
  "HISTORY.md", 
  "bin/conversio", 
  "conversio.gemspec", 
  "lib/conversio.rb", 
  "lib/conversio/converter.rb", 
  "lib/conversio/htmltoc.rb", 
  "lib/conversio/pygmentizer.rb",
  "templates/default.erb",
  "templates/no_css.erb",
  "templates/dark.erb",
  "templates/light.erb"
]
s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Conversio"]
s.require_paths = ["lib"]
s.rubyforge_project = %q{conversio}
s.rubygems_version = %q{1.3.6}
s.summary = %q{Renders Markdown plain text files to HTML}

s.add_dependency('bluecloth', '>= 2.0.9')
s.add_dependency('kramdown')
s.requirements << 'Pygments  (http://pygments.org/)'
s.licenses = 'GPLv3'

end
