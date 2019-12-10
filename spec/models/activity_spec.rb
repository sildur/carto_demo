# == Schema Information
#
# Table name: activities
#
#  id          :integer          not null, primary key
#  name        :string
#  hours_spent :float
#  category    :string
#  location    :string
#  district    :string
#  latitude    :float
#  longitude   :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :hours_spent }
    it { is_expected.to validate_presence_of :category }
    it { is_expected.to validate_presence_of :location }
    it { is_expected.to validate_presence_of :district }
    it { is_expected.to validate_presence_of :latitude }
    it { is_expected.to validate_presence_of :longitude }
  end

  describe 'associations' do
    it { is_expected.to have_many(:opening_hours) }
  end
end
