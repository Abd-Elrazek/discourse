Fabricator(:reviewable) do
  reviewable_by_moderator true
  reviewable_type 'User'
  created_by { Fabricate(:user) }
  target_id { Fabricate(:user).id }
  target_type "User"
  payload {
    { list: [1, 2, 3], name: 'bandersnatch' }
  }
end
