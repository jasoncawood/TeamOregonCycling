require 'rails_helper'

RSpec.describe BuildContactForm do
  let(:service_args) {{ reason: 'membership_inquiry' }}

  it 'yields an instance of ContactForm' do
    subject.call do |form|
      expect(form).to be_a(ContactForm)
    end
  end

  context 'when no reason is provided' do
    let(:service_args) {{ reason: nil }}
    it 'sets the contact form reason to "general_inquiry"' do
      subject.call do |form|
        expect(form.reason).to eq 'general_inquiry'
      end
    end
  end

  context 'when an invalid reason is provided' do
    let(:service_args) {{ reason: 'this will never be a valid reason' }}

    it 'sets the contact form reason to "general_inquiry"' do
      subject.call do |form|
        expect(form.reason).to eq 'general_inquiry'
      end
    end
  end

  it 'sets the reson to the reason provided' do
    subject.call do |form|
      expect(form.reason).to eq service_args[:reason]
    end
  end
end
