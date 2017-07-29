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

require 'rails_helper'

RSpec.describe DiscountCode, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
