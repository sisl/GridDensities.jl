using GridDensities
using Test

function sum_pdf(d::GridDensity)
	# Take a sample from each bin and ensure that they sum to one
	dims = length(d.bins)
	points = length(d.linear)
	centers = [[d.lo[i] + ((j-1)+0.5)*(d.hi[i]-d.lo[i])/d.bins[i] for j=1:d.bins[i]] for i = 1:dims]
	probs = [pdf(d, [centers[j][d.cart[i][j]] for j = 1:dims]) for i = 1:points]
	return sum(probs)*d.volume
end

function checkbounds(lo, hi, point)
	return all(lo .≤ point .≤ hi)
end

function test_uniform(lo, hi, bins)
	d = GridDensity(ones(prod(bins)), lo, hi, bins)
	point = (hi .+ lo) ./ 2
	prob = 1/(prod(bins)*d.volume)
	return abs(pdf(d, point) - prob) < 1e-8
end

@testset "GridDensities.jl" begin
    # Check for valid pdfs
    d = GridDensity(rand(8), [0.0, 0.0], [2.0, 4.0], [2, 4])
    @test abs(1.0 - sum_pdf(d)) < 1e-8
    d = GridDensity(rand(20*31*52), [0.1, 0.2, 12.0], [1.2, 1.6, 22.5], [20, 31, 52])
    @test abs(1.0 - sum_pdf(d)) < 1e-8

    # Check for samples in ranges
    d = GridDensity(rand(8), [0.0, 0.0], [2.0, 4.0], [2, 4])
    @test all([checkbounds([0.0, 0.0], [2.0, 4.0], rand(d)) for i = 1:50])
    d = GridDensity(rand(20*31*52), [0.1, 0.2, 12.0], [1.2, 1.6, 22.5], [20, 31, 52])
    @test all([checkbounds([0.1, 0.2, 12.0], [1.2, 1.6, 22.5], rand(d)) for i = 1:50])

    # Check pdf for uniform distributions
    @test test_uniform([0.0, 0.0], [2.0, 4.0], [2, 4])
    @test test_uniform([0.1, 0.2, 12.0], [1.2, 1.6, 22.5], [20, 31, 52])
end
