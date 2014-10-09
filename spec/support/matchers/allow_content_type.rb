RSpec::Matchers.define :allow_file_content_type do |content_type, validator, message|
  match do |model|
    value = double('file', content_type: content_type)
    model.any_instance.stub(:read_attribute_for_validation).and_return(value)
    dummy = model.new
    validator.validate(dummy)
    if message.present?
      dummy.errors[validator.attributes[0]].exclude?(message[:message])
    else
      dummy.errors.empty?
    end
  end
end
