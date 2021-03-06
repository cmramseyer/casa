# CaseContact Model
class CaseContact < ApplicationRecord
  attr_accessor :duration_hours

  belongs_to :creator, class_name: "User"
  belongs_to :casa_case

  CONTACT_TYPES = %w[
    attorney
    bio_parent
    court
    foster_parent
    other_family
    school
    social_worker
    supervisor
    therapist
    youth
  ].freeze
  IN_PERSON = 'in-person'
  TEXT_EMAIL='text/email'
  VIDEO='video'
  VOICE_ONLY='voice-only'
  LETTER='letter'
  CONTACT_MEDIUMS = [IN_PERSON, TEXT_EMAIL, VIDEO, VOICE_ONLY, LETTER].freeze

  validates :contact_types, presence: true
  validates :occurred_at, presence: true
  validate :contact_types_included
  validate :occurred_at_not_in_future
  validate :reimbursement_only_when_miles_driven

  def contact_types_included
    contact_types&.each do |contact_type|
      unless CONTACT_TYPES.include? contact_type
        errors.add(:contact_types, :invalid, message: "must have valid contact types")
      end
    end
  end

  def occurred_at_not_in_future
    return unless occurred_at && occurred_at >= Date.tomorrow

    errors.add(:occurred_at, :invalid, message: "cannot be in the future")
  end

  def reimbursement_only_when_miles_driven
    return if miles_driven&.positive? || !want_driving_reimbursement

    errors[:base] << "Must enter miles driven to receive driving reimbursement."
  end

  def self.occurred_between(start_date, end_date)
    where("occurred_at BETWEEN ? AND ?", start_date, end_date)
  end
end

# == Schema Information
#
# Table name: case_contacts
#
#  id                         :bigint           not null, primary key
#  contact_made               :boolean          default(FALSE)
#  contact_types              :string           is an Array
#  duration_minutes           :integer          not null
#  medium_type                :string
#  miles_driven               :integer
#  occurred_at                :datetime         not null
#  other_type_text            :string
#  want_driving_reimbursement :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  casa_case_id               :bigint           not null
#  creator_id                 :bigint           not null
#
# Indexes
#
#  index_case_contacts_on_casa_case_id   (casa_case_id)
#  index_case_contacts_on_contact_types  (contact_types) USING gin
#  index_case_contacts_on_creator_id     (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (creator_id => users.id)
#
