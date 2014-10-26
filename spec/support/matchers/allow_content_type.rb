RSpec::Matchers.define :allow_file_content_type do |content_type, validator, message|
  match do |model|
    value = double('file', path: '')
    model.any_instance.stub(:read_attribute_for_validation).and_return(value)
    validator.stub(:detect_content_type).and_return(content_type)
    dummy = model.new
    validator.validate(dummy)
    if message.present?
      dummy.errors.full_messages.exclude?(message[:message])
    else
      dummy.errors.empty?
    end
  end
end
