const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

// --------------------------------
// Constant Variables and Structs
// --------------------------------

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 800;
const NO_TILES_X = 40;
const NO_TILES_Y = 40;
const SNAKE_WAIT_TIME: u32 = 60 * 0.10;
const TILE_WIDTH: u32 = SCREEN_WIDTH / NO_TILES_X;
const TILE_HEIGHT: u32 = SCREEN_HEIGHT / NO_TILES_Y;

const SNAKE_UP = raylib.KEY_F;
const SNAKE_DOWN = raylib.KEY_S;
const SNAKE_LEFT = raylib.KEY_R;
const SNAKE_RIGHT = raylib.KEY_N;

const Game_State = enum {
    Title_Screen,
    Game_Screen,
    Ending_Screen,
};

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
    Constant,
    Null,
};

const Snake = struct {
    head_x: u16,
    head_y: u16,
    tail_x: u16,
    tail_y: u16,
};

const Tile = struct {
    has_movement: Direction,
};

// --------------------------------
// Update Functions
// --------------------------------

fn update_Snake_Head(board: *[NO_TILES_X][NO_TILES_Y]Tile, snake: *Snake, place_food: *bool) bool {
    switch (board[snake.head_x][snake.head_y].has_movement) {
        Direction.Up => {
            if (snake.head_x == 0 or
                (board[snake.head_x - 1][snake.head_y].has_movement != Direction.Null and
                board[snake.head_x - 1][snake.head_y].has_movement != Direction.Constant))
            {
                return true;
            }
            place_food.* = board[snake.head_x - 1][snake.head_y].has_movement == Direction.Constant;

            board[snake.head_x - 1][snake.head_y].has_movement = board[snake.head_x][snake.head_y].has_movement;
            snake.head_x -= 1;
        },
        Direction.Down => {
            if (snake.head_x + 1 == NO_TILES_X or
                (board[snake.head_x + 1][snake.head_y].has_movement != Direction.Null and
                board[snake.head_x + 1][snake.head_y].has_movement != Direction.Constant))
            {
                return true;
            }
            place_food.* = board[snake.head_x + 1][snake.head_y].has_movement == Direction.Constant;

            board[snake.head_x + 1][snake.head_y].has_movement = board[snake.head_x][snake.head_y].has_movement;
            snake.head_x += 1;
        },
        Direction.Left => {
            if (snake.head_y == 0 or
                (board[snake.head_x][snake.head_y - 1].has_movement != Direction.Null and
                board[snake.head_x][snake.head_y - 1].has_movement != Direction.Constant))
            {
                return true;
            }
            place_food.* = board[snake.head_x][snake.head_y - 1].has_movement == Direction.Constant;

            board[snake.head_x][snake.head_y - 1].has_movement = board[snake.head_x][snake.head_y].has_movement;
            snake.head_y -= 1;
        },
        Direction.Right => {
            if (snake.head_y + 1 == NO_TILES_Y or
                (board[snake.head_x][snake.head_y + 1].has_movement != Direction.Null and
                board[snake.head_x][snake.head_y + 1].has_movement != Direction.Constant))
            {
                return true;
            }
            place_food.* = board[snake.head_x][snake.head_y + 1].has_movement == Direction.Constant;

            board[snake.head_x][snake.head_y + 1].has_movement = board[snake.head_x][snake.head_y].has_movement;
            snake.head_y += 1;
        },
        Direction.Constant, Direction.Null => {},
    }
    return false;
}

fn update_Snake_Tail(board: *[NO_TILES_X][NO_TILES_Y]Tile, snake: *Snake) void {
    switch (board[snake.tail_x][snake.tail_y].has_movement) {
        Direction.Up => {
            board[snake.tail_x][snake.tail_y].has_movement = Direction.Null;
            snake.tail_x -= 1;
        },
        Direction.Down => {
            board[snake.tail_x][snake.tail_y].has_movement = Direction.Null;
            snake.tail_x += 1;
        },
        Direction.Left => {
            board[snake.tail_x][snake.tail_y].has_movement = Direction.Null;
            snake.tail_y -= 1;
        },
        Direction.Right => {
            board[snake.tail_x][snake.tail_y].has_movement = Direction.Null;
            snake.tail_y += 1;
        },
        Direction.Constant, Direction.Null => {},
    }
}

// --------------------------------
// Display Functions
// --------------------------------

fn display_Title_Screen(frame_count: u32) void {
    // Draw the title screen
    raylib.DrawText("SNAKE", @divFloor(raylib.GetScreenWidth(), 2) - @divFloor(raylib.MeasureText("SNAKE", 80), 2), @divFloor(raylib.GetScreenHeight(), 2) - 100, 80, raylib.GREEN);
    raylib.DrawText("Use the defined keys to navigate", @divFloor(raylib.GetScreenWidth(), 2) - @divFloor(raylib.MeasureText("Use the defined keys to navigate", 20), 2), @divFloor(raylib.GetScreenHeight(), 2) - 10, 20, raylib.GREEN);
    if ((frame_count / 30) % 2 == 0) {
        raylib.DrawText("Press [Enter] to start", @divFloor(raylib.GetScreenWidth(), 2) - @divFloor(raylib.MeasureText("Press [Enter] to start", 20), 2), @divFloor(raylib.GetScreenHeight(), 2) + 20, 20, raylib.GREEN);
    }
}

fn display_Game_Screen(board: *[NO_TILES_X][NO_TILES_Y]Tile, snake: *Snake) void {
    // Draw the board
    for (0..NO_TILES_X) |i| {
        const pos_x: c_int = @intCast(i);
        for (0..NO_TILES_Y) |j| {
            const pos_y: c_int = @intCast(j);
            // Snake
            if (i == snake.head_x and j == snake.head_y) {
                raylib.DrawRectangle(pos_y * TILE_HEIGHT, pos_x * TILE_WIDTH, TILE_WIDTH, TILE_HEIGHT, raylib.PURPLE);
            } else if (i == snake.tail_x and j == snake.tail_y) {
                raylib.DrawRectangle(pos_y * TILE_HEIGHT, pos_x * TILE_WIDTH, TILE_WIDTH, TILE_HEIGHT, raylib.YELLOW);
            } else if (board[i][j].has_movement != Direction.Null and board[i][j].has_movement != Direction.Constant) {
                raylib.DrawRectangle(pos_y * TILE_HEIGHT, pos_x * TILE_WIDTH, TILE_WIDTH, TILE_HEIGHT, raylib.GREEN);
                // Food
            } else if (board[i][j].has_movement == Direction.Constant) {
                raylib.DrawRectangle(pos_y * TILE_HEIGHT, pos_x * TILE_WIDTH, TILE_WIDTH, TILE_HEIGHT, raylib.RED);
                // Nothing
            } else {
                raylib.DrawRectangle(pos_y * TILE_HEIGHT, pos_x * TILE_WIDTH, TILE_WIDTH, TILE_HEIGHT, raylib.BLACK);
            }
        }
    }
}

fn display_Endingn_Screen(score: u16, frame_count: u32) !void {
    // Display the score on the screen
    const score_str = try std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{score});
    raylib.DrawText(@ptrCast(score_str), @divFloor(raylib.GetScreenWidth(), 2) - @divFloor(raylib.MeasureText(@ptrCast(score_str), 80), 2), @divFloor(raylib.GetScreenHeight(), 2) - 100, 80, raylib.GREEN);
    if ((frame_count / 30) % 2 == 0) {
        raylib.DrawText("Press [Enter] to start", @divFloor(raylib.GetScreenWidth(), 2) - @divFloor(raylib.MeasureText("Press [Enter] to start", 20), 2), @divFloor(raylib.GetScreenHeight(), 2) + 20, 20, raylib.GREEN);
    }
}

// --------------------------------
// Main
// --------------------------------
pub fn main() !void {
    // --------------------------------
    // Initialize the window and close it at the end
    // --------------------------------
    // var prng = std.rand.DefaultPrng.init(blk: {
    //     var seed: u64 = undefined;
    //     try std.os.getrandom(std.mem.asBytes(&seed));
    //     break :blk seed;
    // });
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Snake!");
    defer raylib.CloseWindow();

    // Define the variables
    var game_state: Game_State = Game_State.Title_Screen;
    var frame_count: u32 = 0;

    var board = [_][NO_TILES_X]Tile{
        [_]Tile{Tile{
            .has_movement = Direction.Null,
        }} ** NO_TILES_Y,
    } ** NO_TILES_X;
    board[NO_TILES_X / 2][NO_TILES_Y / 2].has_movement = Direction.Right;
    board[NO_TILES_X / 2][NO_TILES_Y / 2 - 1].has_movement = Direction.Right;

    var snake = Snake{
        .head_x = NO_TILES_X / 2,
        .head_y = NO_TILES_Y / 2,
        .tail_x = NO_TILES_X / 2,
        .tail_y = NO_TILES_Y / 2 - 1,
    };

    var score: u16 = 0;
    var food: bool = true;

    raylib.SetTargetFPS(60);

    // Run the game
    while (!raylib.WindowShouldClose()) {
        // --------------------------------
        // Update Step
        // --------------------------------
        game_state = switch (game_state) {
            Game_State.Title_Screen => blk: {
                if (raylib.IsKeyPressed(raylib.KEY_ENTER)) {
                    break :blk Game_State.Game_Screen;
                }
                break :blk Game_State.Title_Screen;
            },
            Game_State.Game_Screen => blk: {
                // Update the direction
                if (raylib.IsKeyReleased(SNAKE_UP)) {
                    board[snake.head_x][snake.head_y].has_movement = Direction.Up;
                } else if (raylib.IsKeyReleased(SNAKE_DOWN)) {
                    board[snake.head_x][snake.head_y].has_movement = Direction.Down;
                } else if (raylib.IsKeyReleased(SNAKE_LEFT)) {
                    board[snake.head_x][snake.head_y].has_movement = Direction.Left;
                } else if (raylib.IsKeyReleased(SNAKE_RIGHT)) {
                    board[snake.head_x][snake.head_y].has_movement = Direction.Right;
                }

                // Update the snakes movement
                if (frame_count % SNAKE_WAIT_TIME == 0) {
                    // Place the food
                    if (food) {
                        var locations_x: [NO_TILES_X * NO_TILES_Y]u32 = [_]u32{0} ** (NO_TILES_X * NO_TILES_Y);
                        var locations_y: [NO_TILES_X * NO_TILES_Y]u32 = [_]u32{0} ** (NO_TILES_X * NO_TILES_Y);
                        var count: u16 = 0;
                        for (0..NO_TILES_X) |i| {
                            for (0..NO_TILES_Y) |j| {
                                if (board[i][j].has_movement == Direction.Null) {
                                    locations_x[count] = @intCast(i);
                                    locations_y[count] = @intCast(j);
                                    count += 1;
                                }
                            }
                        }
                        if (count == 0) {
                            break :blk Game_State.Ending_Screen;
                        } else {
                            const pos: u16 = rand.intRangeAtMost(u16, 0, count);
                            board[locations_x[pos]][locations_y[pos]].has_movement = Direction.Constant;
                        }
                        food = false;
                    }

                    // Move the snakes head
                    var place_food: bool = false;
                    const collision: bool = update_Snake_Head(&board, &snake, &place_food);
                    if (collision) {
                        break :blk Game_State.Ending_Screen;
                    }

                    // Check if the snake ate
                    if (place_food) {
                        score += 1;
                        food = true;
                    } else {
                        // Move the snakes tail
                        update_Snake_Tail(&board, &snake);
                    }
                }
                break :blk Game_State.Game_Screen;
            },
            Game_State.Ending_Screen => blk: {
                if (raylib.IsKeyPressed(raylib.KEY_ENTER)) {
                    board = [_][NO_TILES_X]Tile{
                        [_]Tile{Tile{
                            .has_movement = Direction.Null,
                        }} ** NO_TILES_Y,
                    } ** NO_TILES_X;
                    board[NO_TILES_X / 2][NO_TILES_Y / 2].has_movement = Direction.Right;
                    board[NO_TILES_X / 2][NO_TILES_Y / 2 - 1].has_movement = Direction.Right;

                    snake = Snake{
                        .head_x = NO_TILES_X / 2,
                        .head_y = NO_TILES_Y / 2,
                        .tail_x = NO_TILES_X / 2,
                        .tail_y = NO_TILES_Y / 2 - 1,
                    };

                    score = 0;
                    food = true;

                    break :blk Game_State.Title_Screen;
                }
                break :blk Game_State.Ending_Screen;
            },
        };
        frame_count += 1;

        // --------------------------------
        // Draw Step
        // --------------------------------
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);

        try switch (game_state) {
            Game_State.Title_Screen => display_Title_Screen(frame_count),
            Game_State.Game_Screen => display_Game_Screen(&board, &snake),
            Game_State.Ending_Screen => display_Endingn_Screen(score, frame_count),
        };
    }
}
