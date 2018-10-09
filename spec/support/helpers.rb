# frozen_string_literal: true

module Helpers
  def fakeio(content = 'file', **options)
    FakeIO.new(content, **options)
  end
end
