module midiModule

using MIDI
function getMidiDatas(filePath)

#midiファイル読み込み
println("koko")
midi = MIDI.readMIDIFile(filePath)
#1トラック目取得
notes = getnotes(midi.tracks[1], midi.tpq)
#ピッチ取得

pitchSequence = []
positionSequence = []
velocitySequence = []
unit = 120
beforeNotePosition = 0
beforeNoteDuration = 0
for note in notes
    push!(pitchSequence, Int(note.pitch))
    push!(positionSequence, Int(note.position))
    if note.position - beforeNotePosition + beforeNoteDuration + 1 > 0
        append!(velocitySequence, repeat([0], div(note.position - beforeNotePosition + beforeNoteDuration + 1, unit)))
    end
    append!(velocitySequence, repeat([Int(note.velocity)], div(Int(note.duration + 1), unit)))
    beforeNotePosition = Int(note.position)
    beforeNoteDuration = Int(note.duration)
end
return pitchSequence, positionSequence, velocitySequence
end

end