
module Schmutils
    def self.noat sym
        sym.to_s.gsub(/\A@/,'').to_sym
    end
    
    module Chain
        class ::Object
            def method_missing(m, *a, &b)
                if (m.to_s[-4..-1] == '_ch_')
                    self.send(:define_singleton_method, m) do |*c, &d|
                        self.send(m.to_s[0..-5].to_sym, *c, &d)
                        self
                    end
                    self.send(m, *a, &b)
                else
                    super
                end
                
            end
        end
        
    end
end

using Schmutils::Chain

'asdfasdf'.define_singleton_method_ch_(:hi){puts 'hi'}.hi
