class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable, :lockable, :timeoutable

  has_and_belongs_to_many :roles

  def display_name
    email
  end
end
