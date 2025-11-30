# frozen_string_literal: true

require_relative 'lib/i18n-inflector/version'

Gem::Specification.new do |s|
  s.name         = 'i18n-inflector-3'
  s.version      = I18n::Inflector::VERSION
  s.authors      = ['Paweł Wilk', 'Alexander Grebennik']
  s.email        = ['pw@gnu.org', 'sl.bug.sl@gmail.com']
  s.homepage     = 'https://github.com/slbug/i18n-inflector'
  s.summary      = 'Inflection module for I18n (Ruby 3+ compatible fork)'
  s.description  = 'Enhances simple I18n backend in a way that it inflects translation data using pattern interpolation. Modernized for Ruby 3.x and 4.x.'
  s.license      = 'LGPL-3.0'

  s.files        = Dir['lib/**/*', 'README.md', 'LGPL-LICENSE', 'ChangeLog', 'docs/**/*']
  s.require_path = 'lib'

  s.required_ruby_version = '>= 3.4'

  s.add_dependency 'i18n', '>= 0.6.0'

  s.metadata = {
    'rubygems_mfa_required' => 'true',
    'bug_tracker_uri' => 'https://github.com/slbug/i18n-inflector/issues',
    'source_code_uri' => 'https://github.com/slbug/i18n-inflector',
    'changelog_uri' => 'https://github.com/slbug/i18n-inflector/blob/master/docs/HISTORY'
  }
end
