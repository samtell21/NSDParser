 
module Utils
    def self.matches regex, s
        o = [regex.match(s)]
        while m = regex.match($') #'
            o << m
        end
        o
    end
end

module Paragraphs
    refine String do
        def paragraphs
            parreg = /^.+?(?=\R |\z)/m
            ::Utils.matches(parreg, self).map(&:to_s).map(&:strip)
        end
    end
end
