%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp

from cairo_math_64x61.math64x61 import Math64x61
from src.discrete import DiscreteGDA

@external
func __setup__{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{ max_examples(100) %}

    let initial_price = 1000;
    let initial_price_fp = Math64x61.fromFelt(initial_price);
    let scale_factor_fp = Math64x61.div(Math64x61.fromFelt(11), Math64x61.fromFelt(10)); 
    let decay_constant_fp = Math64x61.div(Math64x61.fromFelt(1), Math64x61.fromFelt(2));

    let (auction_start_time) = get_block_timestamp();
    let auction_start_time_fp = Math64x61.fromFelt(auction_start_time);

    %{
        context.initial_price = ids.initial_price
        context.initial_price_fp = ids.initial_price_fp
        context.scale_factor_fp = ids.scale_factor_fp
        context.decay_constant_fp = ids.decay_constant_fp
        context.auction_start_time = ids.auction_start_time
    %}


    DiscreteGDA.initializer(initial_price_fp, scale_factor_fp, decay_constant_fp, auction_start_time_fp);
    return ();
}

@external
func test_initial_price{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    let price = DiscreteGDA.purchase_price(1, 0);

    tempvar initial_price;
    %{ ids.initial_price = context.initial_price %}
    assert price = initial_price;

    return ();
}

@external
func setup_correctness() {
    %{
        given(
            amount = strategy.integers(1, 10),
            elapsed = strategy.integers(1, 10),
            quantity = strategy.integers(1, 10),
        )
    %}
    return ();
}

@external
func test_correctness{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}(amount: felt, elapsed: felt, quantity: felt) {
    alloc_locals;

    local expect: felt;
    %{
        import math
        from starkware.cairo.common.math_utils import as_int

        SCALE = 2 ** 61

        initial_price = as_int(context.initial_price_fp, PRIME) / SCALE
        decay_constant = as_int(context.decay_constant_fp, PRIME) / SCALE
        scale_factor = as_int(context.scale_factor_fp, PRIME) / SCALE

        t1 = initial_price * math.pow(scale_factor, ids.amount)
        t2 = math.pow(scale_factor, ids.quantity) - 1
        t3 = math.exp(decay_constant * ids.elapsed)
        t4 = scale_factor - 1
        price = t1 * t2 / (t3 * t4)
        price = int(price)

        ids.expect = price
    %}

    %{ stop_warp = warp(context.auction_start_time + ids.elapsed) %}

    let got = DiscreteGDA.purchase_price(quantity, amount);

    assert expect = got;

    return ();
}
