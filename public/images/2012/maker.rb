f = File.open("captions.txt", "r")
src = true
theSrc = caption = ""
f.each do |line|
  line = line.gsub(/\n/, "")
  next if line == ""
  if src
    theSrc = line
    src = false
  else
    caption = line
    puts "%a.hide.fancybox-thumb{:rel=>'all', :href=>'/images/2012/#{theSrc}', :title => '#{caption}'}"
    src = true
  end
end 