module music21
using PyCall
function generateXml(score)
    println("nanidesukatte-no")
    m = pyimport("music21")
    s = m.stream.Stream()
    s.repeatAppend(m.note.Note(), 4)
    
    t32h = m.duration.Tuplet(3, 2, "half")
    t54q = m.duration.Tuplet(5, 4, "quarter")
    n1 = m.note.Note()
    n1.duration.type = "half"
    n1.duration.appendTuplet(deepcopy(t32h))
    s.append(n1)
    for i in [1, 2, 3, 4, 5]
        n = m.note.Note(60 + i)
        n.duration.type = "quarter"
        n.duration.appendTuplet(deepcopy(t32h))
        n.duration.appendTuplet(deepcopy(t54q))
        s.append(n)
    end
    
    s[:notes][5][:duration][:tuplets][1][:type] = "start"
    # println("nanisuka", s[:notes][5])
    # println("nanisuka", s[:notes][5][:duration][:tuplets][1][:type])
    s[:notes][6][:duration][:tuplets][2][:type] = "start"
    s[:notes][-1][:duration][:tuplets][1][:type] = "stop"
    s[:notes][-1][:duration][:tuplets][2][:type] = "stop"


    s.repeatAppend(m.note.Note("G4"), 4)
    println(s)
    s.show()

#    println("-1")
#    m = pyimport("music21")
#    stream = m.stream.Stream()
#    noteList = []
#    idx = 0
#    for part in score
#        note = m.note.Note()
#        for elm in part["p"]
#            idx += 1
#            note = m.note.Note(part["p"][idx])
#            # println("0")
#            note.duration.type = part["d"][idx]["type"]
#            for duration in part["d"][idx]["tuplet"]
#                # println("1")
#                # println("2")
#                note.duration.appendTuplet(deepcopy(m.duration.Tuplet(duration[1], duration[2], duration[3])))
#            end
#            stream.append(note)
#        end
#    end
# #    stream.notes[0].duration.tuplets[0].type = 'start'
# #    stream.notes[1].duration.tuplets[1].type = 'start'
# #    stream.notes[-1].duration.tuplets[0].type = 'stop'
# #    stream.notes[-1].duration.tuplets[1].type = 'stop'
#    # stream.append(noteList)
#    stream.show()
end
end