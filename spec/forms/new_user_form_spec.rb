require 'forms/new_user_form'

RSpec.describe NewUserForm do
  subject {
    described_class.new(valid_attributes)
  }

  let(:valid_attributes) {{
    email: 'nobody@example.com',
    password: 'A g00d p4ssword!',
    password_confirmation: 'A g00d p4ssword!',
    first_name: 'No',
    last_name: 'Body'
  }}

  it 'has a parameter key of new_user' do
    expect(subject.model_name.param_key).to eq 'new_user'
  end

  %i[email password password_confirmation first_name last_name].each do |field|
    it "exposes the #{field} attribute" do
      value = 'some string'
      subject.public_send("#{field}=", value)
      expect(subject.public_send(field)).to eq value
    end
  end

  it 'is valid when all attributes contain valid values' do
    expect(subject).to be_valid
  end

  %i[email password password_confirmation first_name last_name].each do |field|
    it "is invalid if #{field} is blank" do
      subject.public_send("#{field}=", '')
      expect(subject).not_to be_valid
    end
  end

  it 'is invalid if password and password_confirmation do not match' do
    subject.password_confirmation = 'something else'
    expect(subject).not_to be_valid
  end

  it 'allows its errors to be replaces' do
    errors = instance_double('ActiveModel::Errors', :new_errors)
    subject.errors = errors
    expect(subject.errors).to be errors
  end
end
