module trie
using Plots
using Combinatorics
#時系列データセットから2つの時系列データを全組み合わせで取り出して、それらのDTW距離を出す。
function calcDtwDistances(sequences)
    #時系列データセットから2つの時系列データを全組み合わせで取り出す
    sequenceCombination = collect(combinations(sequences, 2))
    #全組み合わせの時系列同士の距離を計算する
    for seq in sequenceCombination
        
    end
end

#DTWで2つの時系列の距離を計算する。
#s1:比較対象時系列データその1
#s2:比較対象時系列データその2
function dtwDistance(s1, s2)
    #DTW格納用の配列。ループごとに更新される。
    beforeDtwAry = []
    currentDtwAry = []
    #xカウンタ
    x = 0

    for elm2 in s2
    #yカウンタ
        y = 0
        x = x + 1
        currentDtwAry = []
        for elm1 in s1
            y = y + 1
            diff = abs(elm2 - elm1)
            #ループの一番最初だけは先頭同士の差の絶対値
            if x == 1 && y == 1
                currentDtwAry = [diff]
            #ループの1列目は自身の配列のひとつ前の要素
            elseif x == 1
                push!(currentDtwAry, diff + currentDtwAry[y - 1])
            #2列目以降かつ1行目は、前の配列の同じ位置の要素
            elseif x != 1 && y == 1
                push!(currentDtwAry, diff + beforeDtwAry[y])
            #それ以外は、3パターンのうちの最小値
            else
                push!(currentDtwAry, diff + minimum([beforeDtwAry[y], beforeDtwAry[y - 1], currentDtwAry[y - 1]]))
            end
        end
        #完成した現在の列を前の列にコピーする
        beforeDtwAry = currentDtwAry
    end
    #DTW配列の最後の要素がDTW-Distance
    return currentDtwAry[end]
end

#メロディを表示
function plotMelody(sequences)
    #plot装飾用
    xticks_values = [1,3,11,19,28,35,43,51,59]
    xticks_labels = ["0","1","2","3","4","5","6","7","8"]
    yticks_values = [57, 59, 60, 62, 64, 65, 67, 69]
    yticks_labels = ["A","B","C","D","E","F","G","A"]

    #表示
    plot([sequences[i]["data"] for i in 1:length(sequences)],
    labels = [sequences[i]["name"] for i in 1:length(sequences)],
    xticks = (xticks_values, xticks_labels),
    yticks = (yticks_values, yticks_labels),
    xlabel = "measure",
    ylabel = "pitch(natural tone name)")
end

#シーケンスを、階差数列にして返却する
function seqenceToDifferenceSequence(sequence)
    differenceSequence = []
    beforeElm = sequence[1]
    for elm in sequence[2:end]
        push!(differenceSequence, elm - beforeElm)
        beforeElm = elm
    end
    return differenceSequence
end


#シーケンスを増加または減少の2値（1, -1）に変換して返却する
function sequenceToBinarySequence(sequence)
    binarySequence = []
    for elm in sequence
        if elm > 0
            push!(binarySequence, 1)
        else
            push!(binarySequence, -1)
        end
    end
    return binarySequence
end


#シーケンスを独自ルールでLOUDSのTrie木構造に変換して返却する　まだできてない
function sequenceToLouds(sequence)
    #トライ木をLOUDSで表現するためのビット配列　初期値として1番ノードを指すtと、
    #ルートノードの終端を指すfと、
    #1番ノードの終端を指すfが入ってる
    bitAry = BitArray([true,false,false])
    #各ノードに対応するラベル　形式は[sequenceの要素, その要素が出現したインデックス1, その要素が出現したインデックス2,...]
    label = []
    #検索対象となるノードの情報。[何階層目か, その階層の中で左から何番目のノードか、bitIdx]
    searchTargetNodes = []
    #シーケンス番号
    seqIdx = 0

    #各階層のノード数　ルート直下からスタート
    eachLevelNodesAccumulatedNumber = []

    #各階層のbitAry上の区切り位置
    levelBoundaryBaIdx = [3]

    for elm in sequence
        seqIdx = seqIdx + 1
        #検索対象となるノードがあれば過去のシーケンスを検索開始
        if length(searchTargetNodes) > 0
            tmpSearchTargetNodes = []
            for searchTargetNode in searchTargetNodes
                #検索対象となるノードが持つsequence上のインデックスを取得。
                #ラベルから取得するが、現在のseqIdx　- 1 と同じ値の要素は取得しない　あくまで過去の要素が対象
                targetLabelIdx = 0
                if searchTargetNode[1] == 1
                    targetLabelIdx = searchTargetNode[2]
                else
                    targetLabelIdx = eachLevelNodesAccumulatedNumber[searchTargetNode[1] - 1] + searchTargetNode[2]
                end
                searchTargetSeqIdxes = filter!(e->e ≠ seqIdx - 1, label[targetLabelIdx][2:end])
                #ラベルから取得した過去のsequence上のインデックスの右隣が検索対象
                searchTargetChildrenSeqIdxes = searchTargetSeqIdxes + repeat([1], length(searchTargetSeqIdxes))
                #シーケンス上に、今来ているelmと一致したインデックスを取得
                foundMatchLabelIdxes = searchTargetChildrenSeqIdxes[findall(isequal(elm), [sequence[i] for i in searchTargetChildrenSeqIdxes])]
                #1つでも一致したシーケンスがあれば、bitAryとlabelを更新する必要がある
                if length(foundMatchLabelIdxes) > 0
                    #foundMatchLabelIdxesに現在のseqIdxも追加する。その配列をラベルに追加するため。
                    push!(foundMatchLabelIdxes, seqIdx)
                    #子ノードの情報（子ノードの数、子ノードと同じ階層の上の従兄弟の数、子ノードの終端のfalseのbitIdx）を取得する
                    bitIdx, childrenNumber, brotherChildrenNumber = getChild(levelBoundaryBaIdx, searchTargetNode, bitAry)
                    #子ノードの開始位置の一つ前のidxを取得する
                    childLabelStartIdx = eachLevelNodesAccumulatedNumber[searchTargetNode[1]] + brotherChildrenNumber
                    #子ノードが存在していたら
                    if childrenNumber > 0
                        #子ノードのラベルインデックスを取得
                        childrenLabelIdxes = childLabelStartIdx + 1:childLabelStartIdx + childrenNumber
                        #子ノードの中で一致したノードのラベルインデックスを取得
                        matchChildLabelIdx = findfirst(isequal(elm), [elmLabel[1] for elmLabel in label[childrenLabelIdxes]])
                        #一致したノードがあれば
                        if matchChildLabelIdx != nothing
                            #既存のノードラベルにfoundMatchLabelIdxesを追加する
                            childLabelStartIdx += matchChildLabelIdx
                            label[childLabelStartIdx] = insert!(unique!(sort(append!(label[matchChildLabelIdx][2:end], foundMatchLabelIdxes))), 1, label[matchChildLabelIdx][1])
                            push!(tmpSearchTargetNodes, [searchTargetNode[1] + 1, brotherChildrenNumber + matchChildLabelIdx, bitIdx - childrenNumber - 1 + matchChildLabelIdx])
                        #一致したノードがなければノード追加
                        else
                            #子ノード追加
                            insert!(bitAry, bitIdx, true)
                            #各階層のbitAry上の区切り位置更新
                            #追加した子ノードの子ノードが存在しているかもしれない階層まで、区切り位置の配列が情報を持っていなければ追加
                            #適切な位置にfalseを追加
                            insert!(bitAry, getChild(levelBoundaryBaIdx, [searchTargetNode[1] + 1, brotherChildrenNumber + childrenNumber + 1], bitAry)[1], false)
                            #子ノードを追加した階層より右側の区切り位置を1増やす
                            levelBoundaryBaIdx[searchTargetNode[1] + 2] += 1
                            levelBoundaryBaIdx[searchTargetNode[1] + 3:end] += repeat([2], length(levelBoundaryBaIdx[searchTargetNode[1] + 3:end]))
                            #子ノードを追加した階層から右側のノード数を1増やす
                            eachLevelNodesAccumulatedNumber[searchTargetNode[1]+ 1:end] += repeat([1], length(eachLevelNodesAccumulatedNumber[searchTargetNode[1]+ 1:end]))
                            #labelに追加
                            insert!(label, childrenLabelIdxes[end] + 1, insert!(foundMatchLabelIdxes, 1, elm))
                            #既に登録されているsearchTargetNodesを更新
                            if length(tmpSearchTargetNodes) > 0
                                for pastSearchTargetNode in tmpSearchTargetNodes
                                    #今回追加したbitIdxより後ろのbitIdxの場合、1つ右にずらす
                                    if bitIdx < pastSearchTargetNode[3]
                                        pastSearchTargetNode[3] += 1     
                                        #さらに同じ階層の場合、ノードの左からの順番も1つ右にずらす
                                        if searchTargetNode[1] == pastSearchTargetNode[1]
                                            pastSearchTargetNode[1] += 1
                                        end
                                    end
                                end
                            end
                            #searchTargetNodeを追加する。
                            push!(tmpSearchTargetNodes, [searchTargetNode[1] + 1, brotherChildrenNumber + childrenNumber + 1, bitIdx])
                        end
                    #子ノードが存在していなければ子ノードを追加する
                    else
                        #子ノード追加
                        insert!(bitAry, bitIdx, true)
                        
                        #各階層のbitAry上の区切り位置更新
                        #追加した子ノードの子ノードが存在しているかもしれない階層まで、区切り位置の配列が情報を持っていなければ追加
                        if length(levelBoundaryBaIdx) < searchTargetNode[1] + 2
                            push!(levelBoundaryBaIdx, levelBoundaryBaIdx[end] + length(bitAry[levelBoundaryBaIdx[end]:end]))
                            #falseも追加
                            push!(bitAry, false)
                        #既に存在している場合
                        else
                            #適切な位置にfalseを追加
                            insert!(bitAry, getChild(levelBoundaryBaIdx, [searchTargetNode[1] + 1, brotherChildrenNumber + 1], bitAry)[1], false)
                            #子ノードを追加した階層より右側の区切り位置を1増やす
                            levelBoundaryBaIdx[searchTargetNode[1] + 2] += 1
                            levelBoundaryBaIdx[searchTargetNode[1] + 3:end] += repeat([2], length(levelBoundaryBaIdx[searchTargetNode[1] + 3:end]))
                            
                        end
                        #今回追加した子ノードの階層まで、各階層のノード数配列が情報を持っていなければ追加
                        if length(eachLevelNodesAccumulatedNumber) < searchTargetNode[1] + 1
                            push!(eachLevelNodesAccumulatedNumber, eachLevelNodesAccumulatedNumber[end] + 1)
                        #既に存在している場合
                        else
                            #子ノードを追加した階層から右側のノード数を1増やす
                            eachLevelNodesAccumulatedNumber[searchTargetNode[1]+ 1:end] += repeat([1], length(eachLevelNodesAccumulatedNumber[searchTargetNode[1] + 1:end]))
                        end
                        #labelに追加
                        insert!(label, childLabelStartIdx + 1, insert!(foundMatchLabelIdxes, 1, elm))
                        #既に登録されているsearchTargetNodesを更新
                        if length(tmpSearchTargetNodes) > 0
                            for pastSearchTargetNode in tmpSearchTargetNodes
                                #今回追加したbitIdxより後ろのbitIdxの場合、1つ右にずらす
                                if bitIdx < pastSearchTargetNode[3]
                                    pastSearchTargetNode[3] += 1     
                                    #さらに同じ階層の場合、ノードの左からの順番も1つ右にずらす
                                    if searchTargetNode[1] == pastSearchTargetNode[1]
                                        pastSearchTargetNode[1] += 1
                                    end
                                end
                            end
                        end
                        #searchTargetNodeを追加する。
                        push!(tmpSearchTargetNodes, [searchTargetNode[1] + 1, brotherChildrenNumber + 1, bitIdx])
                    end
                end
                
            end
            #次回の検索用配列にコピー
            searchTargetNodes = tmpSearchTargetNodes
        end
        #ルートの子ノードに追加する
        #子供があれば
        if length(eachLevelNodesAccumulatedNumber) > 0
            #同じ要素が子ノードにあるか検索
            matchRootChildLabelIdx = findfirst(isequal(elm), [labelElm[1] for labelElm in label[1:eachLevelNodesAccumulatedNumber[1]]])
            #あれば
            if matchRootChildLabelIdx !== nothing
                #一致したラベルに現在のシーケンスインデックスを追加
                push!(label[matchRootChildLabelIdx], seqIdx)
                #ターゲットノードとして追加
                push!(searchTargetNodes, [1, matchRootChildLabelIdx, 2 + matchRootChildLabelIdx])
            else
            #ルートノードの子にいない場合は追加
                insert!(bitAry, 2 + eachLevelNodesAccumulatedNumber[1] + 1, true)
                insert!(bitAry, getChild(levelBoundaryBaIdx, [1, eachLevelNodesAccumulatedNumber[1] + 1], bitAry)[1], false)
                insert!(label,  eachLevelNodesAccumulatedNumber[1] + 1, [elm, seqIdx])
                eachLevelNodesAccumulatedNumber += repeat([1], length(eachLevelNodesAccumulatedNumber))
                levelBoundaryBaIdx[2:end] += repeat([1], length(levelBoundaryBaIdx[2:end]))
            end
        #なければ追加
        else
            insert!(bitAry, 3, true)
            push!(bitAry, false)
            insert!(label, 1, [elm, seqIdx])
            push!(eachLevelNodesAccumulatedNumber, 1)
            push!(levelBoundaryBaIdx, 5)
        end
    end
    #pumlファイル生成　生成ファイルが重い可能性があるので注意
    #trieToPuml(bitAry, label)
end

# 渡したノードの子ノードの情報を取得
function getChild(levelBoundaryBaIdx, searchTargetNode, bitAry)
    brotherNumber = 0
    countChildren = false
    childrenNumber = 0
    brotherChildrenNumber = 0
    #調査対象ノードが長男の場合、直下の階層の最初が調査対象ノードの子ノードになるので子ノードとして数えだす
    if searchTargetNode[2] == 1
        countChildren = true
    end
    bitIdx = levelBoundaryBaIdx[searchTargetNode[1] + 1] - 1
    for bit in bitAry[bitIdx + 1:end]
        bitIdx += 1       
        if countChildren == true 
            if bit == true
                childrenNumber += 1
            else
                brotherNumber += 1
            end
        else
            if bit == false
                brotherNumber += 1
            else
                brotherChildrenNumber += 1
            end
        end
        if brotherNumber == searchTargetNode[2] - 1
            countChildren = true
        end
        if brotherNumber == searchTargetNode[2]
            break
        end                        
    end
    return bitIdx, childrenNumber, brotherChildrenNumber
end

# PlantUMLファイル生成。Trie木を可視化。
function trieToPuml(bitAry, label)
    open("tree.puml", "w") do file
        write(file, "'This file was automatically generated.\n@startuml tree_diagram\nobject 0\n")
        
        bitCnt = 0
        for bit in bitAry[3:end]
            if bit == true
                bitCnt += 1
                write(file, "object ", string(bitCnt), "\n", string(bitCnt), " : value=", string(label[bitCnt][1]), "\n", string(bitCnt), " : seqIdx=", string(label[bitCnt][2:end], "\n"))
            end
        end
        children = []
        parent = 0
        labelCnt = 0
        for bit in bitAry[3:end]
            if bit == true
                labelCnt += 1
                push!(children, labelCnt)
            elseif bit == false 
                if length(children) > 0
                    for child in children
                        write(file, string(parent), "--", string(child), "\n")
                    end
                    children = []
                end
                parent += 1
            end
        end
        write(file, "@enduml")
    end
end

end