
using Remmable
module Generic
    
    class<<self

        def matchitems s
            s.remset.remall(/^ITEM \#.+?(?=^ITEM \#|\z)/m).rems
        end

    end
end
