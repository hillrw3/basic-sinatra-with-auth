class UserDatabase
  def initialize
    @users = []
  end

  def insert(user)
    validate!(user, :username, :password)

    user = user.dup
    user[:id] = next_id

    @users.push(user)

    user.dup
  end

  def find(id)
    (@users[offset_id(id)] or raise UserNotFoundError).dup
  end

  def delete(id)
    magic_number = offset_id(id)
    @users.delete_at(offset_id(id)) or raise UserNotFoundError
    @users.each do |user_hash|
      user_hash[:id] > magic_number ? user_hash[:id] -= 1 : user_hash[:id]
    end
  end

  def all
    @users.dup
  end

  class UserNotFoundError < RuntimeError; end

  private

  def validate!(user, *attributes)
    invalid_attributes = attributes.select { |a| !user.has_key?(a) }

    if invalid_attributes.any?
      message = "#{invalid_attributes.join(", ")} required"
      raise ArgumentError, message
    end
  end

  def next_id
    @users.length + 1
  end

  def offset_id(id)
    id - 1
  end
end
