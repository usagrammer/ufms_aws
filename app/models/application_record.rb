class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def get_error_messages
    return self.errors.messages if self.errors.present?
    return nil
  end
end
