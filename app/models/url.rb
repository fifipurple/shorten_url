class Url < ActiveRecord::Base
  validates :long_url, presence: true, uniqueness: true,
    :format => { with: URI::regexp(%w(http https)) }
  validates :short_url, presence: true, uniqueness: true
end
