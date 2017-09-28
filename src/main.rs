#![cfg_attr(feature="clippy", feature(plugin))]
#![cfg_attr(feature="clippy", plugin(clippy))]

use std::time::{Instant};
use std::collections::HashSet;
use std::hash::{Hash,Hasher};

struct Shape {
    collider: [u8; 3],
    height: usize,
    width: usize
}

#[derive(Clone)]
struct Piece {
    origin: (usize, usize),
    shape: &'static Shape,
    movable: bool
}

#[derive(Clone)]
struct Board {
    pieces: Vec<Piece>,
    height: usize,
    width: usize
}

impl Hash for Board {
    fn hash<H: Hasher>(&self, state: &mut H) {
        for (i, piece) in self.pieces.iter().enumerate() {
            piece.origin.0.hash(state);
            piece.origin.1.hash(state);
            i.hash(state);
        }
    }
}

impl PartialEq for Board {
    fn eq(&self, other: &Board) -> bool {
        for (piece, other_piece) in self.pieces.iter().zip(other.pieces.iter()) {
            if piece.origin != other_piece.origin {
                return false;
            }
        }
        true
    }
}
impl Eq for Board {}


static DOT: Shape = Shape {
    collider: [0b100, 0b000, 0b000],
    // collider: [[X, O, O],
    //            [O, O, O],
    //            [O, O, O]],
    height: 1,
    width: 1
};

static VTWO: Shape = Shape {
    collider: [0b100, 0b100, 0b000],
    // collider: [[X, O, O],
    //            [X, O, O],
    //            [O, O, O]],
    height: 2,
    width: 1
};

static FTWO: Shape = Shape {
    collider: [0b110, 0b000, 0b000],
    // X X O
    // O O O
    // O O O
    height: 1,
    width: 2
};

static GOAL: Shape = Shape {
    collider: [0b010, 0b111, 0b000],
    // O X O
    // X X X
    // O O O
    height: 2,
    width: 3
};

static LEFT: Shape = Shape {
    collider: [0b110, 0b100, 0b0],
    // X X O
    // X O O
    // O O O
    height: 2,
    width: 2
};

static RIGHT: Shape = Shape {
    collider: [0b010, 0b110, 0b000],
    // O X O
    // X X O
    // O O O
    height: 2,
    width: 2
};

static SQUARE: Shape = Shape {
    collider: [0b110, 0b110, 0b000],
    // X X O
    // X X O
    // O O O
    height: 2,
    width: 2
};

fn show(pieces: &[Piece], height: usize, width: usize) {
    let mut area: [u8; 6] = [0b0; 6];
    for piece in pieces.iter() {
        for (y, row) in piece.shape.collider.iter().enumerate() {
            if piece.origin.0 + y < height {
                area[piece.origin.0 + y] = area[piece.origin.0 + y] | (row << (width - 1) - piece.origin.1);
            }
        }
    }
    println!("-------");
    for row in area.iter() {
        println!("{:#b}", row);
    }
    println!("-------");
}

fn ten_board() -> Board {
    Board { pieces: vec!(
        Piece { origin: (1,0), shape: &LEFT,   movable: true },
        Piece { origin: (2,2), shape: &DOT,    movable: true },
        Piece { origin: (3,1), shape: &SQUARE, movable: true },
        Piece { origin: (1,3), shape: &VTWO,   movable: true },
        Piece { origin: (3,0), shape: &DOT,    movable: true },
        Piece { origin: (3,3), shape: &DOT,    movable: true },
        Piece { origin: (4,0), shape: &VTWO,   movable: true },
        Piece { origin: (5,1), shape: &DOT,    movable: true },
        Piece { origin: (4,2), shape: &RIGHT,  movable: true },
        Piece { origin: (0,0), shape: &DOT,    movable: false },
        Piece { origin: (0,3), shape: &DOT,    movable: false },
    ),
            height: 6,
            width: 4,
    }
}


fn twelve_board() -> Board {
    Board { pieces: vec!(
        Piece { origin: (1,0), shape: &VTWO,  movable: true },
        Piece { origin: (1,4), shape: &VTWO,  movable: true },
        Piece { origin: (4,1), shape: &GOAL,  movable: true },
        Piece { origin: (2,1), shape: &LEFT,  movable: true },
        Piece { origin: (2,2), shape: &RIGHT, movable: true },
        Piece { origin: (3,0), shape: &DOT,   movable: true },
        Piece { origin: (3,4), shape: &DOT,   movable: true },
        Piece { origin: (5,0), shape: &DOT,   movable: true },
        Piece { origin: (5,4), shape: &DOT,   movable: true },
        Piece { origin: (4,0), shape: &FTWO,  movable: true },
        Piece { origin: (4,3), shape: &FTWO,  movable: true },
        Piece { origin: (0,0), shape: &FTWO,  movable: false },
        Piece { origin: (0,3), shape: &FTWO,  movable: false },
    ),
            height: 6,
            width: 5
    }
}

fn movements(piece: &Piece, height: usize, width: usize) -> Vec<Piece> {
    let mut new_pieces = vec!();
    if piece.origin.0 + piece.shape.height < height {
        new_pieces.push(Piece { origin: (piece.origin.0 + 1, piece.origin.1), shape: piece.shape, movable: true })
   }
    if piece.origin.1 + piece.shape.width < width {
        new_pieces.push(Piece { origin: (piece.origin.0, piece.origin.1 + 1), shape: piece.shape, movable: true })
    }
    if piece.origin.0 > 0 {
        new_pieces.push(Piece { origin: (piece.origin.0 - 1, piece.origin.1), shape: piece.shape, movable: true })
    }
    if piece.origin.1 > 0 {
        new_pieces.push(Piece { origin: (piece.origin.0, piece.origin.1 - 1), shape: piece.shape, movable: true })
    }
    new_pieces
}

fn replace(new_piece: Piece, location: usize, board: &mut Board) {
    board.pieces[location] = new_piece;
}

fn area_for(pieces: &[Piece], ignore_location: usize, height: usize, width: usize) -> [u8; 6] {
    let mut area: [u8; 6] = [0b0; 6]; // TODO: area literals
    for (i, piece) in pieces.iter().enumerate() {
        if i == ignore_location {
            continue;
        }
        for (y, row) in piece.shape.collider.iter().enumerate() {
            if piece.origin.0 + y < height {
                area[piece.origin.0 + y] = area[piece.origin.0 + y] | (row << (width - 1) - piece.origin.1);
            }
        }
    }
    area
}

fn valid(piece: &Piece, area: &[u8], _height: usize, width: usize) -> bool {
    for (y, row) in piece.shape.collider.iter().enumerate() {
        if row != &0b0 && ((area[piece.origin.0 + y] & (row << (width - 1) - piece.origin.1)) != 0b0) {
            return false;
        }
    }
    true
}

fn potential_boards(board: &Board, seen_boards: &mut HashSet<Board>) -> Vec<Board> {
    let mut potentials: Vec<Board> = vec!();
    for (i, piece) in board.pieces.iter().enumerate().filter(|p| p.1.movable) {
        let area: [u8; 6] = area_for(&board.pieces, i, board.height, board.width);
        for moved_piece in movements(piece, board.height, board.width) {
            if valid(&moved_piece, &area, board.height, board.width) {
                let mut new_board: Board = board.clone();
                replace(moved_piece, i, &mut new_board);
                if !seen_boards.contains(&new_board) {
                    seen_boards.insert(new_board.clone());
                    potentials.push(new_board);
                }
            }
        }
    }
    potentials
}

fn expand_layer(boards: &[Board], seen_boards: &mut HashSet<Board>) -> Vec<Board> {
    let mut potentials: Vec<Board> = Vec::new();
    for board in boards {
        potentials.extend(potential_boards(board, seen_boards));
    }
    potentials
}

fn goal(board: &Board) -> bool {
    board.pieces[2].origin.0 == 0
}


fn main() {
    let now = Instant::now();
    let mut layer: Vec<Board> = vec!(ten_board());
    let mut seen_boards: HashSet<Board> = HashSet::new();
    let mut counter: usize = 0;
    while counter < 90 {
        layer = expand_layer(&layer, &mut seen_boards);
        match layer.iter().find(|b| goal(b)) {
            Some(b) => {
                println!("found the goal!");
                show(&b.pieces, b.height, b.width);
                break;
            }
            None => {
            }
        }
        println!("layer {} \t size: {} \t | {} s", counter, layer.len(), now.elapsed().as_secs());
        counter += 1;
    }
}
