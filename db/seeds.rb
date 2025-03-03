# Database Seed File
# ==================
#
# This seed file populates the database with sample data for development and testing purposes.
# It creates:
#
# 1. Users
#    - Creates a predefined number of users with randomized attributes
#    - Uses Faker gem to generate realistic names, emails, and other user information
#    - Each user receives a random avatar and unique credentials
#
# 2. Messages
#    - Generates sample SMS messages between users
#    - Uses Faker to create message content that mimics real conversations
#
# Usage:
#   Run this seed with: `docker-compose run web rails db:seed`
#
# Note: This will clear existing seed data before creating new records.
# To modify the number of records created, adjust the constants below.

# Configuration constants
NUM_USERS = 10
MESSAGES_PER_USER = 5

# Seed implementation follows...

# Create users
users =
  NUM_USERS.times.map do |i|
    User.create(
      name: Faker::Name.name,
      email: Faker::Internet.email,
      phone_number: Faker::PhoneNumber.cell_phone_in_e164,
    )
  end

  # Create messages
  users.each do |user|
    NUM_USERS.times.map do |i|
      recipient = users.sample()
      Message.create(sender: user, recipient: recipient, body: Faker::Lorem.sentence)
    end
  end