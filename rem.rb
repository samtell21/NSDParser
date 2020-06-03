#Welcome to rem.rb
#Author: Sam Tell (stell@samtell.com) - 6/2/2020
#rem stands for "remove and remember"
#use to parse through a string
#make matches (rems) of any regexp-like object, and store the matches within the the string instance for later retreival/manipulation
#also stored within the instance is a substring of self after removal of all matches up to that point

#TERMS:
#rem: a string that has been or will be retreived from 'remsult' and stored into the rems array.  say: "I retreive a rem of a regexp from the remsult of the self string" 
#or "I add a rem of a regexp to the rems array of the self string"
#remsult: the working substring from which rems are retrived; initializes to self
#remd: the last rem that has been retreived
module Remmable
    #Strings within the scope of the Remmable module should be themselves remmable
    #especially important if self was made Remmable by 'using' the Remmable module in its source scope, i.e. outside the scope of this module
    #(see at the bottom; there is another refinement of String to include Remmable, this time in the body proper)
    #(this one is wrapped in an anonomous module, so that the next one is a new refinement instance, and Remmable is included in string after all its methods are defined.) 
    #without this, you could not call Remmable mothods on self within this module...
    #(frankly I'm not sure why the first refinement works inside the module but not outside...  I discovered this by accident...
    #(I need to do more research...  lets add a todo)
    #TODO see above
    using (
        Module.new do
            refine String do
                include ::Remmable
            end
        end
    )
    
    #extends self with the Remmable module
    #use if self was made remmable by using the Remmable::RemString module and you want to pass it outside the using scope but still maintain its remmability
    def remextend
        self.extend(Remmable)
    end
    
    
    #all rems retrived so far in this instance
    def rems
        @rems ||= []
    end
    
    #doesnt work!
    #ignore for now, it's a work in progress
    #will be used along with remset
    def rems_history
        raise "rems_history isn't ready yet"
        @remd_history_full ? @remd_history_full[-1] = rems : [rems]
    end
    
    #string from which rems are remtrieved and removed
    def remsult
        @remsult ||= self
    end
    
    #returns last retrieved rem
    def remd
        rems[-1]
    end
    
    #retreive a new rem from remsult and add it the rems array
    #throw: determines functionality in the case that there is no match
    # true: raise an exception
    # false: adds nil as the new rem; remsult is unchanged
    #TODO better exception handling: maybe replace with some sort of if..else
    #ext: extend self with the Remmable module?
    def getrem(r, throws: false, ext: false)
        remextend if ext
        r = Regexp.new(r)
        r.match(remsult)
        begin
            @remsult = $`+$' #` <-- #repl messes up the highlighting w/o this...
        rescue NoMethodError=>e
            raise 'no match' if throws
        end
        rems << $~
        self
    end
    
    alias retrieverem getrem
    alias addrem getrem
    
    #basically an alias of getrem, but extends self with the Remmable module by default
    def rem(r, throws: false, ext:true)
        getrem(r, throws: throws, ext: ext)
    end
    
    #add a curried remgetter
    #takes a symbol 'name' and a regexp-like object 'r'
    #adds a new method called 'name' to the Remmable module that retreives the rem of 'r'
    #will be available to all Remmable objects
    def remgetter name, r
        Remmable.define_method(name){rem(r)}
        self
    end
    
    #retrieves all available rems of a regexp-like object
    #TODO expand the exception handling so it doesn't hide unexpected exceptions, or replace with an "brake if <...>" statement, or maybe a while loop
    #TODO ext 
    def remall r
        loop{rem(r, throws: true) rescue break}
        self
    end
    
    #ignore; work in progress
    def remset
        raise "remset isn't ready yet"
        @remsult = nil
        @remd = nil
        rems_history
        @rems = nil
        self
    end
    
    #add 'using Remmable' to include Remmable in String for a given scope
    refine String do
        include Remmable
    end


end



