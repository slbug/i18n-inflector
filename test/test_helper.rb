# frozen_string_literal: true

require 'minitest/autorun'
require 'i18n-inflector'

# Disable locale enforcement for tests
I18n.enforce_available_locales = false

module Minitest
  class Test
    def teardown
      I18n.locale             = nil
      I18n.default_locale     = :en
      I18n.load_path          = []
      I18n.available_locales  = nil
      I18n.backend            = nil
    end

    def translations
      I18n.backend.instance_variable_get(:@translations)
    end

    def store_translations(*args)
      data   = args.pop
      locale = args.pop || :en
      I18n.backend.store_translations(locale, data)
    end

    def assert_translation(expected, key, **)
      assert_equal expected, I18n.t(key, **)
    end
  end
end

unless Object.method_defined?(:meta_class)
  Object.class_eval do
    def meta_class
      class << self; self; end
    end
  end
end
