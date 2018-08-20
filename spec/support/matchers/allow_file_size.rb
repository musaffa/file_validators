# frozen_string_literal: true

RSpec::Matchers.define :allow_file_size do |size, validator, message|
  match do |model|
    value = double('file', size: size)
    allow_any_instance_of(model).to receive(:read_attribute_for_validation).and_return(value)
    dummy = model.new
    validator.validate(dummy)
    if message.present?
      dummy.errors.full_messages.exclude?(message[:message])
    else
      dummy.errors.empty?
    end
  end
end
