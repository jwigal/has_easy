module Izzle
  module HasEasy
    module AssocationExtension
      
      def save
        do_save(false)
      end
      
      def save!
        do_save(true)
      end
      
      def []=(name, value)
        proxy_association.owner.set_has_easy_thing(proxy_association.reflection.name, name, value)
      end
      
      def [](name)
        proxy_association.owner.get_has_easy_thing(proxy_association.reflection.name, name)
      end
      
      def valid?
        valid = true
        proxy_association.target.each do |thing|
          thing.model_cache = proxy_association.owner
          unless thing.valid?
            thing.errors.each{ |attr, msg| proxy_association.owner.errors.add(proxy_association.reflection.name, msg) }
            valid = false
          end
        end
        valid
      end
      
      private
      
      def do_save(with_bang)
        success = true
        proxy_association.target.each do |thing|
          next if !thing.changed?
          thing.model_cache = proxy_association.owner
          if with_bang
            thing.save!
          elsif thing.save == false
            # delegate the errors to the proxy owner
            thing.errors.each { |attr,msg| proxy_association.owner.errors.add(proxy_association.reflection.name, msg) }
            success = false
          end
        end
        success
      end
      
    end
  end
end
