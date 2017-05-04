# This is a very brute patch to enable some dynamic finders
# that are removed as a side effect of globalize
# and that are required to exist by the current solidus gem
# codebase. This should be removed when those dynamic finders
# are removed from solidus.

Globalize::ActiveRecord::ActMacro.module_eval do
  def translates(*attr_names)
    options = attr_names.extract_options!
    # Bypass setup_translates! if the initial bootstrapping is done already.
    setup_translates!(options) unless translates?
    check_columns!(attr_names)

    # Add any extra translatable attributes.
    attr_names = attr_names.map(&:to_sym)
    attr_names -= translated_attribute_names if defined?(translated_attribute_names)

    allow_translation_of_attributes(attr_names) if attr_names.present?
    add_removed_dynamic_finders
  end

  def add_removed_dynamic_finders
    translated_attribute_names.each do |name|
      define_singleton_method "find_by_#{name}" do |value|
        where(name => value).first
      end
      define_singleton_method "find_by_#{name}!" do |value|
        where(name => value).first!
      end
    end
  end
end
