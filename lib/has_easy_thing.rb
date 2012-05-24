class HasEasyThing < ActiveRecord::Base
  belongs_to :model, :polymorphic => true
  attr_accessor :model_cache, :definition
  before_validation :get_definition
  validate :validate_type_check, :validate_validate
  
  def get_definition
    self.model_cache = model if model_cache.blank?
    self.definition = model_cache.class.has_easy_configurators[self.context].definitions[self.name] if self.definition.blank?
  end
  
  def validate_type_check
    return unless definition.has_type_check
    self.errors.add(:value, "has_easy type check failed for '#{self.name}'") unless definition.type_check.include?(value.class)
  end
  
  def validate_validate
    return unless definition.has_validate
    success = true
    
    if definition.validate.instance_of?(Array) and definition.validate.include?(value) == false
      success = false
    elsif definition.validate.instance_of?(Symbol)
      success = model_cache.send(definition.validate, value)
    elsif definition.validate.instance_of?(Proc)
      begin
        success = definition.validate.call(value)
      rescue HasEasy::ValidationError
        success = false
      end
    end
    
    if success == false
      self.errors[:base] << "has_easy validation failed for '#{self.name}'"
    elsif success.instance_of?(Array)
      success.each{ |message| self.errors[:base] << message }
    end
  end
end
