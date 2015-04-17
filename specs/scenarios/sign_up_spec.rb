require_relative '../spec_helper'

RSpec.describe Models::Client do
  context 'creating a client' do
    subject do
      described_class.create \
        email: 'luke@jeditemple.org',
        password: '12345'
    end

    it { expect(subject).to_not be_a_new_record }
    it { expect(subject.email).to eq 'luke@jeditemple.org' }
    it { expect(subject.password_checks?(12345)).to eq true }
  end
end

RSpec.describe 'Sign up', type: :feature do
  context 'as a new client' do
    before do
      visit '/'

      within('.sign-up-form') do
        fill_in 'Email', with: 'me@api.com'
        fill_in 'Password', with: 123456
        click_button 'Create'
      end
    end

    it 'should present its new my apps page' do
      expect(page).to have_content 'My Apps'
    end
  end
end
