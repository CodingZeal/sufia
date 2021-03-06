require 'spec_helper'

describe "dashboard/index.html.erb" do

  before do
    @user = mock_model(User, name: "Charles Francis Xavier", user_key: "charles")
    allow(@user).to receive(:title).and_return("Professor, Head")
    allow(@user).to receive(:department).and_return("Xavier’s School for Gifted Youngsters")
    allow(@user).to receive(:telephone).and_return("814.865.8399")
    allow(@user).to receive(:email).and_return("chuck@xsgy.edu")
    allow(@user).to receive(:all_following).and_return(["magneto"])
    allow(@user).to receive(:followers).and_return(["wolverine","storm"])
    allow(controller).to receive(:current_user).and_return(@user)
    assign(:activity, [])
    assign(:notifications, [])
  end

  describe "heading" do

    before do
      render
      @heading = view.content_for(:heading)
    end

    it "should display welcome message and links" do
      expect(@heading).to have_link("Upload", sufia.new_generic_file_path)
      expect(@heading).to have_link("Create Collection", collections.new_collection_path)
      expect(@heading).to have_link("View Files", sufia.dashboard_files_path)
      expect(@heading).to include "My Dashboard"
      expect(@heading).to include "Hello, Charles Francis Xavier"
    end

  end

  describe "sidebar" do

    before do
      render
      @sidebar = view.content_for(:sidebar)
    end

    it "should display information about the user" do
      expect(@sidebar).to include "Charles Francis Xavier"
      expect(@sidebar).to include "Professor, Head"
      expect(@sidebar).to include "Xavier’s School for Gifted Youngsters"
      expect(@sidebar).to include "814.865.8399"
      expect(@sidebar).to include "chuck@xsgy.edu"
    end

    it "should have links to view and edit the user's profile" do
      expect(@sidebar).to include '<a class="btn btn-info" href="' + sufia.profile_path(@user) + '">View Profile</a>'
      expect(@sidebar).to include '<a class="btn btn-info" href="' + sufia.edit_profile_path(@user) + '">Edit Profile</a>'
    end

    it "should display user statistics" do
      expect(@sidebar).to include "Your Statistics"
      expect(@sidebar).to include '<span class="label label-default">1</span>'
      expect(@sidebar).to include '<span class="label label-default">2</span>'
      expect(@sidebar).to include '<span class="label label-default">0</span>'
    end

  end

  describe "main" do

    context "with activities and notifications" do

      before do
        @now = DateTime.now.to_i
        assign(:activity, [
          { action: 'so and so edited their profile', timestamp: @now },
          { action: 'so and so uploaded a file', timestamp: (@now - 360 ) }
        ])
        assign(:notifications, FactoryGirl.create(:user_with_mail).mailbox.inbox)
      end

      it "should include recent activities and notifications" do
        render
        expect(rendered).to include "so and so edited their profile"
        expect(rendered).to include "6 minutes ago"
        expect(rendered).to include "You've got mail"
        expect(rendered).to include "Sample notification"
      end

    end

    context "without activities and notifications" do

      it "should include headings for activities and notifications" do
        render
        expect(rendered).to include "User Activity"
        expect(rendered).to include "User Notifications"
      end

      it "should show no activities or notifications" do
        render
        expect(rendered).to include "User has no notifications"
        expect(rendered).to include "User has no recent activity"
      end

    end

  end

end
