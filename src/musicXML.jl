module musicXML
using EzXML

function generateMusicXML()

# ヘッダー
    doc = XMLDocument()
    root = ElementNode("score-partwise")
    root["version"] = "3.0"
    setroot!(doc, root)

# ノード定義
    partList = ElementNode("part-list")
    scorePart = ElementNode("score-part")
    partName = ElementNode("part-name")
    part = ElementNode("part")
    measure = ElementNode("measure")
    attributes = ElementNode("attributes")
    divisions = ElementNode("divisions")
    time = ElementNode("time")
    beats = ElementNode("beats")
    beatType = ElementNode("beat-type")
    clef = ElementNode("clef")
    sign = ElementNode("sign")
    line = ElementNode("line")
    note = ElementNode("note")
# タイトル
    addelement!(root, "movement-title", "trieMusics")
# パートリスト
    link!(root, partList)
    partName.content = "piano"
    link!(partList, scorePart)
    scorePart["id"] = "piano"
    prettyprint(doc)
    link!(scorePart, partName)
    link!(partName, TextNode("piano"))
    link!(root, part)
    part["id"] = "piano"

# パート開始
    link!(part, measure)
# 小節開始
    measure["number"] = "1"
    link!(measure, attributes)
# 属性開始
    link!(attributes, divisions)
    link!(divisions, TextNode("10080"))
    link!(attributes, time)
    link!(time, beats)
    link!(beats, TextNode("4"))
    link!(time, beatType)
    link!(beatType, TextNode("4"))
    link!(attributes, clef)
    link!(clef, sign)
    link!(sign, TextNode("G"))
    link!(clef, line)
    link!(line, TextNode("2"))

# 音符開始
    targetNote = makeNote("C")
    link!(measure, targetNote)
    
    for pitch in ["D", "E", "F"]
        nextNote = makeNote(pitch)
        println("nandesyo", nextNote)
        linknext!(targetNote, nextNote)
        targetNote = nextNote
    end

    prettyprint(doc)
    write("result.xml", doc)

end

function makeNote(pitch)
    noteNode =  ElementNode("note")
    pitchNode = ElementNode("pitch")
    stepNode = ElementNode("step")
    octaveNode = ElementNode("octave")
    durationNode = ElementNode("duration")
    typeNode = ElementNode("type")
    link!(noteNode, pitchNode)
    link!(pitchNode, stepNode)
    link!(stepNode, TextNode(pitch))
    link!(pitchNode, octaveNode)
    link!(octaveNode, TextNode("4"))
    link!(noteNode, durationNode)
    link!(durationNode, TextNode("10080"))
    link!(noteNode, typeNode)
    link!(typeNode, TextNode("quarter"))
    return noteNode
end


end
