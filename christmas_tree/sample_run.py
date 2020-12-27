"""
I seem to reserve doing the stupidest things for you...
A Nerd's Christmas Card for his Nerd lover
"""
from christmas_utils import (
    gen_asterisks,
    overlap_lines,
    gen_tree,
    words_overlay,
    print_generated_lines,
)


star = overlap_lines(
    [
        gen_asterisks(7),
        gen_asterisks(7, inverted=True),
    ],
    offset=5,
    print_longest=True
)
stem = ("*" * 3 for i in range(4))
base = ("*" * (2*i+20) for i in range(5))
tree = gen_tree(initial=5, spread=4, parts=6)

with open("love_letter.byte", "rb") as f:
    love_letter = f.read().decode()

print_generated_lines(
    words_overlay(
        love_letter,
        star,
        tree,
        stem,
        base,
    )
)