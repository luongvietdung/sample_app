class Relationship < ActiveRecord::Base
  belongs_to :follwer, class_name: "User"
  belongs_to :follwed, class_name: "User"
end
