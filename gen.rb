load 'rem.rb'
load 'nsdutils.rb'
using FreshRem
module Generic
    @itemreg = /ITEM \#.+?(?=ITEM \#|\z)/m
    #TODO needs to be generalized for any date!!!!
    @pagereg = /\f\n.*?May 15, 2020 \n/m
    
    @numreg = /ITEM \#(?<num>.+?) (?<cat>.+)/
    @qtyreg = /Quantity: \w+ \((\d+?)\)/
    @manreg = /Manufacturer: (.*)/
    @modreg = /Model: (.*)/
    
    #put regexp variables that need an attr_reader here
    
    @@reg = instance_variables
    
    #put non-regex variables that need an attr_reader here
    
    @@ivs = instance_variables
    
    #put any variables that do not need an attr_reader here
    
    class<<self
        
        #attr_readers for instance variables in @@ivs.  block in each takes off the @ from the symbol and sets up the attr_reader
        @@ivs.each{|v| attr_reader Schmutils.noat(v)}
        
        @@reg.each{|v| Remmable.remgetter(      ('get_'    +Schmutils.noat(v).to_s).to_sym, self.instance_variable_get(v))}
        @@reg.each{|v| Remmable.allremgetter(   ('getall_' +Schmutils.noat(v).to_s).to_sym, self.instance_variable_get(v))}
        
        def matchitems s
            s.remset.getallrems(@pagereg).remsult.getallrems(@itemreg).rems
        end

    end
end
