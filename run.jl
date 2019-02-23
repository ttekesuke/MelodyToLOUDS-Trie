include("main.jl")
# using ASTInterpreter2

############## midiデータからtrie木を作る ##############
using MIDI


#midiファイル読み込み
midi = MIDI.readMIDIFile("bach.mid")
#1トラック目取得
notes = getnotes(midi.tracks[1], midi.tpq)
#ピッチ取得
pitchSequence = [Int(notes[i].pitch) for i in 1:length(notes)]

# pitchSequence = rand(1:16, 224)
#階差数列に変換
differenceSequence = trie.seqenceToDifferenceSequence(pitchSequence)
#2値の数列に変換
binarySequence = trie.sequenceToBinarySequence(differenceSequence)
#LOUDSのTrie木に変換し、トライのビット配列、ラベル（[そのノードのラベル、そのラベルが出現したシーケンス番号１つ目、２つ目、...]という形式）、
#トライ木の各階層のノードの数、ビット配列の階層を示す区切り位置を取得する
bitAry, label, eachLevelNodesAccumulatedNumber, levelBoundaryBaIdx = @time trie.sequenceToLouds(binarySequence)
#すべての部分列を取得する
subSequences, startSeqIdxes, endSeqIdxes = trie.getAllSubSequences(label, pitchSequence, eachLevelNodesAccumulatedNumber)

#DTW距離を計算する
println(trie.calcDtwDistances(subSequences))

#取得した部分列群を表示
# trie.plotSubsequences(pitchSequence, subSequences, startSeqIdxes, endSeqIdxes)

#PlantUMLファイルを生成　長さによっては出力ファイルが大きくなるので注意
#trie.trieToPuml(bitAry, label)