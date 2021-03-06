require 'spec_helper'

feature 'Stats management' do
	DatabaseCleaner.clean
	scenario 'see the stats' do
		visit root_path
		click_link 'Create an account'
		fill_in 'user_name', with: 'mayuko'
		fill_in 'user_email', with: 'example123@example.com'
		fill_in 'user_password', with: 'password123'
		fill_in 'user_password_confirmation', with: 'password123'
		find('input#create_user').click

		visit '/words'
		click_link 'New Word'
		fill_in 'word_name', with: 'bite'
		select 'Noun', :from => 'word_word_type'
		fill_in 'word_sentences_attributes_0_content', with: 'Shall we grab a bite?'
		find('input#create_word').click

		visit '/stats'
		str_expected = "Total: #{Word.all.count}"
		expect(page).to have_content str_expected
	end
end