#![cfg_attr(feature="clippy", feature(plugin))]
#![cfg_attr(feature="clippy", plugin(clippy))]

use std::time::{Instant};
use std::collections::HashSet;
use std::hash::{Hash,Hasher};

#[derive(Clone)]
struct Shape {
    collider: [[bool; 3]; 3],
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
    height: i8,
    width: i8
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
    collider: [[true, false, false],
               [false, false, false],
               [false, false, false]],
    height: 1,
    width: 1
};

static VTWO: Shape = Shape {
    collider: [[true, false, false],
               [true, false, false],
               [false, false, false]],
    height: 2,
    width: 1
};

static FTWO: Shape = Shape {
    collider: [[true, true, false],
               [false, false, false],
               [false, false, false]],
    height: 1,
    width: 2
};

static GOAL: Shape = Shape {
    collider: [[false, true, false],
               [true, true, true],
               [false, false, false]],
    height: 2,
    width: 3
};

static LEFT: Shape = Shape {
    collider: [[true, true, false],
               [true, false, false],
               [false, false, false]],
    height: 2,
    width: 2
};

static RIGHT: Shape = Shape {
    collider: [[false, true, false],
               [true, true, false],
               [false, false, false]],
    height: 2,
    width: 2
};

fn initial_board() -> Board {
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

fn show(board: &Board) {
    let emoji = [
        "🍺",
        "🔴",
        "😍",
        "🔵",
        "💩",
        "💬",
        "⛩",
        "♥",
        "🤡",
        "☂",
        "😹",
        "⬛",
        "⬛",
    ];

    let mut drawing: [[&str; 5]; 6] = [["⬜"; 5]; 6];

    for (pid, piece) in board.pieces.iter().enumerate() {
        println!("id: {} {} ({}, {}) mov: {}", pid, emoji[pid], piece.origin.0, piece.origin.1, piece.movable);
        for (y, row) in piece.shape.collider.iter().enumerate() {
            for (x, cell) in row.iter().enumerate() {
                if cell == &true {
                    drawing[piece.origin.0 + y][piece.origin.1 + x] = emoji[pid]
                }
            }

        }
    }

    for row in drawing.iter() {
        for cell in row {
            print!(" {} ", cell);
        }
        println!();
        println!();
    }
}

fn movements(piece: &Piece) -> Vec<Piece> {
    let mut new_pieces = vec!();
    if piece.origin.0 + piece.shape.height < 6 {
        new_pieces.push(Piece { origin: (piece.origin.0 + 1, piece.origin.1), shape: piece.shape, movable: true })
    }
    if piece.origin.1 + piece.shape.width < 5 {
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

fn area_for(pieces: &[Piece], ignore_location: usize) -> [[bool; 5]; 6] {
    let mut area: [[bool; 5]; 6] = [[false; 5]; 6];
    for (i, piece) in pieces.iter().enumerate() {
        if i == ignore_location {
            continue;
        }
        for (y, row) in piece.shape.collider.iter().enumerate() {
            for (x, cell) in row.iter().enumerate() {
                if *cell {
                    area[piece.origin.0 + y][piece.origin.1 + x] = true;
                }
            }
        }
    }
    area
}

fn valid(piece: &Piece, area: &[[bool; 5]; 6]) -> bool {
    for (y, row) in piece.shape.collider.iter().enumerate() {
        for (x, cell) in row.iter().enumerate() {
            if *cell && area[piece.origin.0 + y][piece.origin.1 + x] {
                return false;
            }
        }
    }
    true
}

fn potential_boards(board: &Board) -> Vec<Board> {
    let mut potentials: Vec<Board> = vec!();
    for (i, piece) in board.pieces.iter().enumerate().filter(|p| p.1.movable) {
        let area: [[bool; 5]; 6] = area_for(&board.pieces, i);
        for moved_piece in movements(piece) {
            if valid(&moved_piece, &area) {
                let mut new_board: Board = board.clone();
                replace(moved_piece, i, &mut new_board);
                potentials.push(new_board);
            }
        }
    }
    potentials
}

fn expand_layer(boards: &[Board], seen_boards: &HashSet<Board>) -> Vec<Board> {
    let mut potentials: Vec<Board> = vec!();
    let pboards: Vec<Vec<Board>> = boards.iter().map(|board| potential_boards(board)).collect();

    for mut boards in pboards {
        // boards.retain(|b| (previous.iter().find(|pb| pb.contains(b)).is_none()));
        boards.retain(|b| !seen_boards.contains(b));
        potentials.append(&mut boards);
    }
    potentials
}

fn goal(board: &Board) -> bool {
    board.pieces[2].origin.0 == 0
}

fn main() {
    let now = Instant::now();
    let mut layer: Vec<Board> = vec!(initial_board());
    let mut seen_boards: HashSet<Board> = HashSet::new();
    let mut counter: usize = 0;
    while counter < 40 {
        layer = expand_layer(&layer, &seen_boards);
        match layer.iter().find(|b| goal(b)) {
            Some(b) => {
                println!("found the goal!");
                show(&b);
                break;
            }
            None => {
            }
        }
        // for board in layer.iter() { show(&board); }
        println!("layer {} size: {} | {} s", counter, layer.len(), now.elapsed().as_secs());

        for board in layer.iter() {
            seen_boards.insert(board.clone());
        }
        counter += 1;
    }
}
