RSpec::Matchers.define :allow_file_size_on_nil_activesupport_file do |size, validator, message|
  match do |model|
    value = double
    allow(value).to(receive(:size).and_raise(Module::DelegationError, "size delegated to attachment, but attachment is nil"))
    allow(value).to(receive(:attached?).and_return(false))

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
