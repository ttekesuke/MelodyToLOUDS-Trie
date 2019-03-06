module midiModule

using MIDI
function getMidiDatas(filePath)

#midiファイル読み込み
println("koko")
midi = MIDI.readMIDIFile(filePath)
#1トラック目取得
notes = getnotes(midi.tracks[1], midi.tpq)
#ピッチ、発音位置、ベロシティー取得
pitchSequence = []
positionSequence = []
velocitySequence = []
unit = 120
beforeNotePosition = 0
beforeNoteDuration = 0
cnt = 0
for note in notes
    cnt += 1
    push!(pitchSequence, Int(note.pitch))
    push!(positionSequence, Int(note.position))
    # ベロシティーは、休符のところは0、音符が伸びて鳴っている箇所はそのノートが持つベロシティーを、duration=120ごとに1要素として配列で取得
    # 休符がある場合
    if note.position - beforeNotePosition - beforeNoteDuration + 1 > 0 && cnt != 1
        #その幅だけ休符を追加
        append!(velocitySequence, repeat([0], div(note.position - beforeNotePosition - beforeNoteDuration + 1, unit)))
    end
    append!(velocitySequence, repeat([Int(note.velocity)], div(Int(note.duration + 1), unit)))
    beforeNotePosition = Int(note.position)
    beforeNoteDuration = Int(note.duration)
end
return pitchSequence, positionSequence, velocitySequence
end

end