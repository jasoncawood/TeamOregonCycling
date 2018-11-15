class UsersController < ApplicationController
  class NewUserForm
    include ActiveModel::Model

    attr_accessor :email, :password, :password_confirmation, :first_name,
                  :last_name, :code_of_conduct_accepted, :street_address, :city,
                  :state, :phone_number, :zipcode

    validates :email, :password, :password_confirmation, :first_name,
              :last_name, :code_of_conduct_accepted, :street_address, :city,
              :state, :zipcode, :phone_number,
              presence: true
    validates :password,
              confirmation: true
    validates :code_of_conduct_accepted,
              acceptance: true
    validates :state, inclusion: { in: :address_states }

    def address_states
      ['Alabama', 'Alaska', 'American Samoa', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Guam', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Northern Mariana Islands', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'U.S. Virgin Islands', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming',].freeze
    end
  end

  def new
    render locals: { user: NewUserForm.new }
  end
end
