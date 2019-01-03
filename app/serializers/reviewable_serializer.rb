class ReviewableSerializer < ApplicationSerializer
  attributes(
    :id,
    :status,
    :reviewable_type,
    :payload
  )

  # Let's always return a payload to avoid null pointer exceptions
  def payload
    object.payload || {}
  end

  # This is easier than creating an AMS method for each attribute
  def self.target_attributes(*attributes)
    attributes.each do |a|
      attribute(a)

      class_eval <<~GETTER
        def #{a}
          object.target.#{a}
        end
      GETTER
    end
  end

end
