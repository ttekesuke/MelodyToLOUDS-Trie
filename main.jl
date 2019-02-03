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
    #0番ノードの子ノードの終端を指すfと、
    #1番ノードの子ノードの終端を指すfが入ってる
    bitAry = BitArray([true,false,false])
    #各ノードに対応するラベル　形式は[sequenceの要素, その要素が出現したインデックス1, その要素が出現したインデックス2,...]
    label = []
    #検索対象となるノードの情報。[[bitAry上のインデックス, label上のインデックス, 同じ世代のノードの中で左から何番目か], ...]。そのノードの子ノードを検索する。
    searchTargetNode = []
    #シーケンス番号
    seqIdx = 0
    #検索対象ノードの子ノードの数
    childrenNumber = 0
    #ルートノードの子ノードの数
    rootChildrenNumber = 0
    #各層のノードの数をカウントしていく ルートも記載あり
    eachLevelNodesNumber = [1]


    for elm in sequence
        seqIdx = seqIdx + 1
        
        #過去のシーケンスを検索開始　検索対象となるノードがあれば
        if length(searchTargetNode) > 0
            
            #初期化
            tmpSearchTargetNode = []
            #検索対象のノードのbitAry上のインデック
            for searchElm in searchTargetNode
                
                
                #調査対象のsequence上のインデックスを取得。
                #ラベルから取得するが、現在のseqIdx　- 1 と同じ値の要素は取得しない
                #あくまで過去の要素が対象
                searchTargetSeqIdxes = filter!(e->e ≠ seqIdx - 1, label[searchElm[2]][2:end])

                #調査対象のラベルのseqIdxの一つ右隣の中で、要素と一致しているラベルインデックスを取得
                searchTargetChildrenIdxes = searchTargetSeqIdxes + repeat([1], length(searchTargetSeqIdxes))       
                foundMatchLabelIdxes = searchTargetChildrenIdxes[findall(isequal(elm), sequence[searchTargetChildrenIdxes])]
                #あれば
                if length(foundMatchLabelIdxes) > 0
                    
                    #foundMatchLabelIdxesには現在のelmも追加する。その配列をラベルに追加するため。
                    push!(foundMatchLabelIdxes, seqIdx)
                    
                    #labelとbitAryを更新する。
                    #子ノードが存在していればラベルにシーケンスインデックスを追加する
                    #子ノードがなければ子ノードを追加する
                    #bitAryに追加する位置を決める 
                    #カウンター　初期値は渡されたターゲットノードのインデックス
                    bitAryIdx = searchElm[1]
                    #探索時に見つかった、関係ないノードの終端を示す0の数     
                    foundOtherNodesFalseNum = 0
                    #探索時に見つかった、関係ないノードの数
                    foundOtherNodesNum = 0
                    #ターゲットノードの子ノードの数
                    targetChildrenNum = 0
                    #ターゲットノードの子ノードの階層にいるノードの数
                    foundSameLevelChildrenNum = 0
                    #ターゲットノードの兄弟を数え上げた後に各ブロックの数を数えだすフラグ
                    countFalse = false
                    #ターゲットノードの子ノードを数えだすフラグ
                    countChild = false
                    for baElm in bitAry[searchElm[1] + 1:end]
                        
                        #ターゲットノードの親ノードがルートでかつターゲットノードと同じ階層の右端の場合
                        #またはターゲットノードの親ノードがルートでなくかつ親ノードに↑の兄弟がいない場合、
                        #即座にcountFalseを開始する
                        # println("nanic", eachLevelNodesNumber)
                        # println("nanid", searchElm[3])
                        if eachLevelNodesNumber[searchElm[3]-1] - searchElm[5] == 0 && searchElm[3] != 2 || eachLevelNodesNumber[searchElm[3]] - searchElm[4] == 0 && searchElm[3] == 2
                            countFalse = true
                            
                        end
                        #次の値から検索開始
                        bitAryIdx += 1
                        if countFalse == true
                            if baElm == false
                                foundOtherNodesFalseNum += 1
                                
                            elseif baElm == true && countChild == false
                                foundOtherNodesNum += 1
                                foundSameLevelChildrenNum += 1
                            end
                        else
                            if baElm == true
                                foundOtherNodesNum += 1
                            end
                        end
                        if countChild == true
                            if baElm == true
                                targetChildrenNum += 1
                            end
                        end
                        #ターゲットノードの右隣の1の数が、同じ階層のノードの数-左から何番目かの値になれば
                        #同じ階層のノードを数え終わったことになるので、今度はfalseを数え出す
                        # println("nania", searchElm[3])
                        # println("nanib", eachLevelNodesNumber)
                        if foundOtherNodesNum == eachLevelNodesNumber[searchElm[3]] - searchElm[4]
                            countFalse = true
                            
                        end
                        #+1分は同じ階層の終了分を表す　その右側searchElm[4]つ目が対象の子ノードのブロックの終了を示す0だが
                        #1個前の0から子供ノードをカウントしだすフラグを立てる
                        parentNodeLevel = searchElm[3] - 1
                        if parentNodeLevel == 0
                            parentNodeLevel = 1
                        end
                        
                        
                        if foundOtherNodesFalseNum == 1 + searchElm[4] - 1
                            
                            countChild = true
                            
                        end
                        if foundOtherNodesFalseNum == 1 + searchElm[4]
                            
                            break
                        end
                    end
                    
                    
                    #ある場合
                    if targetChildrenNum > 0
                        
                        
                    #子ノード達のラベルIdx取得
                        childrenLabelIdxes = searchElm[2] + foundOtherNodesNum + 1:searchElm[2] + foundOtherNodesNum + targetChildrenNum
                    #子ノード達の中で、今来ている値と同じ値のインデックスを取得  
                        matchChildLabelIdxInBrothers = findfirst(isequal(elm), [elmLabel[1] for elmLabel in label[childrenLabelIdxes]])
                        
                    #一致したものがあれば
                        if matchChildLabelIdxInBrothers != nothing
                            
                            matchChildLabelIdx = matchChildLabelIdxInBrothers + searchElm[2] + foundOtherNodesNum
                            #既存のノードラベルにfoundMatchLabelIdxesを追加する　重複は除く TODO:重複になるケースがあるか不明
                            
                            
                            
                            label[matchChildLabelIdx] = insert!(unique!(append!(label[matchChildLabelIdx][2:end], foundMatchLabelIdxes)), 1, label[matchChildLabelIdx][1])
                            push!(tmpSearchTargetNode, [bitAryIdx - targetChildrenNum - 1 + matchChildLabelIdxInBrothers , matchChildLabelIdx, searchElm[3] + 1, foundSameLevelChildrenNum + 1, searchElm[4]])#ここむずい
                            
                        else
                            
                            #なければ子ノードを追加する
                            
                            insert!(bitAry, bitAryIdx, true)#ここはOK

                            push!(bitAry, false)#ここはOK
           
                            insert!(label, childrenLabelIdxes[end] + 1, insert!(foundMatchLabelIdxes, 1, elm))
                            #searchTargetに追加する前に、searchTargetに既に追加されているものがあれば、それらのうちbitAryに関するものを更新する。
                            if length(tmpSearchTargetNode) > 0
                                for searchTargetNode in tmpSearchTargetNode
                                    if searchTargetNode[1] > bitAryIdx
                                        searchTargetNode[1] += 1
                                        searchTargetNode[2] += 1
                                        if searchTargetNode[3] == searchElm[3]
                                            searchTargetNode[4] += 1
                                        end
                                        #既存の調査対象ノードの親ノードが、今ターゲットに追加するノードと同じ階層で、かつ既存の調査対象ノードの親ノードが今ターゲットに追加するノードの右側にあれば、既存のやつを1追加する
                                        if searchTargetNode[3] - 1 == searchElm[3] + 1 && searchTargetNode[5] > foundSameLevelChildrenNum + 1
                                            searchTargetNode[5] += 1
                                        end
                                    end
                                end
                            end
                            #searchTargetに追加する
                            push!(tmpSearchTargetNode, [bitAryIdx, childrenLabelIdxes[end] + 1, searchElm[3] + 1, foundSameLevelChildrenNum + 1, searchElm[4]])#ここはOK
                            
                            if length(eachLevelNodesNumber) < searchElm[3] + 1
                                push!(eachLevelNodesNumber, 1)
                            else
                                eachLevelNodesNumber[searchElm[3] + 1] += 1
                            end
     
                        end
                    else
                        #なければ子ノード追加
                        
                        insert!(bitAry, bitAryIdx, true)

                        
                        push!(bitAry, false)

                        insert!(label, searchElm[2] + foundOtherNodesNum + 1, insert!(foundMatchLabelIdxes, 1, elm))
                        #searchTargetに追加する前に、searchTargetに既に追加されているものがあれば、それらのうちbitAryに関するものを更新する。
                        if length(tmpSearchTargetNode) > 0
                            for searchTargetNode in tmpSearchTargetNode
                                if searchTargetNode[1] > bitAryIdx
                                    searchTargetNode[1] += 1
                                    searchTargetNode[2] += 1
                                    if searchTargetNode[3] == searchElm[3]
                                        searchTargetNode[4] += 1
                                    end
                                    #既存の調査対象ノードの親ノードが、今ターゲットに追加するノードと同じ階層で、かつ既存の調査対象ノードの親ノードが今ターゲットに追加するノードの右側にあれば、既存のやつを1追加する
                                    if searchTargetNode[3] - 1 == searchElm[3] + 1 && searchTargetNode[5] > foundSameLevelChildrenNum + 1
                                        searchTargetNode[5] += 1
                                    end                                    
                                end
                            end
                        end
                        #searchTargetに追加する
                        
                        push!(tmpSearchTargetNode, [bitAryIdx, searchElm[2] + foundOtherNodesNum + 1, searchElm[3] + 1, foundSameLevelChildrenNum + 1, searchElm[4]])
                        
                        
                        if length(eachLevelNodesNumber) < searchElm[3] + 1
                            push!(eachLevelNodesNumber, 1)
                        else
                            eachLevelNodesNumber[searchElm[3] + 1] += 1
                        end
                    end
                end
            end
            #次回の検索用配列にコピー
            searchTargetNode = tmpSearchTargetNode
        end
        #ルートの子ノードに追加する
        #子供があれば
        if length(eachLevelNodesNumber) > 1
            #同じ要素が子ノードにあるか検索
            sameRootChildLabelIdx = findfirst(isequal(elm), [labelElm[1] for labelElm in label[1:eachLevelNodesNumber[2]]])
            
            #あれば
            if sameRootChildLabelIdx !== nothing
                #一致したラベルに現在のシーケンスインデックスを追加
                push!(label[sameRootChildLabelIdx], seqIdx)
                #ターゲットノードの1の位置を[bitaryIdx, labelIdx, 階層の番号, 同じ階層のノードの中で左から何番目か, ターゲットノードの親ノードは同じ階層で左から何番目か]の配列で先頭に追加する
                push!(searchTargetNode, [sameRootChildLabelIdx + 2, sameRootChildLabelIdx, 2, sameRootChildLabelIdx, 1])
            else
            #ルートノードの子にいない場合は追加

            insert!(bitAry, 3, true)
                push!(bitAry, false)

                insert!(label,  eachLevelNodesNumber[2] + 1, [elm, seqIdx])
                eachLevelNodesNumber[2] += 1
            end
        #なければ追加
        else
            insert!(bitAry, 3, true)

            push!(bitAry, false)

            insert!(label, 1, [elm, seqIdx])
            push!(eachLevelNodesNumber, 1)
        end
        
        
        



    end
    trieToPuml(bitAry, label)
end

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