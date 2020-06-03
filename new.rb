load 'rem.rb'
#NOTE: this project makes extensive use of the Remmable module.  See rem.rb for more info

#provides tools for parsing Next Step Design specbooks
#Author: Sam Tell (stell@samtell.com) - 6/2/2020
#PUBLIC METHODS:
#fromatted_items(s) => takes a string of items and organizes all of the item data into a nested hash
#   - formatted to be easily converted to a JSON using the to_json method from the JSON gem
#attr_readers available for all instance vairables of the modulule singleton
module NSD
    using Remmable::RemString
    
    #matches an item, upto the next item or the end of the string (multiline)
    #groups the header data
    #the last item will not stop until the end of the string, so make sure the string has nothing but items...
    @itemreg = /ITEM NO: (?<num>.+?) (?<cat>.+?) QTY: (?<qty>\d+)\s*(?<line>.*?)(?=(\bITEM|\z))/m
    #matches parenthetical text at the beginning of a string
    @labreg = /(?:\A\()(.+?)(?:\))/
    #matches from a manufacturer title to a space-end-of-line (non-greedy)
    @manreg = /(?:MANUFACTURER: )(.+) /
    #matches from a model title to a space-end-of-line (non-greedy)
    @modreg = /(?:MODEL: )(.+) /
    #matches from a features title to an end-of-paragraph (non-greedy) (multiline)
    @feareg = /(?:FEATURES: )(.+?)\R /m
    #matches an accessories label at the start of a line
    @accreg = /\AACCESSORIES: /m
    #matches from the start of a line to an end-of-paragraph or end-of-string (multiline)
    @parreg = /^.+?(?=\R+ |\z)/m
    #matches a whole string and groups details from an accessory, aka 'other' (multiline)
    @othreg = /^(?:(.+?) - )?(?:(.+?) - )?(?:\((\d+)\) )?(.+)/m
    
    #some keys, to avoid typos
    @num = :item_number
    @cat = :category
    @qty = :quantity
    @lin = :line
    @lab = :label
    @man = :manufacturer
    @mod = :model
    @fea = :specifications
    @oth = :other
    @sub = :subitems
    
    @@ivs = instance_variables
    
    class<<self
        #attr_readers for each instance variable listed above
        #mainly to fascilitate debugging, but available in the api
        @@ivs.each{|v| attr_reader v.to_s.chars[1..-1].join.to_sym}
        
        #processes a whole string of items
        #matches the items, unpacks them, processes their lines including accessories, and properly formats them
        #then recursively removes all returns, e.g. line breaks, page breaks
        #this is the big one
        def formatted_items s
            removeR mul_items(s).map{|i| r1i(i)}
        end
        
        private
        
        #accepts a string of items
        #returns an array of all items as matchdata objects
        #see rem.rb for deatails on the Remmable module
        def matchitems s
            s.remall(@itemreg).rems
        end
        #unpack 1 item-matchdata into a hash
        #'line' is the remainder of the item-match that follows the header
        def unpack1item item
            {@num => item[:num], @cat => item[:cat], @qty => item[:qty], @lin => item[:line]}
        end
        #unpacks all the elements of a given array of item-matchdatas
        def unpackallitems a
            a.map{|i| unpack1item i}
        end
        #matches items of a given string and unpacks them iteratively using the above methods
        def mu_items s
            unpackallitems(matchitems(s))
        end
        
        #proccesses 1 'line'
        #see above, that is what I am calling the rest of the item data after the header
        #TODO refactor
        def m1l l
            #retreives a rem for each of the regexps (see rem.rb for details)
            l.rem(@labreg).rem(@manreg).rem(@modreg).rem(@feareg)
            
            #takes the rems, strips thems, and puts them into a working array
            #rescues nil
            #TODO expand that rescue to make sure no exceptions get hidden in there
            rems =  l.rems.map{|e| e[1].strip rescue nil}
            
            #proccesses the 'remsult' (only the accessories should be left) with m1loth, sets up the default manufacturer, adds it to the working array
            #again, see rem.rb for information on remsult
            rems << m1loth(l.remsult).each{|e| e[@man] ||= rems[1]}
            
            #zips the titles up with the working array
            [@lab, @man, @mod, @fea, @oth].zip(rems).to_h
        end
        
        #processes accessories (aka 'other')
        #TODO refactor
        def m1loth s
            #splits accessories into paragraphs
            #TODO will this mess up if there is a page break in the middle of an accessory?
            #removes accessory title if present (add rem of @accreg)
            #groups the details in a matchdata object (add rem of @othreg and get the remd)
            #hashes the match using pother
            paragraphs(s).map{|e| pother e.rem(@accreg).rem(@othreg).remd}
        end
        
        #splits a string into paragraphs, strips them, and rejects any that do not have any word chars
        #also uses rem; retrives all rems of @parreg and returns the resulting rems array to be formatted
        #not really reusable, as this definition of paragraph is unique to this application
        #TODO can i generalize this into a method that accepts a paragraph delimeter as an arg?
        #I'm thinking now that this probably exists already...
        def paragraphs s
            s.remall(@parreg).rems.map(&:to_s).map(&:strip).reject{|e| !e.match?(/\w/)}
        end
        
        #unpacks an accessory matchdata object into a hash
        #TODO refactor with the word 'unpack,' for cocnistancy
        def pother(m)
            e={}
            e[@qty] = m[3] ? m[3] : "1"
            e[@man] = m[2] ? m[1] : nil
            e[@mod] = m[2] ? m[2] : m[1]
            e[@fea] = m[4]
            e
        end
        
        #match and unpack all items from a string, and process all their 'lines'
        def mul_items s
            mu_items(s).each{|e| e[:line] = m1l(e[:line])}
        end
        
        #reformat 1 item
        #i.e. put all item data into identical entries of an array called sublines
        #base item data will be the 0 entry
        #the rest of the accessories will be in indentically formatted subitem entries
        #base hash will only have info relevent to all the subitems, i.e item number, category, and 'label' (by vendor, by owner, etc.)
        #this is how aq organizes item data behind the scenes.  
        #It's functional, intuitive, and it will make things easier if I want to build some lines of communication to aq
        def r1i i
            l = i[@lin]
            o = {@lab => l[@lab], @num => i[@num], @cat => i[@cat], @sub => [{@qty => i[@qty], @man => l[@man], @mod => l[@mod], @fea => l[@fea]}]}
            l[@oth].each{|s| o[@sub] << s}
            o.reject{|k| k==@oth}
        end
        
        
        #recursively removes all returns from a hash, array, or string, or any combination thereof
        #TODO this is highly reusable, concider moving into utils
        def removeR s
            case s
            when String
                s.remall(/\R/).remsult
            when Hash
                s.map{|k,v| [k, removeR(v)]}.to_h
            when Array
                s.map{|e| removeR e}
            else
                nil
            end
        end
        
    end
end




