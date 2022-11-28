class Member < ApplicationRecord
  has_many :members_workouts
  has_many :beneficiaries, class_name: "Member", foreign_key: "responsible_id"
  belongs_to :responsible, class_name: "Member", optional: true
  has_many :workouts, through: :members_workouts
  has_many :invoices
  has_many :billing_items
  has_many :coaches, -> { distinct }, through: :workouts

  scope :billable_in_range, ->(range) { joins(:workouts).where(workouts: { start_at: range, reviewed: true }).uniq }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :cel_number, presence: true

  after_create :assign_sponsor_self, if: proc { self.responsible_id.nil? }

  def self.all_billable_within(range)
    Member.all.billable_in_range(range).select { |r| r.billable_in_range?(range) }
  end

  def name
    "#{first_name} #{last_name}"
  end

  def billable_in_range?(range)
    (has_billable_subscription? || has_billable_individual_class_in_range?(range)) && is_not_in_billing_cycle?(range)
  end

  def has_billable_subscription?
    has_subscription? && loyal?
  end

  def has_subscription?
    subscription_price > 0
  end

  def has_billable_individual_class_in_range?(range)
    has_individual? && has_billable_workouts_in_range?(range)
  end

  def has_individual?
    class_price > 0
  end

  def has_billing_items_in_range?(range)
    billing_items.where(reference_date: range).count > 0
  end

  def is_not_in_billing_cycle?(range)
    result = true
    billing_items.each do |item|
      if item.invoice.present? && range.cover?(item.invoice.reference_date) &&
           item.invoice.invoice_type == "billing_cycle" && item.invoice.status != "canceled"
        result = false
        break
      end
    end
    result
  end

  def has_billable_workouts_in_range?(range)
    billable_workouts_in_range(range).count > 0
  end

  def billable_workouts_in_range(range)
    members_workouts.all.billable_within(range)
  end

  def responsible_self?
    (responsible_id == id) || (responsible_id.blank?)
  end

  def whatsapp_link
    "https://wa.me/+55#{cel_number}"
  end

  def workouts_available_in_month(date)
    dates = [*date.beginning_of_month..date.end_of_month]

    mon = self.monday.nil? ? 0 : self.monday
    tue = self.tuesday.nil? ? 0 : self.tuesday
    wed = self.wednesday.nil? ? 0 : self.wednesday
    thu = self.thursday.nil? ? 0 : self.thursday
    fri = self.friday.nil? ? 0 : self.friday
    sat = self.saturday.nil? ? 0 : self.saturday
    sun = self.sunday.nil? ? 0 : self.sunday

    mondays_in_month = dates.count { |d| (d.wday == 1) } # Number of Mondays in month
    tuesdays_in_month = dates.count { |d| (d.wday == 2) } # Number of Tuesday in month
    wednesdays_in_month = dates.count { |d| (d.wday == 3) } # Number of Wednesday in month
    thursdays_in_month = dates.count { |d| (d.wday == 4) } # Number of Thursday in month
    fridays_in_month = dates.count { |d| (d.wday == 5) } # Number of Friday in month
    saturdays_in_month = dates.count { |d| (d.wday == 6) } # Number of Saturdayy in month
    sundays_in_month = dates.count { |d| (d.wday == 0) } # Number of Sunday in month

    available_monday_workouts = mon * mondays_in_month
    available_monday_workouts += tue * tuesdays_in_month
    available_monday_workouts += wed * wednesdays_in_month
    available_monday_workouts += thu * thursdays_in_month
    available_monday_workouts += fri * fridays_in_month
    available_monday_workouts += sat * saturdays_in_month
    available_monday_workouts += sun * sundays_in_month
  end

  ransacker :name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new(
      "LOWER",
      [
        Arel::Nodes::NamedFunction.new(
          "concat_ws",
          [Arel::Nodes::SqlLiteral.new("' '"), parent.table[:first_name], parent.table[:last_name]],
        ),
      ],
    )
  end

  def billable_extra_workouts_count(month)
    workouts_count = billable_workouts_in_range(month.beginning_of_month..month.end_of_month).count
    available_workouts = self.workouts_available_in_month(month.beginning_of_month)
    billable_extra_workouts = workouts_count - available_workouts # (total de aulas) - (aulas no plano)
    billable_extra_workouts = [0, billable_extra_workouts].max
  end

  def replacements_for_discount(billable_extra_workouts_count)
    replacements = self.replacement_classes
    replacements_for_discount = [billable_extra_workouts_count, replacements].min
  end

  private

  def assign_sponsor_self
    self.responsible_id = self.id
    save!
  end
end
