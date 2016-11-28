class Search
  include ActiveModel::Model

  attr_accessor :search_year, :search_month
  validates :search_year, presence: true
  validates :search_month,presence: true
end
