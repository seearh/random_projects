"""
Library to (lazily) print a Christmas tree
"""


def gen_triangle_lines(num_of_lines, inverted=False, sym="."):
    """
    Generator function for lines that will print a triangle
    Args:
    1) num_of_lines (int): Number of lines to print the triangle in (i.e. its size)
    2) OPT inverted (bool): True if triangle should be inverted, False if upright
    3) OPT sym (char): String character to fill the triangle
    Yields:
    Sequential lines of a triangle
    """
    if not inverted:
        iterable = range(num_of_lines)
    else:
        iterable = range(num_of_lines-1, -1, -1)
    for i in iterable:
        yield sym * (2 * (i + 1) - 1)


def overlap_lines(list_of_lines, offset, print_longest=False):
    """
    Generator function that takes in a list of generator objects for
    triangle lines, with overlap over a few lines
    Args:
    1) list_of_lines (list of generator objects):
    List of generator objects for triangle lines
    2) OPT offset (int):
    Number of lines to overlap by
    3) OPT print_longest (bool):
    When overlapping, pick longer line if True, pick
    next line if False
    Yields: Sequential lines of strings that forms the overlapped triangle
    """
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
    """
    Function to print all lines provided, centre justified according to the lengthiest line
    Args:
    1) VAR lines_to_print (generator object):
    Generator objects of lines to print
    """
    all_lines = []
    for line in lines_to_print:
        all_lines.extend(line)
    longest_base = max([len(line) for line in all_lines])
    for line in all_lines:
        print(f"{line:^{longest_base}}")
        

def words_overlay(love_letter, *lines_to_print, sym="."):
    """
    Function to overlay words onto lines provided
    Args:
    1) love_letter (str): Words to overlay with
    2) VAR lines_to_print (generator object):
    3) OPT sym (char): String character that should be replaced
    Generator objects of lines to print
    """
    all_lines = []
    for line in lines_to_print:
        all_lines.extend(line)
    love_letter = love_letter.split()
    for line in all_lines:
        line = str(line)
        replaceable_char = line.count(sym) - 4
        replace_str = ""
        index = line.find(sym) + 2
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
        yield new_line
        
        
def gen_tree(initial, spread, parts):
    """
    Function to shape the Christmas Tree
    Args:
    1) initial (int): Size of first part
    2) spread (int): Size increment per part of the tree
    3) parts (int): Number of parts to make up the tree
    Returns:
    Generator objects of lines to print
    """
    if parts == 1:
        return gen_triangle_lines(spread*parts + initial)
    else:
        return overlap_lines(
            [
                gen_tree(initial, spread, parts-1),
                gen_triangle_lines(spread*parts + initial),
            ],
            offset = (spread-1)*parts,
            print_longest=True,
        )