class Member < ApplicationRecord
  include ColumnEncryptor

  def crypt_col_names
    %i[name address]
  end
end
