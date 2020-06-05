def use 
    @use ||= File.read('aleadform.txt')
end
load 'rem.rb'
String.include Remmable