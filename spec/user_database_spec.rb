require "spec_helper"

describe UserDatabase do
  let(:user_database) { UserDatabase.new }

  describe "#insert" do
    it "returns the object if it succeeds" do
      user_as_hash = {:username => "jetaggart", :password => "password"}

      result = user_database.insert(user_as_hash)

      expect(result).to include({:username => "jetaggart", :password => "password"})
    end

    it "gives the user an id" do
      user_as_hash = {:username => "jetaggart", :password => "password"}

      user = user_database.insert(user_as_hash)

      expect(user[:id]).to eq(1)
    end

    it "offsets the id by how many users exist" do
      user_database.insert({:username => "jetaggart", :password => "some password"})
      second_user = user_database.insert(:username => "another_name", :password => "some other password")

      expect(second_user[:id]).to eq(2)
    end

    context "validations" do
      it "requires a username" do
        expect {
          user_database.insert(:password => "password")
        }.to raise_error(ArgumentError, "username required")
      end

      it "requires a password" do
        expect {
          user_database.insert(:username => "username")
        }.to raise_error(ArgumentError, "password required")
      end

      it "shows many validations" do
        expect {
          user_database.insert({})
        }.to raise_error(ArgumentError, "username, password required")
      end
    end
  end

  describe "#find" do
    it "finds the user by the id" do
      user_database.insert(:username => "first", :password => "password")
      user_database.insert(:username => "jetaggart", :password => "password")
      user_database.insert(:username => "last", :password => "password")

      found_user = user_database.find(2)

      expect(found_user).to include(:username => "jetaggart", :password => "password")

      found_user = user_database.find(3)

      expect(found_user).to include(:username => "last", :password => "password")
    end

    it "raises an error if no user can be found" do
      expect {
        user_database.find(1)
      }.to raise_error(UserDatabase::UserNotFoundError)
    end
  end

  describe "#delete" do
    it "deletes at the correct id" do
      user_database.insert(:username => "first", :password => "password")
      user_database.delete(1)

      expect(user_database.all).to eq([])
    end

    it "raises an error the an incorrect id is given" do
      expect {
        user_database.delete(1)
      }.to raise_error(UserDatabase::UserNotFoundError)
    end

    it "successfully adds and deletes multiple users" do
      user_database.insert(:username => "first", :password => "password")
      user_database.insert(:username => "jetaggart", :password => "password")
      user_database.insert(:username => "last", :password => "password")
      user_database.insert(:username => "rob", :password => "pass")
      user_database.delete(2)
      p user_database.all
      user_database.delete(2)
      p user_database.all
      user_database.delete(2)
      p user_database.all
      expect(user_database.all).to eq([{:username => "first", :password => "password", :id => 1}])

    end
  end
end
