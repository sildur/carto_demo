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

require 'rails_helper'

RSpec.describe OpeningHour, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :weekday }
    it { is_expected.to validate_presence_of :open_at }
    it { is_expected.to validate_presence_of :close_at }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:activity) }
  end
end
