%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp

from cairo_math_64x61.math64x61 import Math64x61
from src.discrete import DiscreteGDA

@external
func test_initial_price{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    let initial_price = 1000;
    let initial_price_fp = Math64x61.fromFelt(initial_price);
    let scale_factor_fp = Math64x61.div(Math64x61.fromFelt(11), Math64x61.fromFelt(10)); 
    let decay_constant_fp = Math64x61.div(Math64x61.fromFelt(1), Math64x61.fromFelt(2));

    let (auction_start_time) = get_block_timestamp();
    let auction_start_time_fp = Math64x61.fromFelt(auction_start_time);

    DiscreteGDA.initializer(initial_price_fp, scale_factor_fp, decay_constant_fp, auction_start_time_fp);
    let price = DiscreteGDA.purchase_price(1, 0);
    assert price = initial_price;

    return ();
}
