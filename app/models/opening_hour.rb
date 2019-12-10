# == Schema Information
#
# Table name: opening_hours
#
#  id          :integer          not null, primary key
#  weekday     :string
#  open_at     :time
#  close_at    :time
#  activity_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class OpeningHour < ApplicationRecord
  belongs_to :activity

  validates :weekday, :open_at, :close_at, presence: true
end
