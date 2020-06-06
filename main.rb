load 'NSD.rb'
def use
  @use ||= File.read('gbform.txt')
end

def l
  NSD.formatted_items(use)
end

load 'gen.rb'
def use 
    @use ||= File.read('aleadform.txt')
end
load 'rem.rb'
String.include Remmable


#this is a test
