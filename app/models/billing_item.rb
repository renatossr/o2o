class BillingItem < ApplicationRecord
  belongs_to :invoice, optional: true
  belongs_to :member
  belongs_to :payer, class_name: "Member", foreign_key: :payable_by

  scope :all_draft, -> { where(status: "draft") }
end
