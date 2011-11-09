class Issue #Issue should not map user to user, just exist and have a join
	include DataMapper::Resource

	property :issue_id, Serial
	property :created_at, DateTime

	belongs_to :borrowing
end
