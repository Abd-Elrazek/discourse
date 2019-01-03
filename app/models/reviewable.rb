require_dependency 'enum'

class Reviewable < ActiveRecord::Base
  validates_presence_of :reviewable_type, :status, :created_by_id
  belongs_to :target, polymorphic: true
  belongs_to :created_by, class_name: 'User'

  def self.statuses
    @statuses ||= Enum.new(
      pending: 0,
      approved: 1,
      rejected: 2,
      ignored: 3,
      deleted: 4
    )
  end

  def self.create_for(obj)
    create(
      reviewable_type: obj.class.name,
      created_by_id: Discourse.system_user.id,
      target: obj
    )
  end

  def self.list_for(user, status: :pending)
    return [] if user.blank?

    filtered = where(status: statuses[status])

    return filtered if user.admin?

    filtered.where(
      '(reviewable_by_moderator AND :staff) OR (reviewable_by_group_id IN (:group_ids))',
      staff: user.staff?,
      group_ids: user.group_users.pluck(:group_id)
    )
  end
end
