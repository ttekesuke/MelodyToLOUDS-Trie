include("main.jl")
# using ASTInterpreter2

############## trie木を作る ##############
# pitchSequence =rand(1:10,50)
pitchSequence = repeat([1,2,3], 6)
differenceSequence = trie.seqenceToDifferenceSequence(pitchSequence)
binarySequence = trie.sequenceToBinarySequence(differenceSequence)
@time trie.sequenceToLouds(binarySequence)

############## midiファイルを読み込んでpitchを取得する ##############
using MIDI
midi = MIDI.readMIDIFile("bach.mid")
notes = getnotes(midi.tracks[1], midi.tpq)
pitchSequence = [Int(notes[i].pitch) for i in 1:length(notes)]

############## DTW距離を計算する ##############
#計測対象の時系列データセット
sequences = [
# Dict("name" => "kinenju", "data" => [60,62,64,64,64,64,62,62,62,60,60,60,60,60,60,60,60,60,65,65,65,65,69,69,67,66,67,67,67,67,67,67,67,67,69,69,69,67,65,65,67,69,67,67,64,62,60,60,60,62,64,64,64,60,57,57,64,64,62,62,62,62,62,62]),
# Dict("name" => "dokomademoikou", "data" => [60,62,64,64,64,60,59,59,60,62,60,60,60,60,60,60,60,60,65,65,65,65,65,65,67,69,67,67,67,67,67,67,67,67,69,69,69,67,65,65,67,69,67,67,67,64,60,60,60,62,64,64,64,60,59,59,60,62,60,60,60,60,60,60]),
# Dict("name" => "hisou", "data" => [60,62,63,63,63,65,62,62,62,63,60,60,60,60,60,59,60,62,63,62,63,65,67,67,67,67,67,67,67,67,67,67,65,67,68,68,68,68,62,62,63,65,67,67,67,67,60,60,60,62,63,63,63,65,62,62,62,63,60,60,60,60,60,60]),
# Dict("name" => "all C", "data" => [60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,]),
]
trie.calcDtwDistances(sequences)
############## メロディを表示する ##############
trie.plotMelody(sequences)