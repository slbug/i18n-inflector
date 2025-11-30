# frozen_string_literal: true

require 'test_helper'

class I18nInflectorTest < Minitest::Test
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Inflector
    include I18n::Backend::Fallbacks
  end

  def setup
    I18n.backend = Backend.new
    store_translations(:xx, i18n: {inflections: {
      gender: {
        m: 'male',
        f: 'female',
        n: 'neuter',
        s: 'strange',
        masculine: '@m',
        feminine: '@f',
        neuter: '@n',
        neutral: '@neuter',
        default: 'neutral'
      },
      person: {
        i: 'I',
        you: 'You'
      },
      :@gender => {
        m: 'male',
        f: 'female',
        n: 'neuter',
        s: 'strange',
        masculine: '@m',
        feminine: '@f',
        neuter: '@n',
        neutral: '@neuter',
        default: 'neutral'
      }
    }})

    store_translations(:xx, 'welcome'       => 'Dear @{f:Lady|m:Sir|n:You|All}!')
    store_translations(:xx, 'named_welcome' => 'Dear @gender{f:Lady|m:Sir|n:You|All}!')
    I18n.locale = :en
  end

  def test_backend_inflector_has_methods_to_test_its_switches
    assert I18n.inflector.options.unknown_defaults   = true
    refute I18n.inflector.options.excluded_defaults  = false
    refute I18n.inflector.options.aliased_patterns   = false
    refute I18n.inflector.options.raises             = false
    refute I18n.backend.inflector.options.raises
    assert I18n.backend.inflector.options.unknown_defaults
    refute I18n.backend.inflector.options.excluded_defaults
    refute I18n.backend.inflector.options.aliased_patterns
  end

  def test_backend_inflector_store_translations_regenerates_inflection_structures_when_translations_are_loaded
    store_translations(:xx, i18n: {inflections: {gender: {o: 'other'}}})
    store_translations(:xx, 'hi' => 'Dear @{f:Lady|o:Others|n:You|All}!')

    assert_translation 'Dear Others!', 'hi', gender: :o,       locale: :xx
    assert_translation 'Dear Lady!',   'hi', gender: :f,       locale: :xx
    assert_translation 'Dear You!',    'hi', gender: :unknown, locale: :xx
    assert_translation 'Dear All!',    'hi', gender: :m,       locale: :xx
  end

  def test_backend_inflector_store_translations_raises_i18n_duplicatedinflectiontoken_when_duplicated_token_is_given
    assert_raises I18n::DuplicatedInflectionToken do
      store_translations(:xx, i18n: {inflections: {gender: {o: 'other'}, person: {o: 'o'}}})
    end
  end

  def test_backend_inflector_strict_store_translations_allows_duplicated_tokens_across_differend_kinds
    assert_silent do
      store_translations(:xx, i18n: {inflections: {:@gender => {o: 'other'}, :@person => {o: 'o'}}})
      store_translations(:xx, i18n: {inflections: {gender: {o: 'other'}, :@gender => {o: 'o'}}})
    end
  end

  def test_backend_inflector_store_translations_raises_i18n_badinflectionalias_when_bad_alias_is_given
    assert_raises I18n::BadInflectionAlias do
      store_translations(:xx, i18n: {inflections: {gender: {o: '@xnonexistant'}}})
    end
  end

  def test_backend_inflector_store_translations_raises_i18n_badinflectionalias_when_bad_default_is_given
    assert_raises I18n::BadInflectionAlias do
      store_translations(:xx, i18n: {inflections: {gender: {default: '@ynonexistant'}}})
    end
  end

  def test_backend_inflector_strict_store_translations_raises_i18n_badinflectionalias_when_bad_alias_is_given
    assert_raises I18n::BadInflectionAlias do
      store_translations(:xx, i18n: {inflections: {:@gender => {oh: '@znonex'}}})
    end
  end

  def test_backend_inflector_strict_store_translations_raises_i18n_badinflectionalias_when_bad_default_is_given
    assert_raises I18n::BadInflectionAlias do
      store_translations(:xx, i18n: {inflections: {:@gender => {default: '@cnonex'}}})
    end
  end

  def test_backend_inflector_store_translations_raises_i18n_badinflectiontoken_when_bad_token_is_given
    assert_raises I18n::BadInflectionToken do
      store_translations(:xx, i18n: {inflections: {gender: {o: '@'}}})
      store_translations(:xx, i18n: {inflections: {gender: {tok: nil}}})
      store_translations(:xx, i18n: {inflections: {:@gender => {o: '@'}}})
      store_translations(:xx, i18n: {inflections: {:@gender => {tok: nil}}})
    end
  end

  def test_backend_inflector_translate_allows_pattern_only_translation_data
    store_translations(:xx, 'clear_welcome' => '@{f:Lady|m:Sir|n:You|All}')

    assert_translation 'Lady', 'clear_welcome', gender: 'f', locale: :xx
    store_translations(:xx, 'clear_welcome' => '@gender{f:Lady|m:Sir|n:You|All}')

    assert_translation 'Lady', 'clear_welcome', gender: 'f', locale: :xx
  end

  def test_backend_inflector_translate_allows_patterns_to_be_escaped_using_or
    store_translations(:xx, 'escaped_welcome' => '@@{f:AAAAA|m:BBBBB}')

    assert_translation '@{f:AAAAA|m:BBBBB}', 'escaped_welcome', gender: 'f', locale: :xx
    store_translations(:xx, 'escaped_welcome' => '\@{f:AAAAA|m:BBBBB}')

    assert_translation '@{f:AAAAA|m:BBBBB}', 'escaped_welcome', gender: 'f', locale: :xx
    assert_translation 'Dear All!', 'welcome', gender: nil, locale: :xx, inflector_unknown_defaults: false
    store_translations(:xx, 'escaped_welcome' => 'Dear \@{f:Lady|m:Sir|n:You|All}!')

    assert_equal 'Dear @{f:Lady|m:Sir|n:You|All}!',
      I18n.t('escaped_welcome', locale: :xx, inflector_unknown_defaults: false)
  end

  def test_backend_inflector_translate_picks_lady_for_f_gender_option
    assert_translation 'Dear Lady!', 'welcome', gender: :f, locale: :xx
  end

  def test_backend_inflector_translate_picks_lady_for_f_gender_option
    assert_translation 'Dear Lady!', 'welcome', gender: 'f', locale: :xx
  end

  def test_backend_inflector_translate_picks_sir_for_m_gender_option
    assert_translation 'Dear Sir!', 'welcome', gender: :m, locale: :xx
  end

  def test_backend_inflector_translate_picks_sir_for_masculine_gender_option
    assert_translation 'Dear Sir!', 'welcome', gender: :masculine, locale: :xx
  end

  def test_backend_inflector_translate_picks_sir_for_masculine_gender_option
    assert_translation 'Dear Sir!', 'welcome', gender: 'masculine', locale: :xx
  end

  def test_backend_inflector_translate_picks_an_empty_string_when_no_default_token_is_present_and_no_free_text_is_there
    store_translations(:xx, 'none_welcome' => '@{n:You|f:Lady}')

    assert_translation '', 'none_welcome', gender: 'masculine', locale: :xx
  end

  def test_backend_inflector_translate_allows_multiple_patterns_in_the_same_data
    store_translations(:xx,
      'multiple_welcome' => '@@{f:AAAAA|m:BBBBB} @{f:Lady|m:Sir|n:You|All} @{f:Lady|All}@{m:Sir|All}@{n:You|All}')

    assert_translation '@{f:AAAAA|m:BBBBB} Sir AllSirAll', 'multiple_welcome', gender: 'masculine', locale: :xx
  end

  def test_backend_inflector_translate_falls_back_to_default_for_the_unknown_gender_option
    assert_translation 'Dear You!', 'welcome', gender: :unknown, locale: :xx
  end

  def test_backend_inflector_translate_falls_back_to_default_for_a_gender_option_set_to_nil
    assert_translation 'Dear You!', 'welcome', gender: nil, locale: :xx
  end

  def test_backend_inflector_translate_falls_back_to_default_for_no_gender_option
    assert_translation 'Dear You!', 'welcome', locale: :xx
  end

  def test_backend_inflector_translate_falls_back_to_free_text_for_the_proper_gender_option_but_not_present_in_pattern
    assert_translation 'Dear All!', 'welcome', gender: :s, locale: :xx
  end

  def test_backend_inflector_translate_falls_back_to_free_text_when_inflector_unknown_defaults_is_false
    assert_translation 'Dear All!', 'welcome', gender: :unknown, locale: :xx, inflector_unknown_defaults: false
    assert_translation 'Dear All!', 'welcome', gender: :s, locale: :xx, inflector_unknown_defaults: false
    assert_translation 'Dear All!', 'welcome', gender: nil, locale: :xx, inflector_unknown_defaults: false
  end

  def test_backend_inflector_translate_uses_default_token_when_inflection_option_is_set_to_default
    assert_translation 'Dear You!', 'welcome', gender: :default, locale: :xx, inflector_unknown_defaults: true
    assert_translation 'Dear You!', 'welcome', gender: :default, locale: :xx, inflector_unknown_defaults: false
  end

  def test_backend_inflector_translate_falls_back_to_default_for_no_inflection_option_when_inflector_unknown_defaults_is_false
    assert_translation 'Dear You!', 'welcome', locale: :xx, inflector_unknown_defaults: false
  end

  def test_backend_inflector_translate_falls_back_to_free_text_for_the_unknown_gender_option_when_global_inflector_unknown_defaults_is_false
    I18n.inflector.options.unknown_defaults = false

    assert_translation 'Dear All!', 'welcome', gender: :unknown, locale: :xx
  end

  def test_backend_inflector_translate_falls_back_to_default_for_the_unknown_gender_option_when_global_inflector_unknown_defaults_is_overriden
    I18n.inflector.options.unknown_defaults = false

    assert_translation 'Dear You!', 'welcome', gender: :unknown, locale: :xx, inflector_unknown_defaults: true
  end

  def test_backend_inflector_translate_falls_back_to_default_token_for_ommited_gender_option_when_inflector_excluded_defaults_is_true
    assert_translation 'Dear You!', 'welcome', gender: :s, locale: :xx, inflector_excluded_defaults: true
    assert_translation 'Dear You!', 'named_welcome', :@gender => :s, locale: :xx,
      inflector_excluded_defaults: true
    I18n.inflector.options.excluded_defaults = true

    assert_translation 'Dear You!', 'welcome', gender: :s, locale: :xx
    assert_translation 'Dear You!', 'named_welcome', gender: :s, locale: :xx
  end

  def test_backend_inflector_translate_falls_back_to_free_text_for_ommited_gender_option_when_inflector_excluded_defaults_is_false
    assert_translation 'Dear All!', 'welcome', gender: :s, locale: :xx, inflector_excluded_defaults: false
    I18n.inflector.options.excluded_defaults = false

    assert_translation 'Dear All!', 'welcome', gender: :s, locale: :xx
  end

  def test_backend_inflector_translate_raises_i18n_invalidoptionforkind_when_bad_kind_is_given_and_inflector_raises_is_true
    assert_silent do
      I18n.t('welcome', locale: :xx, inflector_raises: true)
    end
    tr = I18n.backend.send(:translations)
    tr[:xx][:i18n][:inflections][:gender].delete(:default)
    store_translations(:xx, i18n: {inflections: {gender: {o: 'other'}}})
    assert_raises(I18n::InflectionOptionNotFound)  { I18n.t('welcome', locale: :xx, inflector_raises: true) }
    assert_raises(I18n::InvalidInflectionOption) { I18n.t('welcome', locale: :xx, gender: '', inflector_raises: true) }
    assert_raises(I18n::InvalidInflectionOption) { I18n.t('welcome', locale: :xx, gender: nil, inflector_raises: true) }
    assert_raises I18n::InflectionOptionNotFound do
      I18n.inflector.options.raises = true
      I18n.t('welcome', locale: :xx)
    end
  end

  def test_backend_inflector_translate_raises_i18n_misplacedinflectiontoken_when_misplaced_token_is_given_and_inflector_raises_is_true
    store_translations(:xx, 'hi' => 'Dear @{f:Lady|i:BAD_TOKEN|n:You|First}!')
    assert_raises(I18n::MisplacedInflectionToken) { I18n.t('hi', locale: :xx, inflector_raises: true) }
    assert_raises I18n::MisplacedInflectionToken do
      I18n.inflector.options.raises = true
      I18n.t('hi', locale: :xx)
    end
  end

  def test_backend_inflector_translate_raises_i18n_misplacedinflectiontoken_when_bad_token_is_given_and_inflector_raises_is_true
    store_translations(:xx, 'hi' => 'Dear @{f:Lady|i:Me|n:You|First}!')
    assert_raises(I18n::MisplacedInflectionToken) { I18n.t('hi', locale: :xx, inflector_raises: true) }
    assert_raises I18n::MisplacedInflectionToken do
      I18n.inflector.options.raises = true
      I18n.t('hi', locale: :xx)
    end
  end

  def test_backend_inflector_translate_works_with_patterns
    store_translations(:xx, 'hi' => 'Dear @{f:Lady|m:%<test>s}!')

    assert_translation 'Dear Dude!', 'hi', gender: :m, locale: :xx, test: 'Dude'
    store_translations(:xx, 'to be' => '%<person>s @{i:am|you:are}')

    assert_translation 'you are', 'to be', person: :you, locale: :xx
  end

  def test_backend_inflector_translate_works_with_doubled_patterns
    store_translations(:xx, 'dd' => 'Dear @{f:Lady|m:Sir|All}! Dear @{f:Lady|m:Sir|All}!')

    assert_translation 'Dear Lady! Dear Lady!', 'dd', gender: :f, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{f:Lady|m:%<test>s}! Dear @{f:Lady|m:%<test>s}!')

    assert_translation 'Dear Dude! Dear Dude!', 'hi', gender: :m, locale: :xx, test: 'Dude'
  end

  def test_backend_inflector_translate_works_with_complex_patterns
    store_translations(:xx,
      i18n: {inflections: {:@tense => {s: 's', now: 'now', past: 'later',
                                       default: 'now'}}})
    store_translations(:xx, 'hi' => '@gender+tense{m+now:he is|f+past:she was} here!')

    assert_translation 'he is here!', 'hi', gender: :m, locale: :xx, inflector_raises: true
    assert_translation 'he is here!', 'hi', gender: :m, locale: :xx, inflector_raises: true
    assert_equal 'he is here!',
      I18n.t('hi', gender: :m, tense: :s, locale: :xx, inflector_excluded_defaults: true)
    assert_equal 'she was here!',
      I18n.t('hi', gender: :f, tense: :past, locale: :xx, inflector_raises: true)
    assert_equal 'she was here!',
      I18n.t('hi', gender: :feminine, tense: :past, locale: :xx, inflector_raises: true)
    store_translations(:xx, 'hi' => '@gender+tense{masculine+now:he is|feminine+past:she was}')

    assert_equal 'he is',
      I18n.t('hi', gender: :m, tense: :now, inflector_aliased_patterns: true, locale: :xx)
    assert_equal 'she was',
      I18n.t('hi', gender: :f, tense: :past, inflector_aliased_patterns: true, locale: :xx)
    store_translations(:xx, 'hi' => '@gender+tense{masculine+now:he is|feminine+past:she was}')

    assert_equal 'she was',
      I18n.t('hi', gender: :f, tense: :past, inflector_aliased_patterns: true, locale: :xx)
    store_translations(:xx, 'hi' => '@gender+tense{masculine+now:he is|feminine+past:she was}')

    assert_equal 'she was',
      I18n.t('hi', gender: :feminine, tense: :past, inflector_aliased_patterns: true,
        locale: :xx)
    store_translations(:xx, 'hi' => '@gender+tense{masculine+now:he is|m+past:he was}')

    assert_equal 'he was',
      I18n.t('hi', gender: :m, tense: :past, inflector_aliased_patterns: true, locale: :xx)
    store_translations(:xx, 'hi' => '@gender+tense{m+now:he is|masculine+past:he was}')

    assert_equal 'he was',
      I18n.t('hi', gender: :m, tense: :past, inflector_aliased_patterns: true, locale: :xx)
    store_translations(:xx, 'hi' => '@gender+tense{m+now:~|f+past:she was}')

    assert_translation 'male now', 'hi', gender: :m, tense: :now, locale: :xx
  end

  def test_backend_inflector_translate_works_with_multiple_patterns
    store_translations(:xx, 'hi' => '@gender{m:Sir|f:Lady}{m: Lancelot|f: Morgana}')

    assert_translation 'Sir Lancelot', 'hi', gender: :m, locale: :xx
    assert_translation 'Lady Morgana', 'hi', gender: :f, locale: :xx
    store_translations(:xx, 'hi' => '@{m:Sir|f:Lady}{m: Lancelot|f: Morgana}')

    assert_translation 'Sir Lancelot', 'hi', gender: :m, locale: :xx
    assert_translation 'Lady Morgana', 'hi', gender: :f, locale: :xx
    store_translations(:xx, 'hi' => 'Hi @{m:Sir|f:Lady}{m: Lancelot|f: Morgana}!')

    assert_translation 'Hi Sir Lancelot!', 'hi', gender: :m, locale: :xx
  end

  def test_backend_inflector_translate_works_with_key_based_inflections
    I18n.backend.store_translations(:xx, '@hi' => {m: 'Sir', f: 'Lady', n: 'You',
                                                   :@free => 'TEST', :@prefix => 'Dear ', :@suffix => '!'})

    assert_translation 'Dear Sir!', '@hi', gender: :m, locale: :xx, inflector_raises: true
    assert_translation 'Dear Lady!', '@hi', gender: :f, locale: :xx, inflector_raises: true
    assert_translation 'Dear TEST!', '@hi', gender: :x, locale: :xx, inflector_unknown_defaults: false
    assert_translation 'Dear TEST!', '@hi', gender: :x, locale: :xx, inflector_unknown_defaults: false
  end

  def test_backend_inflector_translate_raises_i18n_complexpatternmalformed_for_malformed_complex_patterns
    store_translations(:xx,
      i18n: {inflections: {:@tense => {now: 'now', past: 'later',
                                       default: 'now'}}})
    store_translations(:xx, 'hi' => '@gender+tense{m+now+cos:he is|f+past:she was} here!')
    assert_raises I18n::ComplexPatternMalformed do
      I18n.t('hi', gender: :m, person: :you, locale: :xx, inflector_raises: true)
    end
    store_translations(:xx, 'hi' => '@gender+tense{m+:he is|f+past:she was} here!')
    assert_raises I18n::ComplexPatternMalformed do
      I18n.t('hi', gender: :m, person: :you, locale: :xx, inflector_raises: true)
    end
    store_translations(:xx, 'hi' => '@gender+tense{+:he is|f+past:she was} here!')
    assert_raises I18n::ComplexPatternMalformed do
      I18n.t('hi', gender: :m, person: :you, locale: :xx, inflector_raises: true)
    end
    store_translations(:xx, 'hi' => '@gender+tense{m:he is|f+past:she was} here!')
    assert_raises I18n::ComplexPatternMalformed do
      I18n.t('hi', gender: :m, person: :you, locale: :xx, inflector_raises: true)
    end
  end

  def test_backend_inflector_translate_works_with_wildcard_tokens
    store_translations(:xx, 'hi' => 'Dear @{n:You|*:Any|All}!')

    assert_translation 'Dear You!', 'hi', gender: :n, locale: :xx
    assert_translation 'Dear Any!', 'hi', gender: :m, locale: :xx
    assert_translation 'Dear Any!', 'hi', gender: :f, locale: :xx
    assert_translation 'Dear You!', 'hi', gender: :xxxxxx, locale: :xx
    assert_translation 'Dear You!', 'hi', locale: :xx
  end

  def test_backend_inflector_translate_works_with_loud_tokens
    store_translations(:xx, 'hi' => 'Dear @{m:~|n:You|All}!')

    assert_translation 'Dear male!', 'hi', gender: :m, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @gender{m:~|n:You|All}!')

    assert_translation 'Dear male!', 'hi', gender: :m, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{masculine:~|n:You|All}!')

    assert_translation 'Dear male!', 'hi', gender: :m, locale: :xx, inflector_aliased_patterns: true
    store_translations(:xx, 'hi' => 'Dear @{f,m:~|n:You|All}!')

    assert_translation 'Dear male!', 'hi', gender: :m, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{!n:~|n:You|All}!')

    assert_translation 'Dear male!', 'hi', gender: :m, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{!n:\~|n:You|All}!')

    assert_translation 'Dear ~!', 'hi', gender: :m, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{!n:\\\\~|n:You|All}!')

    assert_translation 'Dear \\~!', 'hi', gender: :m, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{*:~|n:You|All}!')

    assert_translation 'Dear male!', 'hi', gender: :m, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{*:~|n:You|All}!')

    assert_translation 'Dear neuter!', 'hi', locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{m:abc|*:~|n:You|All}!')

    assert_translation 'Dear neuter!', 'hi', locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{*:~|All}!')

    assert_translation 'Dear All!', 'hi', gender: :unasdasd, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{*:~|All}!')

    assert_translation 'Dear All!', 'hi', gender: nil, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{*:~|All}!')

    assert_translation 'Dear neuter!', 'hi', gender: :n, locale: :xx
    store_translations(:xx,
      i18n: {inflections: {:@tense => {s: 's', now: 'now', past: 'later',
                                       default: 'now'}}})
    store_translations(:xx, 'hi' => 'Dear @gender+tense{*+*:~|All}!')

    assert_translation 'Dear male now!', 'hi', gender: :m, person: :i, locale: :xx
    assert_translation 'Dear neuter now!', 'hi', locale: :xx
    assert_translation 'Dear neuter later!', 'hi', tense: :past, locale: :xx
  end

  def test_backend_inflector_translate_works_with_tokens_separated_by_commas
    store_translations(:xx, 'hi' => 'Dear @{f,m:Someone|n:You|All}!')

    assert_translation 'Dear Someone!', 'hi', gender: :m, locale: :xx
  end

  def test_backend_inflector_translate_works_with_collections
    h = {}
    h[:hi2] = h[:hi] = 'Dear Someone!'
    store_translations(:xx,
      'welcomes' => {'hi' => 'Dear @{f,m:Someone|n:You|All}!',
                     'hi2' => 'Dear @{f,m:Someone|n:You|All}!'})

    assert_translation h, 'welcomes', gender: :m, foo: 5, locale: :xx
  end

  def test_backend_inflector_translate_works_with_arrays_as_results
    a = %i(one two three)
    store_translations(:xx, 'welcomes' => {'hi' => a})
    store_translations(:uu, 'welcomes' => {'hi' => a})

    assert_translation a, 'welcomes.hi', gender: :m, locale: :xx
    assert_translation a, 'welcomes.hi', gender: :m, locale: :uu
    a = %i(one two x@{m:man|woman}d)
    store_translations(:xx, 'welcomes' => {'hi' => a})
    store_translations(:uu, 'welcomes' => {'hi' => a})

    assert_translation a, 'welcomes.hi', gender: :m, locale: :xx
    assert_translation a, 'welcomes.hi', gender: :m, locale: :uu
    a = %i(one two xmand)

    assert_translation a, 'welcomes.hi', gender: :m, locale: :xx, inflector_interpolate_symbols: true
    a = %i(one two xd)

    assert_translation a, 'welcomes.hi', gender: :m, locale: :uu, inflector_interpolate_symbols: true
    a = %i(one two x@{m:man|woman}d)

    assert_equal a,
      I18n.t('welcomes.hi', gender: :m, locale: :xx, inflector_traverses: false,
        inflector_interpolate_symbols: true)
    a = %i(one two x@{m:man|woman}d)

    assert_equal a,
      I18n.t('welcomes.hi', gender: :m, locale: :uu, inflector_traverses: false,
        inflector_interpolate_symbols: true)
  end

  def test_backend_inflector_translate_works_with_other_types_as_results
    store_translations(:xx, 'welcomes' => {'hi' => 31_337})

    assert_translation 31_337, 'welcomes.hi', gender: :m, locale: :xx
  end

  def test_backend_inflector_translate_works_with_negative_tokens
    store_translations(:xx, 'hi' => 'Dear @{!m:Lady|m:Sir|n:You|All}!')

    assert_translation 'Dear Lady!', 'hi', gender: :n, locale: :xx
    assert_translation 'Dear Sir!', 'hi', gender: :m, locale: :xx
    assert_translation 'Dear Lady!', 'hi', locale: :xx
    assert_translation 'Dear Lady!', 'hi', gender: :unknown, locale: :xx
    store_translations(:xx, 'hi' => 'Hello @{!m:Ladies|n:You}')

    assert_translation 'Hello Ladies', 'hi', gender: :n, locale: :xx
    assert_translation 'Hello Ladies', 'hi', gender: :f, locale: :xx
    assert_translation 'Hello ', 'hi', gender: :m, locale: :xx
    assert_translation 'Hello Ladies', 'hi', locale: :xx
    store_translations(:xx, 'hi' => 'Hello @{!n:Ladies|m,f:You}')

    assert_translation 'Hello ', 'hi', locale: :xx, inflector_raises: false
  end

  def test_backend_inflector_translate_works_with_tokens_separated_by_commas_and_negative_tokens
    store_translations(:xx, 'hi' => 'Dear @{!f,!m:Someone|m:Sir}!')

    assert_translation 'Dear Someone!', 'hi', gender: :m, locale: :xx
    assert_translation 'Dear Someone!', 'hi', gender: :n, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{!f,!m,n:Someone|m:Sir}!')

    assert_translation 'Dear Someone!', 'hi', gender: :m, locale: :xx
    assert_translation 'Dear Someone!', 'hi', gender: :n, locale: :xx
    store_translations(:xx, 'hi' => 'Dear @{!f,n:Someone|m:Sir|f:Lady}!')

    assert_translation 'Dear Someone!', 'hi', gender: :m, locale: :xx
    assert_translation 'Dear Lady!', 'hi', gender: :f, locale: :xx
    assert_translation 'Dear Someone!', 'hi', locale: :xx
  end

  def test_backend_inflector_translate_works_with_aliased_patterns
    store_translations(:xx, 'hi' => 'Dear @{masculine:Sir|feminine:Lady|n:You|All}!')

    assert_translation 'Dear Sir!', 'hi', gender: :m, locale: :xx, inflector_aliased_patterns: true
    assert_translation 'Dear Sir!', 'hi', gender: :masculine, locale: :xx, inflector_aliased_patterns: true
    assert_translation 'Dear Lady!', 'hi', gender: :f, locale: :xx, inflector_aliased_patterns: true
    assert_translation 'Dear Lady!', 'hi', gender: :feminine, locale: :xx, inflector_aliased_patterns: true
    assert_translation 'Dear All!', 'hi', gender: :s, locale: :xx, inflector_aliased_patterns: true
    assert_translation 'Dear You!', 'hi', locale: :xx, inflector_aliased_patterns: true
    I18n.inflector.options.aliased_patterns = true

    assert_translation 'Dear Sir!', 'hi', gender: :masculine, locale: :xx
  end

  def test_backend_inflector_translate_works_with_method_and_proc_object_given_as_inflection_options
    def femme
      kind, locale = yield
      (locale == :xx && kind == :gender) ? :f : :m
    end

    def excluded
      :s
    end

    def bad_method(_a, _b, _c)
      :m
    end
    procek = method(:femme)
    procun = method(:excluded)
    badmet = method(:bad_method)

    assert_equal 'Dear Lady!',
      I18n.t('welcome',       gender: procek,     locale: :xx, inflector_raises: true)
    assert_equal 'Dear Lady!',
      I18n.t('named_welcome', gender: procek,     locale: :xx, inflector_raises: true)
    assert_equal 'Dear Sir!',
      I18n.t('named_welcome', :@gender => procek,     locale: :xx, inflector_raises: true)
    assert_equal 'Dear You!',
      I18n.t('named_welcome', :@gender => procun,     locale: :xx, inflector_excluded_defaults: true)
    assert_equal 'Dear All!',
      I18n.t('named_welcome', :@gender => procun,     locale: :xx, inflector_excluded_defaults: false)
    assert_raises(ArgumentError) do
      I18n.t('named_welcome', :@gender => badmet, locale: :xx, inflector_raises: true)
    end
    assert_translation 'Dear Sir!', 'named_welcome', :@gender => ->(_k, _l) {
      :m
    }, locale: :xx, inflector_raises: true
    assert_translation 'Dear Lady!', 'welcome', gender: ->(k, _l) {
      (k == :gender) ? :f : :s
    }, locale: :xx, inflector_raises: true
  end

  def test_backend_inflector_translate_recognizes_named_patterns_and_strict_kinds
    store_translations(:xx,
      i18n: {inflections: {:@gender => {s: 'sir', o: 'other', s: 'a', n: 'n',
                                        default: 'n'}}})
    store_translations(:xx, 'hi' => 'Dear @gender{s:Sir|o:Other|n:You|All}!')

    assert_translation 'Dear Sir!', 'hi', gender: :s, locale: :xx
    assert_translation 'Dear Other!', 'hi', gender: :o, locale: :xx
    assert_translation 'Dear You!', 'hi', locale: :xx
    assert_translation 'Dear You!', 'hi', gender: '', locale: :xx
    assert_translation 'Dear You!', 'hi', gender: :unknown, locale: :xx
    assert_translation 'Dear You!', 'hi', :@gender => :unknown, locale: :xx
  end

  def test_backend_inflector_translate_prioritizes_style_kinds_in_options_for_named_patterns
    store_translations(:xx,
      i18n: {inflections: {:@gender => {s: 'sir', o: 'other', s: 'a', n: 'n',
                                        default: 'n'}}})
    store_translations(:xx, 'hi' => 'Dear @gender{s:Sir|o:Other|n:You|All}!')

    assert_translation 'Dear Sir!', 'hi', gender: :s, locale: :xx
    assert_translation 'Dear You!', 'hi', gender: :s, :@gender => :unknown, locale: :xx
    assert_translation 'Dear You!', 'hi', gender: :s, :@gender => nil, locale: :xx
    assert_translation 'Dear Sir!', 'hi', gender: :s, :@gender => :s, locale: :xx
  end

  def test_backend_inflector_translate_is_immune_to_reserved_or_bad_content
    store_translations(:xx,
      i18n: {inflections: {:@gender => {s: 'sir', o: 'other', s: 'a', n: 'n',
                                        default: 'n'}}})
    store_translations(:xx, i18n: {inflections: {:@tense => {now: ''}}})
    store_translations(:xx, 'hi' => 'Dear @nonexistant{s:Sir|o:Other|n:You|All}!')

    assert_translation 'Dear All!', 'hi', gender: 'm', locale: :xx
    store_translations(:xx, 'hi' => 'Dear @gender{s:Sir|o:Other|n:You|All}!')

    assert_translation 'Dear You!', 'hi', gender: '@', :@gender => '+', locale: :xx
    assert_translation 'Dear You!', 'hi', gender: '', :@gender => '', locale: :xx
    store_translations(:xx, 'hi' => '@gender+tense{m+now:~|f+past:she was}')

    assert_translation 'male ', 'hi', gender: :m, tense: :now, locale: :xx
    assert_raises I18n::ArgumentError do
      I18n.t('', gender: :s, locale: :xx)
    end
    assert_raises I18n::InvalidInflectionKind do
      store_translations(:xx, 'hop' => '@gen,der{m+now:~|f+past:she was}')
      I18n.t('hop', gender: :s, locale: :xx, inflector_raises: true)
    end
    assert_raises I18n::InvalidInflectionToken do
      I18n.backend.store_translations(:xx, 'hop' => '@{m+now:~|f+past:she was}')
      I18n.t('hop', gender: :s, locale: :xx, inflector_raises: true)
    end
    assert_raises I18n::InvalidInflectionKind do
      store_translations(:xx, 'hi' => 'Dear @uuuuuuuu{s:Sir|o:Other|n:You|All}!')
      I18n.t('hi', gender: 'm', locale: :xx, inflector_raises: true)
    end
    assert_raises I18n::MisplacedInflectionToken do
      store_translations(:xx, 'hi' => 'Dear @tense{s:Sir|o:Other|n:You|All}!')
      I18n.t('hi', gender: 'm', locale: :xx, inflector_raises: true)
    end

    I18n.backend = Backend.new
    assert_raises I18n::BadInflectionKind do
      store_translations(:xx, i18n: {inflections: {:@gender => 'something'}})
    end
    I18n.backend = Backend.new
    store_translations(:xx, 'hi' => '@gender+tense{m+now:~|f+past:she was}')

    assert_translation '', 'hi', gender: :s, :@gender => :s, locale: :xx
    assert_raises I18n::BadInflectionToken do
      store_translations(:xx, i18n: {inflections: {:@gender => {sb: '@', d: '1'}}})
    end
    I18n.backend = Backend.new
    assert_raises I18n::BadInflectionToken do
      store_translations(:xx, i18n: {inflections: {:@gender => {sa: nil, d: '1'}}})
    end
    I18n.backend = Backend.new
    assert_raises I18n::BadInflectionToken do
      store_translations(:xx, i18n: {inflections: {:@gender => {'' => 'a', d: '1'}}})
    end
    ['@', ',', 'cos,cos', '@cos+cos', '+', 'cos!cos', ':', 'cos:', ':cos', 'cos:cos', '!d'].each do |token|
      I18n.backend = Backend.new
      assert_raises I18n::BadInflectionToken do
        store_translations(:xx, i18n: {inflections: {:@gender => {token.to_sym => 'a', d: '1'}}})
      end
    end
    ['@', ',', 'inflector_something', 'default', 'cos,cos', '@cos+cos', '+', 'cos!cos', ':', 'cos:', ':cos', 'cos:cos',
     '!d'].each do |kind|
      I18n.backend = Backend.new
      assert_raises I18n::BadInflectionKind do
        store_translations(:xx, i18n: {inflections: {kind.to_sym => {s: 'a', d: '1'}}})
      end
    end
  end

  def test_inflector_inflected_locales_lists_languages_that_support_inflection
    assert_equal [:xx], I18n.inflector.inflected_locales
    assert_equal [:xx], I18n.inflector.inflected_locales(:gender)
  end

  def test_inflector_strict_inflected_locales_lists_languages_that_support_inflection
    assert_equal [:xx], I18n.inflector.strict.inflected_locales
    assert_equal [:xx], I18n.inflector.strict.inflected_locales(:gender)
    store_translations(:yy, i18n: {inflections: {:@person => {s: 'sir'}}})

    assert_equal [:xx], I18n.inflector.strict.inflected_locales(:gender)
    assert_equal [:yy], I18n.inflector.strict.inflected_locales(:person)
    assert_equal [:xx], I18n.inflector.inflected_locales(:gender)
    assert_equal [:yy], I18n.inflector.inflected_locales(:@person)
    assert_equal(%i(xx yy), I18n.inflector.inflected_locales.sort_by(&:to_s))
    assert_equal(%i(xx yy), I18n.inflector.strict.inflected_locales.sort_by(&:to_s))
    store_translations(:zz, i18n: {inflections: {some: {s: 'sir'}}})

    assert_equal(%i(xx yy zz), I18n.inflector.inflected_locales.sort_by(&:to_s))
    assert_equal(%i(xx yy), I18n.inflector.strict.inflected_locales.sort_by(&:to_s))
    assert_empty I18n.inflector.inflected_locales(:@some)
    assert_equal [:zz], I18n.inflector.inflected_locales(:some)
  end

  def test_inflector_inflected_locale_tests_if_the_given_locale_supports_inflection
    assert I18n.inflector.inflected_locale?(:xx)
    I18n.locale = :xx

    assert_predicate I18n.inflector, :inflected_locale?
  end

  def test_inflector_strict_inflected_locale_tests_if_the_given_locale_supports_inflection
    assert I18n.inflector.strict.inflected_locale?(:xx)
    I18n.locale = :xx

    assert_predicate I18n.inflector.strict, :inflected_locale?
  end

  def test_inflector_new_database_creates_a_database_with_inflections
    assert_kind_of I18n::Inflector::InflectionData, I18n.inflector.new_database(:yy)
    assert I18n.inflector.inflected_locale?(:yy)
    refute I18n.inflector.inflected_locale?(:yyyyy)
  end

  def test_inflector_add_database_adds_existing_database_with_inflections
    db = I18n::Inflector::InflectionData.new(:zz)

    assert_kind_of I18n::Inflector::InflectionData, I18n.inflector.add_database(db)
    assert I18n.inflector.inflected_locale?(:zz)
    refute I18n.inflector.inflected_locale?(:zzzzzz)
  end

  def test_inflector_delete_database_deletes_existing_inflections_database
    I18n.inflector.new_database(:vv)

    assert I18n.inflector.inflected_locale?(:vv)
    assert_kind_of NilClass, I18n.inflector.delete_database(:vv)
    refute I18n.inflector.inflected_locale?(:vv)
  end

  def test_inflector_locale_supported_checks_if_a_language_supports_inflection
    assert I18n.inflector.locale_supported?(:xx)
    refute I18n.inflector.locale_supported?(:pl)
    refute I18n.inflector.locale_supported?(nil)
    refute I18n.inflector.locale_supported?('')
    I18n.locale = :xx

    assert_predicate I18n.inflector, :locale_supported?
    I18n.locale = :pl

    refute_predicate I18n.inflector, :locale_supported?
    I18n.locale = nil

    refute_predicate I18n.inflector, :locale_supported?
    I18n.locale = ''

    refute_predicate I18n.inflector, :locale_supported?
  end

  def test_inflector_strict_locale_supported_checks_if_a_language_supports_inflection
    assert I18n.inflector.strict.locale_supported?(:xx)
    refute I18n.inflector.strict.locale_supported?(:pl)
    refute I18n.inflector.strict.locale_supported?(nil)
    refute I18n.inflector.strict.locale_supported?('')
    I18n.locale = :xx

    assert_predicate I18n.inflector.strict, :locale_supported?
    I18n.locale = :pl

    refute_predicate I18n.inflector.strict, :locale_supported?
    I18n.locale = nil

    refute_predicate I18n.inflector.strict, :locale_supported?
    I18n.locale = ''

    refute_predicate I18n.inflector.strict, :locale_supported?
  end

  def test_inflector_has_token_checks_if_a_token_exists
    assert I18n.inflector.has_token?(:neuter, :gender, :xx)
    assert I18n.inflector.has_token?(:neuter, :xx)
    assert I18n.inflector.has_token?(:f,      :xx)
    assert I18n.inflector.has_token?(:you,    :xx)
    I18n.locale = :xx

    assert I18n.inflector.has_token?(:f)
    assert I18n.inflector.has_token?(:you)
    refute I18n.inflector.has_token?(:faafaffafafa)
  end

  def test_inflector_strict_has_token_checks_if_a_token_exists
    assert I18n.inflector.strict.has_token?(:neuter,  :gender, :xx)
    assert I18n.inflector.strict.has_token?(:f,       :gender, :xx)
    refute I18n.inflector.strict.has_token?(:you,     :gender)
    I18n.locale = :xx

    assert I18n.inflector.strict.has_token?(:f,       :gender)
    refute I18n.inflector.strict.has_token?(:you,     :gender)
    refute I18n.inflector.strict.has_token?(:faafaffafafa)
  end

  def test_inflector_has_kind_checks_if_an_inflection_kind_exists
    assert I18n.inflector.has_kind?(:gender, :xx)
    assert I18n.inflector.has_kind?(:person, :xx)
    refute I18n.inflector.has_kind?(:nonono, :xx)
    refute I18n.inflector.has_kind?(nil,     :xx)
    I18n.locale = :xx

    assert I18n.inflector.has_kind?(:gender)
    assert I18n.inflector.has_kind?(:person)
    refute I18n.inflector.has_kind?(:faafaffafafa)
  end

  def test_inflector_strict_has_kind_checks_if_an_inflection_kind_exists
    assert I18n.inflector.strict.has_kind?(:gender, :xx)
    refute I18n.inflector.strict.has_kind?(:person, :xx)
    refute I18n.inflector.strict.has_kind?(nil,     :xx)
    I18n.locale = :xx

    assert I18n.inflector.strict.has_kind?(:gender)
    refute I18n.inflector.strict.has_kind?(nil)
    refute I18n.inflector.strict.has_kind?(:faafaffa)
  end

  def test_inflector_kind_checks_what_is_the_inflection_kind_of_the_given_token
    assert_equal :gender, I18n.inflector.kind(:neuter,  :xx)
    assert_equal :gender, I18n.inflector.kind(:f,       :xx)
    assert_equal :person, I18n.inflector.kind(:you,     :xx)
    assert_nil I18n.inflector.kind(nil,      :xx)
    assert_nil I18n.inflector.kind(nil,      nil)
    assert_nil I18n.inflector.kind(:nononono, :xx)
    I18n.locale = :xx

    assert_equal :gender, I18n.inflector.kind(:neuter)
    assert_equal :gender, I18n.inflector.kind(:f)
    assert_equal :person, I18n.inflector.kind(:you)
    assert_nil I18n.inflector.kind(nil)
    assert_nil I18n.inflector.kind(:faafaffa)
  end

  def test_inflector_strict_kind_checks_what_is_the_inflection_kind_of_the_given_token
    assert_equal :gender, I18n.inflector.strict.kind(:neuter,  :gender,  :xx)
    assert_equal :gender, I18n.inflector.strict.kind(:f,       :gender,  :xx)
    assert_nil I18n.inflector.strict.kind(:f,           :nontrue, :xx)
    assert_nil I18n.inflector.strict.kind(:f,           nil,      :xx)
    assert_nil I18n.inflector.strict.kind(nil,          :gender,  :xx)
    assert_nil I18n.inflector.strict.kind(nil,          nil,      :xx)
    assert_nil I18n.inflector.strict.kind(:faafaffafafa, nil,     :xx)
    assert_nil I18n.inflector.strict.kind(:nil, :faafafa, :xx)
    I18n.locale = :xx

    assert_equal :gender, I18n.inflector.strict.kind(:neuter,  :gender)
    assert_equal :gender, I18n.inflector.strict.kind(:f,       :gender)
    assert_nil I18n.inflector.strict.kind(:f,       :nontrue)
    assert_nil I18n.inflector.strict.kind(nil,      :gender)
    assert_nil I18n.inflector.strict.kind(nil,      nil)
    assert_nil I18n.inflector.strict.kind(:faafaffa)
  end

  def test_inflector_true_token_gets_true_token_for_the_given_token_name
    assert_equal :n,  I18n.inflector.true_token(:neuter, :xx)
    assert_equal :f,  I18n.inflector.true_token(:f, :xx)
    I18n.locale = :xx

    assert_equal :n,  I18n.inflector.true_token(:neuter)
    assert_equal :f,  I18n.inflector.true_token(:f)
    assert_equal :f,  I18n.inflector.true_token(:f, :xx)
    assert_nil I18n.inflector.true_token(:f, :person, :xx)
    assert_nil I18n.inflector.true_token(:f, :nokind, :xx)
    assert_nil I18n.inflector.true_token(:faafaffa)
  end

  def test_inflector_strict_true_token_gets_true_token_for_the_given_token_name
    assert_equal :n,  I18n.inflector.strict.true_token(:neuter,  :gender,  :xx)
    assert_equal :f,  I18n.inflector.strict.true_token(:f,       :gender,  :xx)
    I18n.locale = :xx

    assert_equal :n,  I18n.inflector.strict.true_token(:neuter,  :gender)
    assert_equal :f,  I18n.inflector.strict.true_token(:f,       :gender)
    assert_equal :f,  I18n.inflector.strict.true_token(:f,       :gender, :xx)
    assert_nil I18n.inflector.strict.true_token(:f,       :person,  :xx)
    assert_nil I18n.inflector.strict.true_token(:f,       nil,      :xx)
    assert_nil I18n.inflector.strict.true_token(:faafaffa)
  end

  def test_inflector_has_true_token_tests_if_true_token_exists_for_the_given_token_name
    refute I18n.inflector.has_true_token?(:neuter, :xx)
    assert I18n.inflector.has_true_token?(:f,      :xx)
    I18n.locale = :xx

    refute I18n.inflector.has_true_token?(:neuter)
    assert I18n.inflector.has_true_token?(:f)
    assert I18n.inflector.has_true_token?(:f,      :xx)
    refute I18n.inflector.has_true_token?(:f,      :person, :xx)
    refute I18n.inflector.has_true_token?(:f,      :nokind, :xx)
    refute I18n.inflector.has_true_token?(:faafaff)
  end

  def test_inflector_strict_markers_tests_if_named_markers_in_kinds_are_working_for_api_calls
    tt = {m: 'male', f: 'female', n: 'neuter', s: 'strange'}
    t = tt.merge({masculine: 'male', feminine: 'female', neuter: 'neuter', neutral: 'neuter'})
    al = {masculine: :m, feminine: :f, neuter: :n, neutral: :n}
    tr = tt.merge(al)

    assert_equal [:xx],   I18n.inflector.inflected_locales(:@gender)
    assert_equal t,       I18n.inflector.tokens(:@gender, :xx)
    assert_equal tt,      I18n.inflector.true_tokens(:@gender, :xx)
    assert_equal tr,      I18n.inflector.raw_tokens(:@gender, :xx)
    assert_equal :n,      I18n.inflector.default_token(:@gender, :xx)
    assert_equal al,      I18n.inflector.aliases(:@gender, :xx)
    assert I18n.inflector.has_kind?(:@gender, :xx)
    assert I18n.inflector.has_alias?(:neuter,  :@gender, :xx)
    assert I18n.inflector.has_token?(:n,       :@gender, :xx)
    refute I18n.inflector.has_true_token?(:neuter,  :@gender, :xx)
    assert I18n.inflector.has_true_token?(:n,       :@gender, :xx)
    assert_equal :n, I18n.inflector.true_token(:neuter, :@gender, :xx)
    assert_equal 'neuter', I18n.inflector.token_description(:neuter,  :@gender, :xx)
    assert_equal 'neuter', I18n.inflector.token_description(:n,       :@gender, :xx)
    I18n.locale = :xx

    assert_equal t,       I18n.inflector.tokens(:@gender)
    assert_equal tt,      I18n.inflector.true_tokens(:@gender)
    assert_equal tr,      I18n.inflector.raw_tokens(:@gender)
    assert_equal :n,      I18n.inflector.default_token(:@gender)
    assert_equal al,      I18n.inflector.aliases(:@gender)
    assert I18n.inflector.has_kind?(:@gender)
    assert I18n.inflector.has_alias?(:neuter,  :@gender)
    assert I18n.inflector.has_token?(:n,       :@gender)
    refute I18n.inflector.has_true_token?(:neuter,  :@gender)
    assert I18n.inflector.has_true_token?(:n,       :@gender)
    assert_equal :n, I18n.inflector.true_token(:neuter, :@gender)
    assert_equal 'neuter', I18n.inflector.token_description(:neuter,  :@gender)
    assert_equal 'neuter', I18n.inflector.token_description(:n,       :@gender)
  end

  def test_inflector_strict_has_true_token_tests_if_true_token_exists_for_the_given_token_name
    refute I18n.inflector.strict.has_true_token?(:neuter, :gender,  :xx)
    assert I18n.inflector.strict.has_true_token?(:f,      :gender,  :xx)
    I18n.locale = :xx

    refute I18n.inflector.strict.has_true_token?(:neuter, :gender)
    assert I18n.inflector.strict.has_true_token?(:f,      :gender)
    assert I18n.inflector.strict.has_true_token?(:f,      :gender,  :xx)
    refute I18n.inflector.strict.has_true_token?(:f,      :person,  :xx)
    refute I18n.inflector.strict.has_true_token?(:f,      nil,      :xx)
    refute I18n.inflector.strict.has_true_token?(:faafaff)
  end

  def test_inflector_kinds_lists_inflection_kinds
    refute_nil I18n.inflector.kinds(:xx)
    assert_equal(%i(gender person), I18n.inflector.kinds(:xx).sort_by(&:to_s))
    I18n.locale = :xx

    assert_equal(%i(gender person), I18n.inflector.kinds.sort_by(&:to_s))
  end

  def test_inflector_strict_kinds_lists_inflection_kinds
    refute_nil I18n.inflector.strict.kinds(:xx)
    assert_equal [:gender], I18n.inflector.strict.kinds(:xx)
    I18n.locale = :xx

    assert_equal [:gender], I18n.inflector.strict.kinds
  end

  def test_inflector_tokens_lists_all_inflection_tokens_including_aliases
    h = {m: 'male', f: 'female', n: 'neuter', s: 'strange',
         masculine: 'male', feminine: 'female', neuter: 'neuter',
         neutral: 'neuter'}
    ha = h.merge(i: 'I', you: 'You')

    assert_equal h, I18n.inflector.tokens(:gender, :xx)
    I18n.locale = :xx

    assert_equal h,   I18n.inflector.tokens(:gender)
    assert_equal ha,  I18n.inflector.tokens
  end

  def test_inflector_strict_tokens_lists_all_inflection_tokens_including_aliases
    h = {m: 'male', f: 'female', n: 'neuter', s: 'strange',
         masculine: 'male', feminine: 'female', neuter: 'neuter',
         neutral: 'neuter'}

    assert_equal h, I18n.inflector.strict.tokens(:gender, :xx)
    I18n.locale = :xx

    assert_equal h, I18n.inflector.strict.tokens(:gender)
    assert_empty(I18n.inflector.strict.tokens)
  end

  def test_inflector_true_tokens_lists_true_tokens
    h  = {m: 'male', f: 'female', n: 'neuter', s: 'strange'}
    ha = h.merge(i: 'I', you: 'You')

    assert_equal h, I18n.inflector.true_tokens(:gender, :xx)
    I18n.locale = :xx

    assert_equal h,   I18n.inflector.true_tokens(:gender)
    assert_equal ha,  I18n.inflector.true_tokens
  end

  def test_inflector_strict_true_tokens_lists_true_tokens
    h = {m: 'male', f: 'female', n: 'neuter', s: 'strange'}

    assert_equal h, I18n.inflector.strict.true_tokens(:gender, :xx)
    I18n.locale = :xx

    assert_equal h, I18n.inflector.strict.true_tokens(:gender)
    assert_empty(I18n.inflector.strict.true_tokens)
  end

  def test_inflector_raw_tokens_lists_tokens_in_a_so_called_raw_format
    h = {m: 'male', f: 'female', n: 'neuter', s: 'strange',
         masculine: :m, feminine: :f, neuter: :n,
         neutral: :n}
    ha = h.merge(i: 'I', you: 'You')

    assert_equal h, I18n.inflector.raw_tokens(:gender, :xx)
    I18n.locale = :xx

    assert_equal h,   I18n.inflector.raw_tokens(:gender)
    assert_equal ha,  I18n.inflector.raw_tokens
  end

  def test_inflector_strict_raw_tokens_lists_tokens_in_a_so_called_raw_format
    h = {m: 'male', f: 'female', n: 'neuter', s: 'strange',
         masculine: :m, feminine: :f, neuter: :n,
         neutral: :n}

    assert_equal h, I18n.inflector.strict.raw_tokens(:gender, :xx)
    I18n.locale = :xx

    assert_equal h, I18n.inflector.strict.raw_tokens(:gender)
    assert_empty(I18n.inflector.strict.raw_tokens)
  end

  def test_inflector_default_token_returns_a_default_token_for_a_kind
    assert_equal :n, I18n.inflector.default_token(:gender, :xx)
    I18n.locale = :xx

    assert_equal :n, I18n.inflector.default_token(:gender)
  end

  def test_inflector_strict_default_token_returns_a_default_token_for_a_kind
    assert_equal :n, I18n.inflector.strict.default_token(:gender, :xx)
    I18n.locale = :xx

    assert_equal :n, I18n.inflector.strict.default_token(:gender)
  end

  def test_inflector_aliases_lists_aliases
    a = {masculine: :m, feminine: :f, neuter: :n, neutral: :n}

    assert_equal a, I18n.inflector.aliases(:gender, :xx)
    I18n.locale = :xx

    assert_equal a, I18n.inflector.aliases(:gender)
    assert_equal a, I18n.inflector.aliases
  end

  def test_inflector_strict_aliases_lists_aliases
    a = {masculine: :m, feminine: :f, neuter: :n, neutral: :n}

    assert_equal a, I18n.inflector.strict.aliases(:gender, :xx)
    I18n.locale = :xx

    assert_equal a, I18n.inflector.strict.aliases(:gender)
    assert_empty(I18n.inflector.strict.aliases)
  end

  def test_inflector_token_description_returns_token_s_description
    assert_equal 'male', I18n.inflector.token_description(:m, :xx)
    I18n.locale = :xx

    assert_equal 'male', I18n.inflector.token_description(:m)
    assert_nil I18n.inflector.token_description(:vnonexistent, :xx)
    assert_equal 'neuter',  I18n.inflector.token_description(:neutral, :xx)
  end

  def test_inflector_strict_token_description_returns_token_s_description
    assert_equal 'male',    I18n.inflector.strict.token_description(:m, :gender, :xx)
    I18n.locale = :xx

    assert_equal 'male', I18n.inflector.strict.token_description(:m, :gender)
    assert_nil I18n.inflector.strict.token_description(:bnonexistent, :gender, :xx)
    assert_equal 'neuter', I18n.inflector.strict.token_description(:neutral, :gender, :xx)
  end

  def test_inflector_has_alias_tests_whether_a_token_is_an_alias
    assert I18n.inflector.has_alias?(:neutral, :xx)
    refute I18n.inflector.has_alias?(:you,     :xx)
    assert I18n.inflector.has_alias?(:neutral, :gender, :xx)
    refute I18n.inflector.has_alias?(:you,     :gender, :xx)
    refute I18n.inflector.has_alias?(:neutral, :nokind, :xx)
    I18n.locale = :xx

    assert I18n.inflector.has_alias?(:neutral)
  end

  def test_inflector_strict_has_alias_tests_whether_a_token_is_an_alias
    assert I18n.inflector.strict.has_alias?(:neutral, :gender, :xx)
    refute I18n.inflector.strict.has_alias?(:you,     :person, :xx)
    refute I18n.inflector.strict.has_alias?(:you,     :gender, :xx)
    I18n.locale = :xx

    assert I18n.inflector.strict.has_alias?(:neutral, :gender)
  end
end
