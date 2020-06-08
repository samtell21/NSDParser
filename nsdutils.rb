
module Schmutils
    def self.noat sym
        sym.to_s.gsub(/\A@/,'').to_sym
    end
end
