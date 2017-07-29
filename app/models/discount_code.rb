# == Schema Information
#
# Table name: discount_codes
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  used       :boolean          default(FALSE)
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DiscountCode < ApplicationRecord
end
