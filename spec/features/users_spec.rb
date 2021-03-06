require 'spec_helper'

feature 'User management' do
	DatabaseCleaner.clean
	scenario 'creates an account' do
		visit root_path
		expect(page).to have_content 'Create an account'
		expect{
			click_link 'Create an account'
			fill_in 'user_name', with: 'mayuko'
			fill_in 'user_email', with: 'example123@example.com'
			fill_in 'user_password', with: 'password123'
			fill_in 'user_password_confirmation', with: 'password123'
			find('input#create_user').click
		}.to change(User, :count).by(1)

		expect(current_path).to eq root_path

		within 'aside' do
			expect(page).to have_content 'mayuko'
		end
	end

	scenario 'changes attributes' do
		visit root_path
		expect(page).to have_content 'Create an account'
		expect{
			click_link 'Create an account'
			fill_in 'user_name', with: 'mayuko'
			fill_in 'user_email', with: 'example123@example.com'
			fill_in 'user_password', with: 'password123'
			fill_in 'user_password_confirmation', with: 'password123'
			find('input#create_user').click
		}.to change(User, :count).by(1)

		click_link 'Edit Profile'
		attach_file('user_avatar', "#{Rails.root}/spec/support/user-female-2.jpg")
		fill_in 'user_name', with: 'mayuyu'
		fill_in 'user_email', with: 'changed123@example.com'
		fill_in 'user_password', with: 'password123'
		fill_in 'user_password_confirmation', with: 'password123'
		find('input#create_user').click

		expect(page).to have_content 'User was successfully updated.'
		expect(page).to have_content 'mayuyu'
	end
end