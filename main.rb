load 'new.rb'
def use
  @use ||= File.read('gbform.txt')
end

def l
  NSD.formatted_items(use)
end


#this is a test