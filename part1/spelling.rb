def get_spelling_correction_list word
  #aspell_output = `echo "#{word}" | /usr/local/bin/aspell -a list`
  aspell_output = `echo "#{word}" | aspell -a list`
  aspell_output = aspell_output.split("\n")[1..-1]
  results = []
  aspell_output.each {|line|
    tokens = line.split(",")
    header = tokens[0].gsub(':','').split(' ')
    tokens[0] = header[4]
    results <<
       [header[1], header[3],
        tokens.collect {|tt| tt.strip}] if header[1]
  }
  begin
    return results[0][2][0..5]
  rescue ; end
  []
end

def get_spelling_correction word
  correction_list = get_spelling_correction_list(word)
  return word if correction_list.length==0
  correction_list[0]
end

#require 'pp'
#pp get_spelling_correction_list("waalkiing")
#pp get_spelling_correction("wallkiing")
