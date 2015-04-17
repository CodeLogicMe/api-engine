require_relative '../spec_helper'

RSpec.describe 'Signing in', type: :feature do
  context 'as an existing client' do
    let!(:client) { create :client, password: 123456 }

    before do
      visit '/'

      within('.sign-in-form') do
        fill_in 'Email', with: client.email
        fill_in 'Password', with: 123456
        click_button 'Sign in'
      end
    end

    it 'should take him to its apps page' do
      expect(page).to have_content 'My Apps'
    end
  end
end
