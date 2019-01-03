require 'rails_helper'

describe ReviewController do


  it "requires you to be logged in" do
    get "/review.json"
    expect(response.code).to eq("403")
  end

  context "when logged in" do
    let(:moderator) { Fabricate(:moderator) }

    before do
      sign_in(moderator)
    end

    it "returns empty JSON when nothing to review" do
      get "/review.json"
      expect(response.code).to eq("200")
      json = ::JSON.parse(response.body)
      expect(json['review']).to eq([])
    end

    it "returns JSON with reviewable content" do
      reviewable = Fabricate(:reviewable)

      get "/review.json"
      expect(response.code).to eq("200")
      json = ::JSON.parse(response.body)
      expect(json['review']).to be_present

      json_review = json['review'][0]
      expect(json_review['id']).to eq(reviewable.id)
      expect(json_review['status']).to eq(Reviewable.statuses[:pending])
      expect(json_review['reviewable_type']).to eq('User')
      expect(json_review['payload']['list']).to match_array([1, 2, 3])
      expect(json_review['payload']['name']).to eq('bandersnatch')
    end
  end

end
