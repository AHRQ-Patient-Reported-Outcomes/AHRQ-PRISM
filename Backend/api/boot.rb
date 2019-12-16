# frozen_string_literal: true

$:.unshift File.expand_path(File.dirname(__FILE__))

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

ENV['ROOT_PATH'] = File.expand_path(File.dirname(__FILE__)).to_s

require 'config/environment'
require 'active_support/core_ext/hash'
require 'app/server'
