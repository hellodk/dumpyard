import poc_2048_gui
import random

# Directions, DO NOT MODIFY
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

# Offsets for computing tile indices in each direction.
# DO NOT MODIFY this dictionary.
OFFSETS = {UP: (1, 0),
           DOWN: (-1, 0),
           LEFT: (0, 1),
           RIGHT: (0, -1)}


def shift(line, result_list):
    """
   Helper function for merge function
   """
    j_idx = 0
    for i_idx in line:
        if i_idx != 0:
            result_list[j_idx] = i_idx
            j_idx = j_idx + 1
    return result_list


def merge(line):
    """
    Helper function that merges a single row or column in 2048
    """
    result_list = [0 for index in range(len(line))]
    null_list = [0 for index in range(len(line))]
    shift(line, result_list)
    for i_idx in range(len(result_list) - 1):
        if result_list[i_idx] == result_list[i_idx + 1]:
            result_list[i_idx] = result_list[i_idx] + result_list[i_idx + 1]
            result_list[i_idx + 1] = 0
            shift(result_list, null_list)
            result_list = null_list
            # cause we have null_list here
            # after moving with vaues
    return result_list


class TwentyFortyEight:

    """
    Class to run the game logic.
    """

    def __init__(self, grid_height, grid_width):

        self.grid_height = grid_height
        self.grid_width = grid_width
        # lists computed for offsets

        lst_up = ([[0, i_idx] for i_idx in range(0, self.grid_height)])
        lst_right = ([[i_idx, self.grid_width - 1]
                      for i_idx in range(0, self.grid_width)])
        lst_left = ([[i_idx, 0] for i_idx in range(0, self.grid_width)])
        lst_down = ([[self.grid_height - 1, i_idx]
                     for i_idx in range(0, self.grid_height)])
        self.directions = {UP: lst_up,
                           RIGHT: lst_right,
                           LEFT: lst_left,
                           DOWN: lst_down,
                           }
        self.dashboard = [
            [0 for col in range(self.grid_width)] for row in range(self.grid_height)]

    def reset(self):
        """
        Reset the game so the grid is empty.
        """
        self.dashboard = [
            [0 for col in range(self.grid_width)] for row in range(self.grid_height)]

        return self.dashboard

    def __str__(self):
        """
        Return a string representation of the grid for debugging.
        """
        result = ""

        for row in range(self.grid_height):
            for col in range(self.grid_width):
                result = result + str(row) + str(col) + " "
            result += "\n"
        return result

    def get_grid_height(self):
        """
        Get the height of the board.
        """
        return self.grid_height

    def get_grid_width(self):
        """
        Get the width of the board.
        """
        return self.grid_width

    def move(self, direction):
        """
        Move all tiles in the given direction and add
        a new tile if any tiles moved.
        """
        # creating a temporary random list
        temp_dashboard = [
            [random.randrange(0, 8, 2) for col in range(4)] for row in range(4)]
        # seting this random list equal to dashboard like a new object
        for i_idx in range(0, 4):
            for j_idx in range(0, 4):
                temp_dashboard[i_idx][j_idx] = self.dashboard[i_idx][j_idx]

        temp_lst_col = []
        merge_result = []
        for row, col in self.directions[direction]:
            while row in range(0, self.grid_height) and col in range(0, self.grid_width):
                temp_lst_col.append(self.dashboard[row][col])
                if (direction == UP and row == self.grid_height - 1) or (direction == DOWN and row == 0) or (direction == LEFT and col == self.grid_width - 1) or (direction == RIGHT and col == 0):
                    # if direction == DOWN:
                    #    temp_lst_col.reverse()

                    merge_result = merge(temp_lst_col)

                    if direction == DOWN:
                        merge_result.reverse()

                    temp_lst_col = []

                    if (direction == UP) or (direction == DOWN):
                        for idx, rows in enumerate(self.dashboard):
                            rows[col] = merge_result[idx]

                    if (direction == LEFT):
                        for idx, rows in enumerate(self.dashboard):
                            self.dashboard[row][idx] = merge_result[idx]

                    if (direction == RIGHT):
                        temp_lst_col.reverse()
                        merge_result.reverse()
                        for idx, rows in enumerate(self.dashboard):
                            self.dashboard[row][idx] = merge_result[idx]

                row += OFFSETS[direction][0]
                col += OFFSETS[direction][1]
        if temp_dashboard != self.dashboard:
            TwentyFortyEight.new_tile(self)
        return self.dashboard

    def new_tile(self):
        """
        Create a new tile in a randomly selected empty 
        square.  The tile should be 2 90% of the time and
        4 10% of the time.
        """
        empty_lst = []
        # creating a list with indexes of empty tiles
        for row in range(0, self.grid_height):
            for col in range(0, self.grid_width):
                if self.dashboard[row][col] == 0:
                    empty_lst.append([row, col])

        # creating a list with randomly selected empty tile
        random_idx = random.choice(empty_lst)
        random_row = random_idx[0]
        random_col = random_idx[1]

        probability_k = random.randrange(0, 101)

        if probability_k <= 90:  # 90 percents
            TwentyFortyEight.set_tile(self, random_row, random_col, 2)

        else:
            TwentyFortyEight.set_tile(self, random_row, random_col, 4)

    def set_tile(self, row, col, value):
        """
        Set the tile at position row, col to have the given value.
        """
        self.dashboard[row][col] = value
        return self.dashboard[row][col]

    def get_tile(self, row, col):
        """
        Return the value of the tile at position row, col.
        """
        return self.dashboard[row][col]


poc_2048_gui.run_gui(TwentyFortyEight(4, 4))
