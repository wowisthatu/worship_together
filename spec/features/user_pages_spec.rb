require 'spec_helper'

describe "User Pages" do
    subject { page }

    describe "show users" do
	describe "individually" do
	    let (:user) { FactoryGirl.create(:user) }

	    before { visit user_path(user) }

	    it { should have_content(user.name) }
	    it { should have_content(user.email) }
	    it { should_not have_content(user.password) }
	end

	describe "non-existant", type: :request do
	    before { get user_path(-1) }

	    specify { expect(response).to redirect_to(users_path) }

	    describe "follow redirect" do
		before { visit user_path(-1) }

		it { should have_alert(:danger, text: "Unable") }
	    end
	end

	describe "all" do
	    before do
		25.times { |i| FactoryGirl.create(:user) }
		visit users_path
	    end

	    it { should have_content('List of users') }
	    it { should have_content('25 users') }

	    it "should show all users" do
		User.all.each do |user|
		    should have_selector('li', text: user.name)
		    should have_selector('li', text: user.email)
		end
	    end
	end
    end

    describe "creating user" do
	let (:submit) { 'Create new user' }

	before { visit new_user_path }

	it "hides password text" do
	    should have_field 'user_password', type: 'password'
	end

	describe "with invalid information" do
	    it "does not add the user to the system" do
		expect { click_button submit }.not_to change(User, :count)
	    end

	    it "produces an error message" do
		click_button submit
		should have_alert(:danger)
	    end
	end

	describe "with valid information" do
	    before do
		fill_in 'Username', with: 'John Doe'
		fill_in 'Email', with: 'john.doe@example.com'
		fill_in 'Password', with: 'password'
		fill_in 'Confirmation', with: 'password'
	    end

	    it "allows the user to fill in the fields" do
		click_button submit
	    end

	    it "does add the user to the system" do
		expect { click_button submit }.to change(User, :count).by(1)
	    end

	    describe "produces a welcome message" do
		before { click_button submit }

		it { should have_alert(:success, text: 'Welcome') }
	    end

	    describe "redirects to profile page", type: :request do
		before do
		    post users_path, user: { name: 'John Doe',
					     email: 'john.doe@example.com',
					     password: 'password',
					     password_confirmation: 'password' }
		end

		specify do
		    expect(response).to redirect_to(user_path(assigns(:user)))
		end
	    end
	end
    end

    describe "editing users" do
	let (:user) { FactoryGirl.create(:user) }
	let!(:original_name) { user.name }
	let (:submit) { 'Update user profile' }

	before do
	    login user
	    visit edit_user_path(user)
	end

	it { should have_field('Username', with: user.name) }
	it { should have_field('Email', with: user.email) }
	it { should have_field('Password') }

	describe "with invalid information" do
	    before do
		fill_in 'Username', with: ''
		fill_in 'Email', with: ''
		fill_in 'Password', with: ''
	    end

	    describe "does not change data" do
		before { click_button submit }

		specify { expect(user.reload.name).not_to eq('') }
		specify { expect(user.reload.name).to eq(original_name) }
	    end

	    it "does not add a new user to the system" do
		expect { click_button submit }.not_to change(User, :count)
	    end

	    it "produces an error message" do
		click_button submit
		should have_alert(:danger)
	    end
	end

	describe "non-existant", type: :request do
	    before do
		login user, avoid_capybara: true
		get edit_user_path(-1)
	    end

	    specify { expect(response).to redirect_to(users_path) }

	    describe "follow redirect" do
		before { visit edit_user_path(-1) }

		it { should have_alert(:danger, text: "Unable") }
	    end
	end

	describe "with valid information" do
	    before do
		fill_in 'Username', with: 'New Name'
		fill_in 'Email', with: 'new.name@example.com'
		fill_in 'Password', with: user.password
		fill_in 'Confirmation', with: user.password
	    end

	    describe "changes the data" do
		before { click_button submit }

		specify { expect(user.reload.name).to eq('New Name') }
		specify { expect(user.reload.email).to eq('new.name@example.com') }
	    end

	    describe "redirects back to profile page", type: :request do
		before do
		    login user, avoid_capybara: true
		    patch user_path(user), user: { name: 'New Name',
						   email: 'new.name@example.com',
						   password: user.password,
						   password_confirmation: user.password }
		end

		specify { expect(response).to redirect_to(user_path(user)) }
	    end

	    it "produces an update message" do
		click_button submit
		should have_alert(:success)
	    end

	    it "does not add a new user to the system" do
		expect { click_button submit }.not_to change(User, :count)
	    end
	end
    end

    describe "delete users" do
	let!(:user) { FactoryGirl.create(:user) }
	let (:admin) { FactoryGirl.create(:admin) }

	before do
	    login admin
	    visit users_path
	end

	it { should have_link('delete', href: user_path(user)) }

	describe "redirects properly", type: :request do
	    before do
		login admin, avoid_capybara: true
		delete user_path(user)
	    end

	    specify { expect(response).to redirect_to(users_path) }
	end

	it "produces a delete message" do
	    click_link('delete', match: :first)
	    should have_alert(:success)
	end

	it "removes a user from the system" do
	    expect do
		click_link('delete', match: :first)
	    end.to change(User, :count).by(-1)
	end
    end
end
