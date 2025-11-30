# frozen_string_literal: true

#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011,2012,2013 by Paweł Wilk
# License::   This program is licensed under the terms of {file:docs/LGPL GNU Lesser General Public License} or {file:docs/COPYING Ruby License}.
#
# This file contains more intuitive version of Set.

module I18n
  module Inflector
    # This class keeps sets of data with hash-like access
    class HSet < Set
      # This method performs a fast check
      # if an element exists in a set using hash-like syntax.
      #
      # @param [Object] k the element to check
      # @return [Boolean] true if element exists in set
      def [](k)
        include?(k)
      end
    end
  end
end
