using PyCall
music21 = pyimport("music21")
stream2 = music21.stream.Stream()
pitch = 61
n3 = music21.note.Note(pitch)
n3.pitch.microtone = -20
stream2.repeatAppend(n3, 4)
stream2.show()