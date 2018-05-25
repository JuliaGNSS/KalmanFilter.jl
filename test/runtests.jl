using Base.Test, KalmanFilter

srand(1234)

include("ukf.jl")
include("kf.jl")

@testset "Measurement augmentation" begin

    𝐱 = [0, 1]
    𝐏 = diagm([2, 3])
    𝐓 = [1 0.1; 0 1]
    𝐐 = diagm([0.25, 0.25])
    time_update = KalmanFilter.init_kalman(𝐱, 𝐏)
    measurement_update = time_update(𝐓, 𝐐)
    time_update1, 𝐱, 𝐏 = measurement_update(5, x -> x[1], 0.1)
    time_update2, 𝐱_aug, 𝐏_aug = measurement_update(5, x -> x[1] + x[3], Augment(0.1))
    @test 𝐱 ≈ 𝐱_aug
    @test 𝐏 ≈ 𝐏_aug
end

@testset "Transition augmentation" begin

    𝐱 = [0, 1]
    𝐏 = diagm([2, 3])
    𝐓 = [1 0.1; 0 1]
    𝐐 = diagm([0.25, 0.25])
    time_update = KalmanFilter.init_kalman(𝐱, 𝐏)
    measurement_update = time_update(𝐓, 𝐐)
    measurement_update_aug = time_update([𝐓 eye(2)], Augment(𝐐))
    time_update1, 𝐱, 𝐏 = measurement_update(5, x -> x[1], 0.1)
    time_update2, 𝐱_aug, 𝐏_aug = measurement_update_aug(5, x -> x[1], 0.1)
    @test 𝐱 ≈ 𝐱_aug
    @test 𝐏 ≈ 𝐏_aug
end

@testset "Transition and measurement augmentation" begin

    𝐱 = [0, 1]
    𝐏 = diagm([2, 3])
    𝐓 = [1 0.1; 0 1]
    𝐐 = diagm([0.25, 0.25])
    time_update = KalmanFilter.init_kalman(𝐱, 𝐏)
    measurement_update = time_update(𝐓, 𝐐)
    measurement_update_aug = time_update([𝐓 eye(2) zeros(2); 0 0 0 0 1], Augment(𝐐), Augment(0.1))
    time_update1, 𝐱, 𝐏 = measurement_update(5, x -> x[1], 0.1)
    time_update2, 𝐱_aug, 𝐏_aug = measurement_update_aug(5, x -> x[1] + x[3])
    @test 𝐱 ≈ 𝐱_aug
    @test 𝐏 ≈ 𝐏_aug
end

@testset "Filter states" begin
    𝐱 = [0, 1]
    𝐏 = diagm([2, 3])
    used_states = [true, false]
    part_𝐱, part_𝐏 = KalmanFilter.filter_states(𝐱, 𝐏, used_states)
    @test part_𝐱 == [0]
    @test part_𝐏 == 𝐏[used_states, used_states]
end

@testset "Expand states" begin
    𝐱_init = [0, 1]
    𝐏_init = diagm([2, 3])
    𝐱_prev = [1, 2]
    𝐏_prev = diagm([3, 4])
    used_states = [true, false]
    part_𝐱 = [3]
    part_𝐏 = ones(2,2)[used_states,used_states] * 5
    reset_unused_states = false
    𝐱, 𝐏 = KalmanFilter.expand_states(part_𝐱, part_𝐏, 𝐱_init, 𝐏_init, 𝐱_prev, 𝐏_prev, used_states, reset_unused_states)
    @test 𝐱 == [3,2]
    @test 𝐏 == diagm([5,4])

    reset_unused_states = true
    𝐱, 𝐏 = KalmanFilter.expand_states(part_𝐱, part_𝐏, 𝐱_init, 𝐏_init, 𝐱_prev, 𝐏_prev, used_states, reset_unused_states)
    @test 𝐱 == [3,1]
    @test 𝐏 == diagm([5,3])
end