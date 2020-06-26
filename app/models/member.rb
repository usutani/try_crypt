class Member < ApplicationRecord
  after_initialize :decrypt_columns
  before_save :encrypt_columns

  def decrypt_columns
    return if new_record?

    crypt = message_encryptor
    self.name = crypt.decrypt_and_verify(name)
    self.address = crypt.decrypt_and_verify(address)
  end

  def encrypt_columns
    crypt = message_encryptor
    self.name = crypt.encrypt_and_sign(name)
    self.address = crypt.encrypt_and_sign(address)
  end

  def message_encryptor
    salt = Rails.application.credentials.salt
    key_len = ActiveSupport::MessageEncryptor.key_len
    key = Rails.application.key_generator.generate_key(salt, key_len)
    ActiveSupport::MessageEncryptor.new(key)
  end
end
