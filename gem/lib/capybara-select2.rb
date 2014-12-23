require "capybara-select2/version"
require 'capybara/selectors/tag_selector'
require 'rspec/core'

module Capybara
  module Select2
    def select2(value, options = {})
      raise "Must pass a hash containing 'from' or 'xpath' or 'css'" unless options.is_a?(Hash) and [:from, :xpath, :css].any? { |k| options.has_key? k }
      if options.has_key? :xpath
        select2_container = first(:xpath, options[:xpath])
      elsif options.has_key? :css
        select2_container = first(:css, options[:css])
      else
        select_name = options[:from]
        label = find('label', text: select_name)
        focusser = find(:xpath, "//*[@id = #{label[:for].inspect}]")
        select2_container = focusser.find(:xpath,
          "./ancestor::div[contains(concat(' ', normalize-space(@class), ' '), ' select2-container ')]")
      end

      # Open select2 field
      if select2_container.has_selector?(".select2-choice")
        select2_container.find(".select2-choice").click
      else
        select2_container.find(".select2-choices").click
      end
      
      if options.has_key? :search
        find(:xpath, "//body").find(".select2-with-searchbox input.select2-input").set(value)
        page.execute_script(%|$("input.select2-input:visible").keyup();|)
        drop_container = ".select2-results"
      else
        drop_container = ".select2-drop"
      end

      [value].flatten.each do |value|
        find(:xpath, "//body").find("#{drop_container} li.select2-result-selectable", text: value).click
      end
    end

    def find_select2(options)
      raise "Must pass a hash containing 'from/label' or 'xpath'" unless options.is_a?(Hash) and [:from, :label, :xpath].any? { |k| options.has_key? k }

      if options.has_key? :xpath
        first(:xpath, options[:xpath])
      else
        select_name = options[:from] || options[:label]
        label = find('label', text: select_name)
        focusser = find(:xpath, "//*[@id = #{label[:for].inspect}]")
        focusser.find(:xpath,
          "./ancestor::div[contains(concat(' ', normalize-space(@class), ' '), ' select2-container ')]")
      end
    end

    def open_select2(options)
      trigger_click(find_select2(options).find('.select2-choice, .select2-choices'))
    end

    def close_select2
      trigger_click(find('.select2-drop-mask'))
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::Select2
  config.include Capybara::Selectors::TagSelector
end
