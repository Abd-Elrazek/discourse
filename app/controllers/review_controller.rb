class ReviewController < ApplicationController

  requires_login

  def index
    reviewables = Reviewable.list_for(current_user, status: :pending)

    json = reviewables.map do |r|
      serializer = serializer_for(r)
      serializer.new(r, root: nil).as_json
    end

    render_json_dump(review: json)
  end

protected

  def lookup_serializer_for(type)
    "Reviewable#{type}Serializer".constantize
  rescue NameError
    ReviewableSerializer
  end

  def serializer_for(reviewable)
    type = reviewable.reviewable_type
    @serializers ||= {}
    @serializers[type] ||= lookup_serializer_for(type)
  end

end
