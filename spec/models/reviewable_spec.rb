require 'rails_helper'

RSpec.describe Reviewable, type: :model do

  context ".create" do
    let(:admin) { Fabricate(:admin) }
    let(:user) { Fabricate(:user) }

    let(:reviewable) do
      Reviewable.new(
        reviewable_type: 'thing',
        created_by_id: admin.id,
        payload: {
          list: [1, 2, 3],
          name: 'bandersnatch'
        }
      )
    end

    it "can create a reviewable object" do
      expect(reviewable).to be_present
      expect(reviewable.status).to eq(Reviewable.statuses[:pending])
      expect(reviewable.created_by).to eq(admin)

      expect(reviewable.payload).to be_present
      expect(reviewable.payload['name']).to eq('bandersnatch')
      expect(reviewable.payload['list']).to eq([1, 2, 3])
    end

    it "can add a target" do
      reviewable.target = user
      reviewable.save!

      expect(reviewable.target_type).to eq('User')
      expect(reviewable.target_id).to eq(user.id)
      expect(reviewable.target).to eq(user)
    end
  end

  context ".list_for" do
    it "returns an empty list for nil user" do
      expect(Reviewable.list_for(nil)).to eq([])
    end

    context "with a pending item" do
      let(:post) { Fabricate(:post) }
      let(:user) { Fabricate(:user) }

      let(:reviewable) do
        Reviewable.new(
          reviewable_type: 'thing',
          target: post,
          created_by: user
        )
      end

      it "works with the reviewable by moderator flag" do
        reviewable.reviewable_by_moderator = true
        reviewable.save!

        expect(Reviewable.list_for(user, status: :pending)).to be_empty
        user.update_column(:moderator, true)
        expect(Reviewable.list_for(user, status: :pending)).to eq([reviewable])

        # Admins can review everything
        user.update_columns(moderator: false, admin: true)
        expect(Reviewable.list_for(user, status: :pending)).to eq([reviewable])
      end

      it "works with the reviewable by group" do
        group = Fabricate(:group)
        reviewable.reviewable_by_group_id = group.id
        reviewable.save!

        expect(Reviewable.list_for(user, status: :pending)).to be_empty
        gu = GroupUser.create!(group_id: group.id, user_id: user.id)
        expect(Reviewable.list_for(user, status: :pending)).to eq([reviewable])

        # Admins can review everything
        gu.destroy
        user.update_columns(moderator: false, admin: true)
        expect(Reviewable.list_for(user, status: :pending)).to eq([reviewable])
      end
    end

  end

end
