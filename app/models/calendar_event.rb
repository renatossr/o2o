class CalendarEvent < ApplicationRecord
  has_one :workout, dependent: :delete
  accepts_nested_attributes_for :workout

  scope :all_unprocessed, -> { where(processed: false) }
  scope :all_unreviewed, -> { where(reviewed: false) }

  after_save :process_event, if: proc { !self.processed? }
  after_save :set_workout_reviewed, if: proc { self.reviewed? }

  def process_event
    workout = self.workout
    workout = Workout.new if workout.nil?

    workout.calendar_event_id = self.id
    workout.start_at = self.start_at
    workout.end_at = self.end_at
    workout.location = self.location

    # Set cancelled status
    workout.status = "cancelled" if cancelled?

    # Process Members
    workout.members = extract_members(processed_title.first) unless processed_title.first.blank?

    # Process replacement
    workout.with_replacement = true if replacement?

    # Process Coach
    workout.coach = extract_coach(processed_title.second) unless processed_title.second.blank?
    workout.save!

    self.processed = true
    self.save!
  end

  def set_workout_reviewed
    workout = self.workout
    workout.mark_reviewed
  end

  def set_workout_with_replacement
    workout = self.workout
    workout.mark_replacement
  end

  def self.process_all
    events = CalendarEvent.all_unprocessed
    events.each { |event| event.process_event }
  end

  def processed_title
    process_title(title) #(1st) Members, (2nd) Coach, (3rd) Status
  end

  def cancelled?
    status = processed_title.third

    return false if status.blank?
    return true if status.downcase.include?("cancelado")
    status.split(/\W+/).each { |word| return true if generate_score("cancelado", word) <= 0.25 }
    return false
  end

  def replacement?
    status = processed_title.third

    return false if status.blank?
    return true if status.downcase.include?("reposição")
    status.split(/\W+/).each { |word| return true if generate_score("reposição", word) <= 0.25 }
    return false
  end

  def color
    color_hash = {
      1 => "#7986cb",
      2 => "#33b679",
      3 => "#8e24aa",
      4 => "#e67c73",
      5 => "#f6c026",
      6 => "#f5511f",
      7 => "#039be5",
      8 => "#616161",
      9 => "#3f51b5",
      10 => "#0b8043",
      11 => "#d60000",
    }
    color_id.nil? ? "#039be5" : color_hash[color_id]
  end

  private

  def process_title(title)
    title.split(/\s*-\s*/)
  end

  def extract_coach(coach_name)
    coach_distances = []

    first_name = coach_name.split(/\s* \s*/).first.downcase
    last_name = coach_name.split(/\s* \s*/).last.downcase

    coaches =
      Coach.where(
        "lower(first_name) like ? and lower(last_name) like ?",
        "%" + Coach.sanitize_sql_like(first_name) + "%",
        "%" + Coach.sanitize_sql_like(last_name) + "%",
      )
    coaches =
      Coach.where(
        "lower(first_name) like ? or lower(last_name) like ?",
        "%" + Coach.sanitize_sql_like(first_name) + "%",
        "%" + Coach.sanitize_sql_like(last_name) + "%",
      ) if coaches.blank?
    coaches = Coach.all if coaches.blank?

    coaches.each do |coach|
      score = generate_total_score(coach, coach_name)
      coach_distances.push(coach: coach.id, score: score)
    end

    coach_distances.sort_by! { |k| k[:score] }
    if coach_distances.length == 1 || (coach_distances.length > 1 && coach_distances.first[:score] < 1)
      Coach.find(coach_distances.first[:coach])
    end
  end

  def extract_members(member_names)
    member_results = []

    names = member_names.split(/\s*,\s*/)

    names.each do |name|
      member_distances = []

      first_name = name.split(/\s* \s*/).first.downcase
      last_name = name.split(/\s* \s*/).last.downcase

      members =
        Member.where(
          "lower(first_name) like ? and lower(last_name) like ?",
          "%" + Member.sanitize_sql_like(first_name) + "%",
          "%" + Member.sanitize_sql_like(last_name) + "%",
        )
      members =
        Member.where(
          "lower(first_name) like ? or lower(last_name) like ?",
          "%" + Member.sanitize_sql_like(first_name) + "%",
          "%" + Member.sanitize_sql_like(last_name) + "%",
        ) if members.blank?
      members = Member.all if members.blank?

      members.each do |member|
        score = generate_total_score(member, name)
        member_distances.push(member: member.id, score: score)
      end

      member_distances.sort_by! { |k| k[:score] }
      if member_distances.length == 1 || (member_distances.length > 1 && member_distances.first[:score] < 1)
        member_results.push(Member.find(member_distances.first[:member]))
      end
    end
    member_results
  end

  def generate_total_score(model, name)
    first_name = name.split(/\s* \s*/).first.downcase
    last_name = name.split(/\s* \s*/).last.downcase

    # Testa o primeiro nome
    score_first = generate_score(model.first_name, first_name) * 0.6

    # Testa o sobrenome contra o sobrenome e primeiro nome
    score_last =
      [generate_score(model.last_name, last_name), generate_score(model.last_name, first_name)].minmax.length() * 0.3

    # Testa o nome inteiro
    score_full = generate_score(model.name, name) * 0.1

    # Agrega os scores
    score = score_first + score_last + score_full
  end

  def generate_score(string_a, string_b)
    dl = DamerauLevenshtein
    distance = dl.distance(string_a.downcase, string_b.downcase)
    largest_size = [string_a, string_b].max.length
    score = (distance.to_f / largest_size)
  end
end
