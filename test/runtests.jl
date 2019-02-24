using trieMusic
using Test

@testset "trieMusic.jl" begin
@test trieMusic.seqenceToDifferenceSequence([1,2]) == [1]
 end
