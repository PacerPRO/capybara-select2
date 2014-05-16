require "capybara-select2/version"
require 'capybara/selectors/tag_selector'
require 'rspec/core'

def trigger_click(element)
  begin
    element.trigger('click')
  rescue Capybara::NotSupportedByDriverError
    element.click
  end
end

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
        select2_container = first("label", text: select_name).find(:xpath, '..').find(".select2-container")
      end

      single = select2_container.first('.select2-choice')
      multiple = select2_container.first('.select2-choices')

      trigger_click(single) if single

      if options.has_key? :search
        find(:xpath, "//body").find(".select2-with-searchbox input.select2-input").set(value)
        page.execute_script(%|$("input.select2-input:visible").keyup();|)
        drop_container = ".select2-results"
      else
        drop_container = ".select2-drop"
      end

      [value].flatten.each do |value|
        trigger_click(multiple) if multiple
        trigger_click(find(:xpath, "//body").find("#{drop_container} li", text: value))
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
