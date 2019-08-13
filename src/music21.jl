module music21
using PyCall

function generateXml(score)
m = pyimport("music21")
stream = m.stream.Stream()
noteList = []
    for part in score
        note = m.note.Note()
        for pitch in part["p"]
            note = m.note.Note(pitch)
        end
        print(part)
        for duration in part["d"]
            for nestedDuration in duration
                note.duration.type = nestedDuration[4]
                note.duration.appendTuplet(deepcopy(duration.Tuplet(nestedDuration[1],nestedDuration[2],nestedDuration[3])))
            end
        end
        push!(noteList, note)
    end
    stream.append(noteList)
    stream.show()
end






end