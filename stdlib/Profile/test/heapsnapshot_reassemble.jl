using Test

@testset "_write_decimal_number" begin
    _digits_buf = zeros(UInt8, ndigits(typemax(UInt)))
    io = IOBuffer()

    test_write(d) = begin
        Profile.HeapSnapshot._write_decimal_number(io, d, _digits_buf)
        s = String(take!(io))
        seekstart(io)
        return s
    end
    @test test_write(0) == "0"
    @test test_write(99) == "99"
    # Sample among possible UInts we might print
    for x in typemin(UInt):typemax(UInt)÷10001:typemax(UInt)
        @test test_write(x) == string(x)
    end
end