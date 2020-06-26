module ColumnEncryptor
  extend ActiveSupport::Concern

  included do
    after_initialize -> { decrypt_columns(crypt_col_names) }
    before_save -> { encrypt_columns(crypt_col_names) }
  end

  def crypt_col_names
    raise NotImplementedError
  end

  def decrypt_columns(col_names)
    return if new_record?

    crypt = message_encryptor
    col_names.each do |col_name|
      self[col_name] = crypt.decrypt_and_verify(self[col_name])
    end
  end

  def encrypt_columns(col_names)
    crypt = message_encryptor
    col_names.each do |col_name|
      self[col_name] = crypt.encrypt_and_sign(self[col_name])
    end
  end

  def message_encryptor
    salt = Rails.application.credentials.salt
    key_len = ActiveSupport::MessageEncryptor.key_len
    key = Rails.application.key_generator.generate_key(salt, key_len)
    ActiveSupport::MessageEncryptor.new(key)
  end
end
