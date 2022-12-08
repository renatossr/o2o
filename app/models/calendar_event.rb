class CalendarEvent < ApplicationRecord
  has_one :workout, dependent: :delete
  accepts_nested_attributes_for :workout

  scope :unprocessed, -> { where(processed: false) }
  scope :unreviewed, -> { where(reviewed: false) }

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
    workout.cancelled = true if cancelled?

    # Process Members
    workout.members = extract_members(processed_title.first) unless processed_title.first.blank?

    # Process replacement
    workout.with_replacement = true if replacement?

    # Process gympass
    workout.gympass = true if gympass?

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
    events = CalendarEvent.all.unprocessed.unreviewed
    events.each { |event| event.process_event }
  end

  def self.reprocess_unreviewed
    events = CalendarEvent.all.unreviewed
    events.update_all(processed: false)
    self.process_all
  end

  def processed_title
    process_title(title) #(1st) Members, (2nd) Coach, (3rd) Status
  end

  def cancelled?
    status = title

    return false if status.blank?
    return true if status.downcase.include?("cancelado")
    status.split(/\W+/).each { |word| return true if generate_score("cancelado", word) >= 0.75 }
    return false
  end

  def replacement?
    status = title

    return false if status.blank?
    return true if status.downcase.include?("reposição")
    status.split(/\W+/).each { |word| return true if generate_score("reposição", word) >= 0.75 }
    return false
  end

  def gympass?
    status = title

    return false if status.blank?
    return true if status.downcase.include?("gymp")
    status.split(/\W+/).each { |word| return true if generate_score("gymp", word) >= 0.75 }
    return false
  end

  def color
    color_hash = { 1 => "#7986cb", 2 => "#33b679", 3 => "#8e24aa", 4 => "#e67c73", 5 => "#f6c026", 6 => "#f5511f", 7 => "#039be5", 8 => "#616161", 9 => "#3f51b5", 10 => "#0b8043", 11 => "#d60000" }
    color_id.nil? ? "#039be5" : color_hash[color_id]
  end

  def process_title(title)
    title.split(/\s*-\s*/)
  end

  def extract_coach(coach_name)
    coach_distances = []

    first_name = coach_name.split(/\s* \s*/).first.downcase
    last_name = coach_name.split(/\s* \s*/).last.downcase

    coaches = Coach.where("lower(first_name) % ? and lower(last_name) % ?", Coach.sanitize_sql_like(first_name), Coach.sanitize_sql_like(last_name))
    coaches = Coach.where("lower(first_name) % ? or lower(last_name) % ?", Coach.sanitize_sql_like(first_name), Coach.sanitize_sql_like(last_name)) if coaches.blank?
    coaches = Coach.all if coaches.blank?

    if coaches.length > 1
      coaches.each do |coach|
        score = generate_total_score(coach, coach_name)
        coach_distances.push(coach: coach.id, score: score)
      end
      coach_distances.sort_by! { |k| k[:score] }
      Coach.find(coach_distances.first[:coach]) if coach_distances.first[:score] >= 1
    else
      coaches.first
    end
  end

  def extract_members(member_names)
    member_results = []

    names = member_names.split(%r{\s*[,\/]\s*|\s+[e]\s+})

    names.each do |name|
      member_distances = []

      first_name = name.split(/\s* \s*/).first.downcase
      last_name = name.split(/\s* \s*/).last.downcase

      #members = Member.where("lower(first_name) % ? and lower(last_name) % ?", Member.sanitize_sql_like(first_name), Member.sanitize_sql_like(last_name))
      #members = Member.where("lower(first_name) % ? or lower(last_name) % ?", Member.sanitize_sql_like(first_name), Member.sanitize_sql_like(last_name)) if members.blank?
      members =
        Member.where("SIMILARITY(CONCAT(first_name, ' ', last_name), ?) > 0.3", name).order(Member.sanitize_sql_for_order([Arel.sql("SIMILARITY(CONCAT(first_name, ' ', last_name), ?) DESC"), name]))
      members = Member.all if members.blank?

      if members.length > 1
        members.each do |member|
          score = generate_total_score(member, name)
          member_distances.push(member: member.id, score: score)
        end

        member_distances.sort_by! { |k| k[:score] }
        member_results.push(Member.find(member_distances.first[:member])) if member_distances.first[:score] >= 0.75
      else
        member_results.push(members.first)
      end
    end
    member_results
  end

  def generate_total_score(model, name)
    first_name = name.split(/\s* \s*/).first.downcase
    last_name = name.split(/\s* \s*/).last.downcase

    # Testa o primeiro nome
    score_first = generate_score(model.first_name, first_name) * 0.45

    # Testa o sobrenome contra o sobrenome e primeiro nome
    score_last = [generate_score(model.last_name, last_name), generate_score(model.last_name, first_name)].minmax.length() * 0.35

    # Testa o nome inteiro
    score_full = generate_score(model.name, name) * 0.2

    # Agrega os scores
    score = score_first + score_last + score_full
    score
  end

  def generate_score(string_a, string_b)
    # dl = DamerauLevenshtein
    # distance = dl.distance(string_a.downcase, string_b.downcase)
    # largest_size = [string_a, string_b].max.length
    # distance = largest_size if distance > 2
    # score = (distance.to_f / largest_size)

    jw = JaroWinkler
    score = jw.distance(string_a.downcase, string_b.downcase)
    score = 0 if score < 0.6
    score
  end
end
