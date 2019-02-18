class PasswordResetToken
  attr_reader :value

  def initialize(_email)
    self.value = SecureRandom.hex(15)
    freeze
  end

  alias to_s value

  private

  attr_writer :value
end
