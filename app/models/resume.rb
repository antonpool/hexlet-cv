# frozen_string_literal: true

class Resume < ApplicationRecord
  include AASM
  extend Enumerize
  include ResumeRepository
  has_paper_trail
  is_impressionable counter_cache: true

  enumerize :english_fluency, in: %i[dont_know basic read pass_interview fluent]

  validates :name, presence: true
  validates :english_fluency, presence: true
  validates :github_url, presence: true
  validates :summary, presence: true, length: { minimum: 200 }
  validates :skills_description, presence: true

  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :answer_likes, through: :answers, source: :likes
  has_many :educations, inverse_of: :resume, dependent: :destroy
  has_many :works, inverse_of: :resume, dependent: :destroy
  has_many :comments, inverse_of: :resume, dependent: :destroy

  accepts_nested_attributes_for :educations, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :works, allow_destroy: true

  ransack_alias :popular, :impressions_created_at_or_comments_created_at_or_answers_created_at

  aasm column: :state do
    state :draft, initial: true
    state :published

    event :publish do
      transitions from: %i[draft published], to: :published
    end
  end

  def to_s
    name
  end
end
