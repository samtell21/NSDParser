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
    @spcreg = /(.+?\s+)+?(?=•|\z)/
    #put regexp variables that need an attr_reader here
    
    @@reg = instance_variables
    
    @num = :item_number
    @cat = :category
    @qty = :quantity
    @man = :manufacturer
    @mod = :model
    @spc = :specifications
    @lin = :line
    #put non-regex variables that need an attr_reader here
    
    @@ivs = instance_variables
    
    #put any variables that do not need an attr_reader here
    
    class<<self
        
        #attr_readers for instance variables in @@ivs.  block in each takes off the @ from the symbol and sets up the attr_reader
        @@ivs.each{|v| attr_reader Schmutils.noat(v)}
        
        @@reg.each{|v| FreshRem.remgetter(      ('get_'    +Schmutils.noat(v).to_s).to_sym, Generic.instance_variable_get(v))}
        @@reg.each{|v| FreshRem.allremgetter(   ('getall_' +Schmutils.noat(v).to_s).to_sym, Generic.instance_variable_get(v))}
        
        def matchitems s
            s.remset.getall_pagereg.remsult.getall_itemreg.rems.map(&:to_s)
        end
        
        def unpack1item i
            #TODO rems should only match end of a string on the last rar, and beginning on the first!!
            x = i.remset.get_numreg.get_qtyreg.get_manreg.get_modreg
            y= x.remsult.get_spcreg

            [@num, @cat, @qty, @man, @mod, @spc, @lin].zip(x.rems.map{|e| e ? e[1..2].map(&:strip) : nil}.flatten << y.remd.to_s.strip << y.remsult.strip).to_h
        end
        
        def unpackallitems a
            a.map{|i| unpack1item(i)}
        end
        
        def mu_items s
            unpackallitems(matchitems(s))
        end
        
        

    end
end
