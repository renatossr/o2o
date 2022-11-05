# frozen_string_literal: true

class BadgeComponent < ViewComponent::Base
  def initialize(text:, color:)
    @text = text
    @color = color
  end
end
