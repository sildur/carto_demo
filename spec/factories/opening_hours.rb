# frozen_string_literal: true

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


FactoryBot.define do
  factory :opening_hour do
    weekday { %w[mo tu we th fr sa su].sample }
    open_at { "#{rand(23)}:#{rand(59)}" }
    close_at { "#{rand(23)}:#{rand(59)}" }
    activity { create(:activity) }
  end
end
