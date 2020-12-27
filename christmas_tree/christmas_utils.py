"""
Library to (lazily) print a Christmas tree
"""


def gen_asterisks(num_of_lines, inverted=False):
    base_num = 2*num_of_lines - 1
    if not inverted:
        iterable = range(num_of_lines)
    else:
        iterable = range(num_of_lines-1, -1, -1)
    for i in iterable:
        num_of_stars = 2 * (i + 1) - 1
        line = "*" * num_of_stars
        yield line


def overlap_lines(list_of_lines, offset=0, print_longest=False):
    output_lines = []
    for counter, lines in enumerate(list_of_lines):
        lines = list(lines)
        if counter > 0:
            if offset > 0:
                if print_longest:
                    lines[:offset] = [
                        x if len(x) > len(y) 
                        else y 
                        for x, y in zip(
                            output_lines[-offset:], lines[:offset]
                        )
                    ]
                output_lines[-offset:] = []
        output_lines.extend(lines)
    for line in output_lines:
        yield line
        

def print_generated_lines(*lines_to_print):
    all_lines = []
    for line in lines_to_print:
        all_lines.extend(line)
    longest_base = max([len(line) for line in all_lines])
    for line in all_lines:
        print(f"{line:^{longest_base}}")
        

def words_overlay(love_letter, *lines_to_print):
    all_lines = []
    for line in lines_to_print:
        all_lines.extend(line)
    love_letter = love_letter.split()
    for line in all_lines:
        line = str(line)
        replaceable_char = line.count("*") - 4
        replace_str = ""
        index = line.find("*") + 2
        while replaceable_char > 0 and love_letter:
            word = love_letter[0] + " "
            if len(replace_str + word.rstrip()) > replaceable_char:
                break
            replace_str += word
            del love_letter[0]
        new_line = (
            line[:index] 
            + replace_str.rstrip() 
            + line[index+len(replace_str.rstrip()):]
        )
        yield new_line.replace("*", ".")
        
        
def gen_tree(initial, spread, parts):
    if parts == 1:
        return gen_asterisks(spread*parts + initial)
    else:
        return overlap_lines(
            [
                gen_tree(initial, spread, parts-1),
                gen_asterisks(spread*parts + initial),
            ],
            offset = (spread-1)*parts,
            print_longest=True,
        )