module MxitRails
  module Styles

    # Not sure whether a Constant is the neatest/nicest way of storing these?
    StyleList = {}

    def self.get name
      StyleList[name.to_sym]
    end

    def self.add name, content
      content.strip!
      if content[-1] != ';'
        content += ';'
      end
      StyleList[name.to_sym] = content
    end

    Emoticons =  {
      happy: [':)', ':-)'],
      sad: [':(', ':-('],
      winking: [";)", ";-)"],
      excited: [':D', ':-D'],
      shocked: [':|', ':-|'],
      surprised: [':O', ':-O'],
      tongue_out: [':P', ':-P'],
      embarrassed: [':$', ':-$'],
      cool: ['8-)'],
      heart: ['(H)'],
      flower: ['(F)'],

      # V 3.0. smileys
      male: ['(m)'],
      female: ['(f)'],
      star: ['(*)'],
      chilli: ['(c)'],
      kiss: ['(x)'],
      idea: ['(i)'],
      extremely_angry: [':e', ':-e'],
      censored: [':x', ':-x'],
      grumpy: ['(z)'],
      coffee: ['(U)'],
      mr_green: ['(G)'],

      # V 5.0 smileys
      sick: [':o('],
      wtf: [':{', ':-{'],
      in_love: [':}', ':-}'],
      rolling_eyes: ['8-o', '8o'],
      crying: [':\'('],
      thinking: [':?', ':-?'],
      drooling: [':~', ':-~'],
      sleepy: [':z', ':-z'],
      liar: [':L)'],
      nerdy: ['8-|', '8|'],
      pirate: ['P-)'],
      bored: [':[', ':-['],
      cold: [':<', ':-<'],
      confused: [':,', ':-,'],
      hungry: [':C', ':-C'],
      stressed: [':s', ':-s'],
    }

    def self.add_emoticons source
      output = source
      Emoticons.each do |name, searches|
        searches.each do |search|
          output.gsub! search, "<span class=\"emoticon #{name}\" title=\"#{name} #{search}\">#{search}</span>"
        end
      end
      output
    end

  end
end